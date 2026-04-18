%code requires {
typedef enum ExprKind {
    EXPR_KIND_INVALID = 0,
    EXPR_KIND_INT,
    EXPR_KIND_FLOAT,
    EXPR_KIND_CHAR,
    EXPR_KIND_STRING
} ExprKind;

typedef struct ExprValue {
    ExprKind kind;
    union {
        int intValue;
        float floatValue;
        char charValue;
        char *stringValue;
    } as;
} ExprValue;
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

/* Declaracoes para evitar avisos de funcao implicita */
int yylex(void);                // usado para pedir proximo token
void yyerror(const char *s);    // usado quando ha um erro
extern int yylineno;
%}

%code {
static ExprValue make_invalid_expr(void) {
    ExprValue value;
    value.kind = EXPR_KIND_INVALID;
    value.as.intValue = 0;
    return value;
}

static ExprValue make_int_expr(int int_value) {
    ExprValue value;
    value.kind = EXPR_KIND_INT;
    value.as.intValue = int_value;
    return value;
}

static ExprValue make_float_expr(float float_value) {
    ExprValue value;
    value.kind = EXPR_KIND_FLOAT;
    value.as.floatValue = float_value;
    return value;
}

static ExprValue make_char_expr(char char_value) {
    ExprValue value;
    value.kind = EXPR_KIND_CHAR;
    value.as.charValue = char_value;
    return value;
}

static ExprValue make_string_expr(char *string_value) {
    ExprValue value = make_invalid_expr();

    if (string_value == NULL) {
        return value;
    }

    value.kind = EXPR_KIND_STRING;
    value.as.stringValue = string_value;
    return value;
}

static void free_expr_value(ExprValue *value) {
    if (value == NULL) {
        return;
    }

    if (value->kind == EXPR_KIND_STRING && value->as.stringValue != NULL) {
        free(value->as.stringValue);
        value->as.stringValue = NULL;
    }

    value->kind = EXPR_KIND_INVALID;
    value->as.intValue = 0;
}

static void semantic_error(const char *format, ...) {
    va_list arguments;

    fprintf(stderr, "Erro semantico");
    if (yylineno > 0) {
        fprintf(stderr, " (linha %d)", yylineno);
    }
    fprintf(stderr, ": ");

    va_start(arguments, format);
    vfprintf(stderr, format, arguments);
    va_end(arguments);

    fprintf(stderr, "\n");
}

static int is_numeric_kind(ExprKind kind) {
    return kind == EXPR_KIND_INT || kind == EXPR_KIND_FLOAT || kind == EXPR_KIND_CHAR;
}

static int expr_as_int(const ExprValue *value) {
    if (value->kind == EXPR_KIND_INT) {
        return value->as.intValue;
    }

    if (value->kind == EXPR_KIND_CHAR) {
        return (unsigned char)value->as.charValue;
    }

    return (int)value->as.floatValue;
}

static float expr_as_float(const ExprValue *value) {
    if (value->kind == EXPR_KIND_FLOAT) {
        return value->as.floatValue;
    }

    if (value->kind == EXPR_KIND_CHAR) {
        return (float)(unsigned char)value->as.charValue;
    }

    return (float)value->as.intValue;
}

static char *duplicate_text(const char *text) {
    size_t length = (text == NULL) ? 0U : strlen(text);
    char *copy = (char *)malloc(length + 1);

    if (copy == NULL) {
        return NULL;
    }

    if (length > 0) {
        memcpy(copy, text, length);
    }

    copy[length] = '\0';
    return copy;
}

static char *text_from_concat_operand(const ExprValue *value) {
    char *text;

    if (value->kind == EXPR_KIND_STRING) {
        return duplicate_text(value->as.stringValue);
    }

    if (value->kind != EXPR_KIND_CHAR) {
        return NULL;
    }

    text = (char *)malloc(2);
    if (text == NULL) {
        return NULL;
    }

    text[0] = value->as.charValue;
    text[1] = '\0';
    return text;
}

static ExprValue concat_expr_values(const ExprValue *left, const ExprValue *right) {
    char *left_text = text_from_concat_operand(left);
    char *right_text = text_from_concat_operand(right);
    char *joined;
    size_t joined_length;

    if (left_text == NULL || right_text == NULL) {
        free(left_text);
        free(right_text);
        return make_invalid_expr();
    }

    joined_length = strlen(left_text) + strlen(right_text);
    joined = (char *)malloc(joined_length + 1);
    if (joined == NULL) {
        free(left_text);
        free(right_text);
        return make_invalid_expr();
    }

    strcpy(joined, left_text);
    strcat(joined, right_text);

    free(left_text);
    free(right_text);
    return make_string_expr(joined);
}

static ExprValue numeric_add_expr(const ExprValue *left, const ExprValue *right) {
    if (left->kind == EXPR_KIND_FLOAT || right->kind == EXPR_KIND_FLOAT) {
        return make_float_expr(expr_as_float(left) + expr_as_float(right));
    }

    return make_int_expr(expr_as_int(left) + expr_as_int(right));
}

static ExprValue numeric_subtract_expr(const ExprValue *left, const ExprValue *right) {
    if (left->kind == EXPR_KIND_FLOAT || right->kind == EXPR_KIND_FLOAT) {
        return make_float_expr(expr_as_float(left) - expr_as_float(right));
    }

    return make_int_expr(expr_as_int(left) - expr_as_int(right));
}

static ExprValue numeric_multiply_expr(const ExprValue *left, const ExprValue *right) {
    if (left->kind == EXPR_KIND_FLOAT || right->kind == EXPR_KIND_FLOAT) {
        return make_float_expr(expr_as_float(left) * expr_as_float(right));
    }

    return make_int_expr(expr_as_int(left) * expr_as_int(right));
}

static ExprValue numeric_divide_expr(const ExprValue *left, const ExprValue *right) {
    if (left->kind == EXPR_KIND_FLOAT || right->kind == EXPR_KIND_FLOAT) {
        return make_float_expr(expr_as_float(left) / expr_as_float(right));
    }

    return make_int_expr(expr_as_int(left) / expr_as_int(right));
}
}

