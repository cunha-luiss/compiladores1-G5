%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ast.h"
#include "symtab.h"
#include "eval.h"
#include "semantic.h"

/* Declarações para evitar avisos de função implícita 

Rodar com:

gcc -o parser parser.tab.c lex.yy.c ast.c symtab.c -lfl

*/

int yylex(void);
// usado para pedir próximo token
void yyerror(const char *s);      // usado quando há um erro

extern int yylineno;
extern char *yytext;
extern int lexical_errors;

static int syntax_errors = 0;
extern int debug_mode;

/* Raiz da AST */
ASTNode *root = NULL;
%}

%define parse.error detailed

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE_STATEMENT

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

/* Tokens com valor semântico */
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
%token CONTINUE_STATEMENT DECLARATION STATEMENT RETURN_STATEMENT KW_PRINTF

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
%token LESS GREATER

/* Precedência */
%left LOGICAL_OR
%left LOGICAL_AND
%left COMPARATION NOT_EQUAL
%left LESS LESS_EQUAL GREATER GREATER_EQUAL
%left PLUS MINUS
%left TIMES DIVIDE
%right UMINUS

/* Tipos dos não-terminais */
%type <node> expr
%type <node> program stmt stmt_list

%start program

%%

program
    : stmt_list
        {
            root = $1;
            $$ = $1;
        }
    ;

stmt_list
    : stmt
        {
            $$ = new_block($1, NULL);
        }

    | stmt_list stmt
        {
            $$ = append_block($1, $2);
        }
    ;

stmt
    : IF_STATEMENT LPAREN expr RPAREN stmt ELSE_STATEMENT stmt
        {
            $$ = new_if($3, $5, $7);
        }


    | IF_STATEMENT LPAREN expr RPAREN stmt %prec LOWER_THAN_ELSE

        {
            $$ = new_if($3, $5, NULL);
        }

    | KW_WHILE LPAREN expr RPAREN stmt
        {
            $$ = new_while($3, $5);
        }

    | LBRACE stmt_list RBRACE
        {
            $$ = $2;
        }

    | TYPE_SPECIFIER ID EQUAL expr SEMICOLON
        {
            /* A tabela de símbolos não é mais populada aqui */
            $$ = new_assign($2, $4);
        }

    | TYPE_SPECIFIER ID SEMICOLON
        {
            $$ = new_assign($2, NULL);
        }

    | ID EQUAL expr SEMICOLON
        {
            /* Validações semânticas removidas do parser */
            $$ = new_assign($1, $3);
        }

    | KW_PRINTF LPAREN expr RPAREN SEMICOLON
        {
            $$ = new_printf($3);
        }

    | expr SEMICOLON
        {
            $$ = $1;
        }

    | error SEMICOLON
        {
            fprintf(stderr,
                    "Erro sintatico recuperado na linha %d\n",
                    yylineno);

            yyerrok;
            $$ = NULL;
        }

        | LBRACE error RBRACE
        {
            fprintf(stderr,
                    "Erro recuperado dentro de bloco na linha %d\n",
                    yylineno);

            yyerrok;
            $$ = NULL;
        }
    ;

expr
    : expr PLUS expr
        {
            if (debug_mode) printf("Expr PLUS processada\n");
            $$ = new_binop(OP_ADD, $1, $3);
        }

    | expr MINUS expr
        {
            if (debug_mode) printf("Expr MINUS processada\n");
            $$ = new_binop(OP_SUB, $1, $3);
        }

    | expr TIMES expr
        {
            if (debug_mode) printf("Expr TIMES processada\n");
            $$ = new_binop(OP_MUL, $1, $3);
        }

    | expr DIVIDE expr
        {
            if (debug_mode) printf("Expr DIVIDE processada\n");
            $$ = new_binop(OP_DIV, $1, $3);
        }

    | expr LESS expr
        {
            $$ = new_binop(OP_LT, $1, $3);
        }

    | expr GREATER expr
        {
            $$ = new_binop(OP_GT, $1, $3);
        }

    | expr LESS_EQUAL expr
        {
            $$ = new_binop(OP_LE, $1, $3);
        }

    | expr GREATER_EQUAL expr
        {
            $$ = new_binop(OP_GE, $1, $3);
        }

    | expr COMPARATION expr
        {
            $$ = new_binop(OP_EQ, $1, $3);
        }

    | expr NOT_EQUAL expr
        {
            $$ = new_binop(OP_NEQ, $1, $3);
        }

    | expr LOGICAL_AND expr
        {
            $$ = new_binop(OP_AND, $1, $3);
        }

    | expr LOGICAL_OR expr
        {
            $$ = new_binop(OP_OR, $1, $3);
        }

    | LPAREN expr RPAREN
        {
            if (debug_mode) printf("Expr entre parenteses processada\n");
            $$ = $2;
        }

    | NUM
        {
            if (debug_mode) printf("Numero processado: %d\n", $1);
            $$ = new_num($1);
        }

    | ID
        {
            if (debug_mode) printf("Identificador processado: %s\n", $1);
            /* Uso da variável delegado para a análise semântica */
            $$ = new_var($1);
        }

    | STRING_LITERAL
        {
            if (debug_mode) printf("String processada: %s\n", $1);
            $$ = new_string_literal($1);
        }

    | CHAR_LITERAL
        {
            if (debug_mode) printf("Char processado: %s\n", $1);
            $$ = new_char_literal($1);
        }
    
    | NUMFLOAT
        {
            $$ = new_num($1);
        }
    
    | MINUS expr %prec UMINUS
        {
            $$ = new_binop(
                    OP_SUB,
                    new_num(0),
                    $2
                );
        }
    
    | error
        {
            fprintf(stderr,
                    "Expressao invalida na linha %d\n",
                    yylineno);

            yyerrok;

            $$ = new_num(0);
        }
    ;

