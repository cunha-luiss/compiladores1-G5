
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/* Declarações para evitar avisos de função implícita 

Rodar com:

gcc -o parser parser.tab.c lex.yy.c ast.c -lfl

*/
int yylex(void);                //usado para pedir próximo token
void yyerror(const char *s);    //usado quando há um erro
extern int yylineno;
extern char *yytext;
extern int lexical_errors;

static int syntax_errors = 0;

/* Raiz da AST */
ASTNode *root = NULL;
%}

%define parse.error verbose

/* Garante que parser.tab.h conheça ASTNode antes de YYSTYPE. */
%code requires {
    typedef struct ASTNode ASTNode;
}

/* Define valor semântico (intValue) */
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
%token NEWLINE
%token COMPARATION EQUAL
%token SEMICOLON LBRACE RBRACE LESS_EQUAL GREATER_EQUAL NOT_EQUAL LOGICAL_AND LOGICAL_OR
/* Declara precedência:
   - PLUS e MINUS têm menor precedência
   - TIMES e DIVIDE têm maior precedência */
%left PLUS MINUS
%left TIMES DIVIDE

/* Associa o não terminal expr ao tipo intValue */
%type <node> expr

/* Não-terminais que carregam nó da AST */
%type <node> program stmt stmt_list
%start program


%%

program
    : stmt
        {
            root = $1;
            $$ = $1;
        }
    ;

stmt_list
    : stmt
        { $$ = $1; }

    | stmt_list stmt
        {
            $$ = $2;
        }
    ;

stmt
    : IF_STATEMENT LPAREN expr RPAREN stmt ELSE_STATEMENT stmt
        { $$ = new_if((ASTNode*)(long)$3, $5, $7); }

    | IF_STATEMENT LPAREN expr RPAREN stmt
        { $$ = new_if((ASTNode*)(long)$3, $5, NULL); }

    | KW_WHILE LPAREN expr RPAREN stmt
        { $$ = new_while((ASTNode*)(long)$3, $5); }

    | LBRACE stmt_list RBRACE
    { $$ = $2; }
        
    | expr SEMICOLON
        { $$ = $1;  /* O ideal aqui eh criar um no para a expressao; usando cast para evitar warning de tipagem */ }
    ;

expr:
      /*
        $$ = resultado 
        $1 = valor da primeira expr
        $3 = valor da segunda expr ($2 é representado pelo +)
      */

      expr PLUS expr    {
        $$ = new_binop('+', $1, $3);
        printf("Expr processada: %d + %d = %d\n", $1, $3, $$);
    }
    | expr MINUS expr   {
        $$ = new_binop('-', $1, $3);
        printf("Expr processada: %d - %d = %d\n", $1, $3, $$);
    }
    | expr TIMES expr   {
        $$ = new_binop('*', $1, $3);
        printf("Expr processada: %d * %d = %d\n", $1, $3, $$);
    }
    | expr DIVIDE expr  {
        if ($3 == 0) {
            printf("Erro: divisao por zero em %d / %d\n", $1, $3);
            $$ = 0;
        } else {
            $$ = new_binop('/', $1, $3);
            printf("Expr processada: %d / %d = %d\n", $1, $3, $$);
        }
    }
    | LPAREN expr RPAREN{
        $$ = $2;
        printf("Expr processada: (%d) = %d\n", $2, $$);
    }
    | NUM               {
        $$ = new_num($1);
        printf("Numero processado: %d\n", $$);
    }
    | ID                {
        printf("Identificador processado: %s (valor temporario = 0)\n", $1);
        free($1);
        $$ = new_var($1);
    }
    
    /* IMPLEMENTAÇÃO TEMPORÁRIA ANTES DA ÁRVORE SINTÁTICA*/
    | STRING_LITERAL    {
        printf("String processada: %s\n", $1);
        $$ = new_string_literal($1);
        free($1);
    }
    | CHAR_LITERAL      {
        printf("Char processado: %s\n", $1);
        $$ = new_char_literal($1);
        free($1);
    }

    ;

%%

int main(void) {
    // yyparse retorna 0 se a análise foi bem sucedida
    int parse_result = yyparse();
    if (parse_result == 0) {
        printf("Análise sintática concluída com sucesso!\n\n");
        printf("--- Árvore Sintática Abstrata (AST) ---\n");
        
        // Se a raiz foi preenchida, imprime a árvore começando do nível 0 de indentação
        if (root != NULL) {
            print_ast(root, 0);
            
            // Depois de usar a árvore, libere a memória para evitar memory leak
            free_ast(root); 
        } else {
            printf("A árvore está vazia.\n");
        }
    } else {
        printf("Falha na análise sintática.\n");
    }

    if (lexical_errors > 0 || syntax_errors > 0) {
        fprintf(stderr, "Finalizado com %d erro(s) lexico(s) e %d erro(s) sintatico(s).\n",
                lexical_errors, syntax_errors);
    }

    return parse_result;
}

void yyerror(const char *s) {
    syntax_errors++;
    fprintf(stderr, "Erro sintatico na linha %d: %s (proximo token: '%s')\n",
            yylineno, s, (yytext && yytext[0] != '\0') ? yytext : "EOF");
}
