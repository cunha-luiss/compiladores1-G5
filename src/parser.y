
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Forward declaration local para permitir uso de ponteiros para ASTNode. */
typedef struct ASTNode ASTNode;

/* Declarações para evitar avisos de função implícita */
int yylex(void);                //usado para pedir próximo token
void yyerror(const char *s);    //usado quando há um erro

/* Construtores esperados em ast.h/ast.c (implementação futura). */
ASTNode *new_if(ASTNode *cond, ASTNode *then_branch, ASTNode *else_branch);
ASTNode *new_binary(const char *op, ASTNode *left, ASTNode *right);
ASTNode *new_int_literal(int value);
ASTNode *new_float_literal(float value);
ASTNode *new_identifier(const char *name);
ASTNode *new_string_literal(const char *value);
ASTNode *new_char_literal(const char *value);

/* Raiz da AST */
ASTNode *root = NULL;
%}

/* Garante que parser.tab.h conheça ASTNode antes de YYSTYPE. */
%code requires {
    typedef struct ASTNode ASTNode;
}

/* Define valor semântico */
%union {
    int intValue;
    float floatValue;
    char *str;
    ASTNode *node;
}

/* Token que carrega valor semântico */
%token <intValue> NUM
%token <floatValue> NUMFLOAT
%token <str> ID
%token <str> STRING_LITERAL
%token <str> CHAR_LITERAL


/* Tipos e Especificadores de Tipo */
%token KW_BOOL BOOL_TYPE DOUBLE_TYPE KW_LONG KW_SIZE TYPE_MODIFIER TYPE_SPECIFIER KW_TYPE_MODIFIER
%token KW_DECIMAL32 KW_DECIMAL64 KW_DECIMAL128 KW_COMPLEX KW_IMAGINARY
%token KW_TYPE_DECLARATION KW_DECLARATION_OF_A_COMPOUND_TYPE KW_DECLARATION_OF_A_UNION_TYPE ENUMERATION_TYPE
%token KW_TYPE_OF_VARIABLE_OR_PARAMETER_OF_FUNCTION_OR_RETURN_VALUE

/* Estruturas de Controle e Laços */
%token IF_STATEMENT ELSE_STATEMENT KW_WHILE DO_LOOP LOOP
%token SWITCH_STATEMENT KW_SWITCH DEFAULT_STATEMENT
%token CONTINUE_STATEMENT DECLARATION STATEMENT RETURN_STATEMENT

/* Modificadores de Acesso, Classes de Armazenamento e Qualificadores */
%token KW_STATIC STORAGE_CLASS_SPECIFIER AUTOMATIC_DURATION_STORAGE_CLASS_SPECIFIER
%token INLINE_FUNCTION_SPECIFIER TYPE_QUALIFIER KW_TYPE_QUALIFIER CONST_LITERAL SPECIFIER
%token THREAD_STORAGE KW_THREAD_STORAGE_CLASS_SPECIFIER AUTO_TYPE_INFERENCE

/* Alinhamento, Asserções e Atômicos */
%token KW_ALIGNAS KW_ALIGNOF KW_ALIGNMENT
%token KW_ATOMIC
%token KW_STATIC_ASSERT STATIC_ASSERT_DECLARATION
%token KW_GENERIC KW_NORETURN

/* Literais Reservados e Operadores Especiais */
%token TRUE_LITERAL FALSE_LITERAL POINTER_CONSTANT
%token OPERATOR KW_OPERATOR KW_OPERATOR_THAT_REMOVES_QUALIFIERS


/* Tokens sem valor semântico, mas com precedência */
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN
%token COMPARATION EQUAL
%token SEMICOLON LBRACE RBRACE LESS_EQUAL GREATER_EQUAL NOT_EQUAL LOGICAL_AND LOGICAL_OR

/* Declara precedência:
   - PLUS e MINUS têm menor precedência
   - TIMES e DIVIDE têm maior precedência */
%left PLUS MINUS
%left TIMES DIVIDE

/* Não-terminais que carregam nó da AST */
%type <node> program stmt expr
%start program

%%

program
    : stmt
        {
            root = $1;
            $$ = $1;
        }
    ;

stmt
    : IF_STATEMENT LPAREN expr RPAREN stmt ELSE_STATEMENT stmt
        { $$ = new_if($3, $5, $7); }
    | expr SEMICOLON
        { $$ = $1; }
    ;

expr:
      /*
        $$ = resultado 
        $1 = valor da primeira expr
        $3 = valor da segunda expr ($2 é representado pelo +)
      */
            expr PLUS expr     { $$ = new_binary("+", $1, $3); }
        | expr MINUS expr    { $$ = new_binary("-", $1, $3); }
        | expr TIMES expr    { $$ = new_binary("*", $1, $3); }
        | expr DIVIDE expr   { $$ = new_binary("/", $1, $3); }
        | LPAREN expr RPAREN { $$ = $2; }
        | NUM                { $$ = new_int_literal($1); }
        | NUMFLOAT           { $$ = new_float_literal($1); }
        | ID                 { $$ = new_identifier($1); free($1); }
        | STRING_LITERAL {
            printf("String processada: %s\n", $1);
            $$ = new_string_literal($1);
            free($1);
        }
        | CHAR_LITERAL {
            printf("Char processado: %s\n", $1);
            $$ = new_char_literal($1);
            free($1);
        }

    ;

%%

int main(void) {
    return yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}