%%

int debug_mode = 0;

int main(int argc, char **argv) {
    int opcao = 1;
    int is_test = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--test") == 0) {
            is_test = 1;
        }
    }

    if (!is_test) {
        FILE *tty = fopen("/dev/tty", "r+");
        if (!tty) {
            tty = fopen("CON", "r+");
        }

        if (tty) {
            fprintf(tty, "===========================================\n");
            fprintf(tty, "Escolha o modo de execucao:\n");
            fprintf(tty, "1 - Apenas executar\n");
            fprintf(tty, "2 - Executar com passo a passo (debugging)\n");
            fprintf(tty, "Opcao: ");
            if (fscanf(tty, "%d", &opcao) != 1) {
                opcao = 1;
            }
            fclose(tty);
        } else {
            printf("===========================================\n");
            printf("Escolha o modo de execucao:\n");
            printf("1 - Apenas executar\n");
            printf("2 - Executar com passo a passo (debugging)\n");
            printf("Opcao: ");
            if (scanf("%d", &opcao) != 1) {
                opcao = 1;
            }
            int c;
            while ((c = getchar()) != '\n' && c != EOF);
        }
    }

    if (opcao == 2) {
        debug_mode = 1;
    }

    symtab_init();
    int parse_result = yyparse();
    if (parse_result == 0) {
        if (debug_mode) printf("Análise sintática concluída com sucesso!\n\n");
        if (debug_mode) printf("--- Árvore Sintática Abstrata (AST) ---\n");

        if (root != NULL) {
            if (debug_mode) print_ast(root, 0);
            
            if (debug_mode) printf("\n--- Executando Análise Semântica (1ª Passada) ---\n");
            int semantic_errors = analyze_ast(root);
            
            if (semantic_errors == 0) {
                if (debug_mode) printf("\nAnálise semântica concluída sem erros! Iniciando execução (2ª Passada):\n");
                eval_ast(root);
            } else {
                fprintf(stderr, "\nExecução abortada: detectado(s) %d erro(s) semântico(s).\n", semantic_errors);
            }
            
            free_ast(root);

        } else {
            if (debug_mode) printf("A árvore está vazia.\n");
        }

        if (debug_mode) symtab_dump();

    } else {
        if (debug_mode) printf("Falha na análise sintática.\n");
    }

    if (lexical_errors > 0 || syntax_errors > 0) {
        fprintf(stderr,
                "Finalizado com %d erro(s) lexico(s) e %d erro(s) sintatico(s).\n",
                lexical_errors,
                syntax_errors);
    }

    symtab_free();
    return parse_result;
}

void yyerror(const char *s)
{
    syntax_errors++;
    fprintf(stderr,
        "Erro sintatico na linha %d: %s (proximo token: '%s')\n",
        yylineno, s, (yytext && yytext[0] != '\0') ? yytext : "EOF");

    if (yytext && yytext[0] != '\0')
    {
        fprintf(stderr,
                "[Linha %d] %s. Token encontrado: '%s'\n",
                yylineno,
                s,
                yytext);
    }
    else
    {
        fprintf(stderr,
                "[Linha %d] Fim de arquivo inesperado.\n",
                yylineno);
    }

}