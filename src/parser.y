
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
}

/* Token que carrega valor semântico */
%token <intValue> NUM
%token <floatValue> NUMFLOAT

/* Tokens sem valor semântico, mas com precedência */
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN
%token COMPARATION EQUAL
/* Declara precedência:
   - PLUS e MINUS têm menor precedência
   - TIMES e DIVIDE têm maior precedência */
%left PLUS MINUS
%left TIMES DIVIDE

/* Associa o não terminal expr ao tipo intValue */
%type <intValue> expr

%%

expr:
      expr PLUS expr    { $$ = $1 + $3; }
      
      /*
        $$ = resultado 
        $1 = valor da primeira expr
        $3 = valor da segunda expr ($2 é representado pelo +)
      */

    | expr MINUS expr   { $$ = $1 - $3; }
    | expr TIMES expr   { $$ = $1 * $3; }
    | expr DIVIDE expr  { $$ = $1 / $3; }
    | LPAREN expr RPAREN{ $$ = $2; }
    | NUM               { $$ = $1; }
    | NUMFLOAT             { $$ = $1; }
    ;

%%

int main(void) {
    return yyparse();
}

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}