/* Define valor semantico */
%union {
    int intValue;
    float floatValue;
    char charValue;
    char *stringValue;
    ExprValue exprValue;
}

/* Token que carrega valor semantico */
%token <intValue> NUM
%token <floatValue> NUMFLOAT
%token <charValue> CHAR
%token <stringValue> STRING

/* Tokens sem valor semantico, mas com precedencia */
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN
%token COMPARATION EQUAL
%token SEMICOLON LBRACE RBRACE
%token LESS_EQUAL GREATER_EQUAL NOT_EQUAL
%token LOGICAL_AND LOGICAL_OR

/* Declara precedencia:
   - PLUS e MINUS tem menor precedencia
   - TIMES e DIVIDE tem maior precedencia */
%left PLUS MINUS
%left TIMES DIVIDE

%type <exprValue> expr
%start input

%destructor { free($$); } <stringValue>
%destructor {
    if ($$.kind == EXPR_KIND_STRING && $$.as.stringValue != NULL) {
        free($$.as.stringValue);
        $$.as.stringValue = NULL;
    }
    $$.kind = EXPR_KIND_INVALID;
} <exprValue>

%%

input:
      expr { free_expr_value(&$1); }
    ;

expr:
      expr PLUS expr
      {
          if ($1.kind == EXPR_KIND_INVALID || $3.kind == EXPR_KIND_INVALID) {
              $$ = make_invalid_expr();
          } else if ($1.kind == EXPR_KIND_STRING || $3.kind == EXPR_KIND_STRING) {
              if (($1.kind == EXPR_KIND_STRING || $1.kind == EXPR_KIND_CHAR) &&
                  ($3.kind == EXPR_KIND_STRING || $3.kind == EXPR_KIND_CHAR)) {
                  $$ = concat_expr_values(&$1, &$3);
                  if ($$.kind == EXPR_KIND_INVALID) {
                      semantic_error("falha ao concatenar operandos de STRING");
                  }
              } else {
                  semantic_error("operador '+' nao suporta STRING com operando numerico");
                  $$ = make_invalid_expr();
              }
          } else if (is_numeric_kind($1.kind) && is_numeric_kind($3.kind)) {
              $$ = numeric_add_expr(&$1, &$3);
          } else {
              semantic_error("operandos invalidos para '+'");
              $$ = make_invalid_expr();
          }

          free_expr_value(&$1);
          free_expr_value(&$3);
      }
    | expr MINUS expr
      {
          if ($1.kind == EXPR_KIND_INVALID || $3.kind == EXPR_KIND_INVALID) {
              $$ = make_invalid_expr();
          } else if ($1.kind == EXPR_KIND_STRING || $3.kind == EXPR_KIND_STRING) {
              semantic_error("operador '-' nao permite operandos STRING");
              $$ = make_invalid_expr();
          } else if (is_numeric_kind($1.kind) && is_numeric_kind($3.kind)) {
              $$ = numeric_subtract_expr(&$1, &$3);
          } else {
              semantic_error("operandos invalidos para '-'");
              $$ = make_invalid_expr();
          }

          free_expr_value(&$1);
          free_expr_value(&$3);
      }
    | expr TIMES expr
      {
          if ($1.kind == EXPR_KIND_INVALID || $3.kind == EXPR_KIND_INVALID) {
              $$ = make_invalid_expr();
          } else if ($1.kind == EXPR_KIND_STRING || $3.kind == EXPR_KIND_STRING) {
              semantic_error("operador '*' nao permite operandos STRING");
              $$ = make_invalid_expr();
          } else if (is_numeric_kind($1.kind) && is_numeric_kind($3.kind)) {
              $$ = numeric_multiply_expr(&$1, &$3);
          } else {
              semantic_error("operandos invalidos para '*'");
              $$ = make_invalid_expr();
          }

          free_expr_value(&$1);
          free_expr_value(&$3);
      }
    | expr DIVIDE expr
      {
          if ($1.kind == EXPR_KIND_INVALID || $3.kind == EXPR_KIND_INVALID) {
              $$ = make_invalid_expr();
          } else if ($1.kind == EXPR_KIND_STRING || $3.kind == EXPR_KIND_STRING) {
              semantic_error("operador '/' nao permite operandos STRING");
              $$ = make_invalid_expr();
          } else if (is_numeric_kind($1.kind) && is_numeric_kind($3.kind)) {
              if (($1.kind == EXPR_KIND_FLOAT || $3.kind == EXPR_KIND_FLOAT) && expr_as_float(&$3) == 0.0f) {
                  semantic_error("divisao por zero");
                  $$ = make_invalid_expr();
              } else if ($1.kind != EXPR_KIND_FLOAT && $3.kind != EXPR_KIND_FLOAT && expr_as_int(&$3) == 0) {
                  semantic_error("divisao por zero");
                  $$ = make_invalid_expr();
              } else {
                  $$ = numeric_divide_expr(&$1, &$3);
              }
          } else {
              semantic_error("operandos invalidos para '/'");
              $$ = make_invalid_expr();
          }

          free_expr_value(&$1);
          free_expr_value(&$3);
      }
    | LPAREN expr RPAREN
      {
          $$ = $2;
      }
    | NUM
      {
          $$ = make_int_expr($1);
      }
    | NUMFLOAT
      {
          $$ = make_float_expr($1);
      }
    | CHAR
      {
          $$ = make_char_expr($1);
      }
    | STRING
      {
          $$ = make_string_expr($1);
      }
    ;

%%

int main(void) {
    return yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintatico");
    if (yylineno > 0) {
        fprintf(stderr, " (linha %d)", yylineno);
    }
    fprintf(stderr, ": %s\n", s);
}
