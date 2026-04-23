
%{
#include <stdio.h>
#include <stdlib.h>
/* Declarações para evitar avisos de função implícita */
int yylex(void);                //usado para pedir próximo token
void yyerror(const char *s);    //usado quando há um erro
%}

/* Define valor semântico (intValue) */
%union {
    int intValue;
    float floatValue;
    char *str;
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
%token NEWLINE
%token COMPARATION EQUAL
%token SEMICOLON LBRACE RBRACE LESS_EQUAL GREATER_EQUAL NOT_EQUAL LOGICAL_AND LOGICAL_OR
/* Declara precedência:
   - PLUS e MINUS têm menor precedência
   - TIMES e DIVIDE têm maior precedência */
%left PLUS MINUS
%left TIMES DIVIDE

/* Associa o não terminal expr ao tipo intValue */
%type <intValue> expr

%%

input:
            /* vazio */
        | input NEWLINE
        | input expr NEWLINE { printf("Resultado final: %d\n", $2); }
        ;

expr:
      /*
        $$ = resultado 
        $1 = valor da primeira expr
        $3 = valor da segunda expr ($2 é representado pelo +)
      */

      expr PLUS expr    {
        $$ = $1 + $3;
        printf("Expr processada: %d + %d = %d\n", $1, $3, $$);
    }
    | expr MINUS expr   {
        $$ = $1 - $3;
        printf("Expr processada: %d - %d = %d\n", $1, $3, $$);
    }
    | expr TIMES expr   {
        $$ = $1 * $3;
        printf("Expr processada: %d * %d = %d\n", $1, $3, $$);
    }
    | expr DIVIDE expr  {
        if ($3 == 0) {
            printf("Erro: divisao por zero em %d / %d\n", $1, $3);
            $$ = 0;
        } else {
            $$ = $1 / $3;
            printf("Expr processada: %d / %d = %d\n", $1, $3, $$);
        }
    }
    | LPAREN expr RPAREN{
        $$ = $2;
        printf("Expr processada: (%d) = %d\n", $2, $$);
    }
    | NUM               {
        $$ = $1;
        printf("Numero processado: %d\n", $$);
    }
    | ID                {
        printf("Identificador processado: %s (valor temporario = 0)\n", $1);
        free($1);
        $$ = 0;
    }
    
    /* IMPLEMENTAÇÃO TEMPORÁRIA ANTES DA ÁRVORE SINTÁTICA*/
    | STRING_LITERAL    {
        printf("String processada: %s\n", $1);
        $$ = 0;
        free($1);
    }
    | CHAR_LITERAL      {
        printf("Char processado: %s\n", $1);
        $$ = $1[1];
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
