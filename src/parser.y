%{
#include <stdio.h>
#include <stdlib.h>

#include "ast.h"
#include "eval.h"
#include "semantic.h"
#include "symtab.h"

int yylex(void);
void yyerror(const char *message);

extern int yylineno;
extern char *yytext;
extern int lexical_errors;

static int syntax_errors = 0;
ASTNode *root = NULL;
%}

%define parse.error verbose
%locations

%code requires {
    #include "types.h"
    typedef struct ASTNode ASTNode;
}

%union {
    int intValue;
    float floatValue;
    char *str;
    SymbolType symbol_type;
    ASTNode *node;
}

%token <intValue> NUM
%token <floatValue> NUMFLOAT
%token <str> ID STRING_LITERAL CHAR_LITERAL
%token <symbol_type> TYPE_SPECIFIER BOOL_TYPE DOUBLE_TYPE KW_BOOL

%token KW_LONG KW_SIZE TYPE_MODIFIER KW_TYPE_MODIFIER
%token KW_DECIMAL32 KW_DECIMAL64 KW_DECIMAL128 KW_COMPLEX KW_IMAGINARY
%token KW_TYPE_DECLARATION KW_DECLARATION_OF_A_COMPOUND_TYPE
%token KW_DECLARATION_OF_A_UNION_TYPE ENUMERATION_TYPE
%token KW_TYPE_OF_VARIABLE_OR_PARAMETER_OF_FUNCTION_OR_RETURN_VALUE

%token IF_STATEMENT ELSE_STATEMENT KW_WHILE DO_LOOP LOOP
%token SWITCH_STATEMENT KW_SWITCH DEFAULT_STATEMENT
%token CONTINUE_STATEMENT DECLARATION STATEMENT RETURN_STATEMENT

%token KW_STATIC STORAGE_CLASS_SPECIFIER AUTOMATIC_DURATION_STORAGE_CLASS_SPECIFIER
%token INLINE_FUNCTION_SPECIFIER TYPE_QUALIFIER KW_TYPE_QUALIFIER CONST_LITERAL SPECIFIER
%token THREAD_STORAGE KW_THREAD_STORAGE_CLASS_SPECIFIER AUTO_TYPE_INFERENCE

%token KW_ALIGNAS KW_ALIGNOF KW_ALIGNMENT KW_ATOMIC
%token KW_STATIC_ASSERT STATIC_ASSERT_DECLARATION KW_GENERIC KW_NORETURN

%token TRUE_LITERAL FALSE_LITERAL POINTER_CONSTANT
%token OPERATOR KW_OPERATOR KW_OPERATOR_THAT_REMOVES_QUALIFIERS

%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN
%token NEWLINE COMPARATION EQUAL SEMICOLON LBRACE RBRACE
%token LESS_EQUAL GREATER_EQUAL NOT_EQUAL LOGICAL_AND LOGICAL_OR
%token LESS GREATER

%left LOGICAL_OR
%left LOGICAL_AND
%left COMPARATION NOT_EQUAL
%left LESS LESS_EQUAL GREATER GREATER_EQUAL
%left PLUS MINUS
%left TIMES DIVIDE
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE_STATEMENT

%type <node> program stmt stmt_list expr
%type <symbol_type> type_specifier

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
    : %empty
        {
            $$ = NULL;
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
            $$ = new_scope($2, @1.first_line);
        }
    | type_specifier ID EQUAL expr SEMICOLON
        {
            $$ = new_decl($2, $1, $4, @2.first_line);
        }
    | type_specifier ID SEMICOLON
        {
            $$ = new_decl($2, $1, NULL, @2.first_line);
        }
    | ID EQUAL expr SEMICOLON
        {
            $$ = new_assign($1, $3, @1.first_line);
        }
    | expr SEMICOLON
        {
            $$ = $1;
        }
    ;

type_specifier
    : TYPE_SPECIFIER
        {
            $$ = $1;
        }
    | BOOL_TYPE
        {
            $$ = $1;
        }
    | DOUBLE_TYPE
        {
            $$ = $1;
        }
    | KW_BOOL
        {
            $$ = $1;
        }
    ;

expr
    : expr PLUS expr
        {
            $$ = new_binop(OP_ADD, $1, $3);
        }
    | expr MINUS expr
        {
            $$ = new_binop(OP_SUB, $1, $3);
        }
    | expr TIMES expr
        {
            $$ = new_binop(OP_MUL, $1, $3);
        }
    | expr DIVIDE expr
        {
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
            $$ = $2;
        }
    | NUM
        {
            $$ = new_num($1);
        }
    | NUMFLOAT
        {
            $$ = new_num($1);
        }
    | TRUE_LITERAL
        {
            $$ = new_num(1);
        }
    | FALSE_LITERAL
        {
            $$ = new_num(0);
        }
    | ID
        {
            $$ = new_var($1, @1.first_line);
        }
    | STRING_LITERAL
        {
            $$ = new_string_literal($1);
        }
    | CHAR_LITERAL
        {
            $$ = new_char_literal($1);
        }
    ;

%%

int main(void) {
    int parse_result;
    int semantic_errors = 0;
    int exit_code = EXIT_SUCCESS;

    symtab_init();
    parse_result = yyparse();

    if (parse_result == 0 && lexical_errors == 0 && syntax_errors == 0) {
        printf("Analise sintatica concluida com sucesso.\n");

        if (root) {
            printf("\n--- Arvore Sintatica Abstrata (AST) ---\n");
            print_ast(root, 0);

            semantic_errors = analyze_ast(root);
            if (semantic_errors == 0) {
                printf("\nAnalise semantica concluida sem erros.\n");
                symtab_reset();
                printf("\n--- Execucao ---\n");
                eval_ast(root);
                symtab_dump();
            } else {
                fprintf(stderr,
                        "Execucao abortada: %d erro(s) semantico(s).\n",
                        semantic_errors);
                symtab_dump();
                exit_code = EXIT_FAILURE;
            }
        }
    } else {
        fprintf(stderr, "Falha na analise lexica ou sintatica.\n");
        exit_code = EXIT_FAILURE;
    }

    if (lexical_errors > 0 || syntax_errors > 0) {
        fprintf(stderr,
                "Finalizado com %d erro(s) lexico(s) e %d erro(s) sintatico(s).\n",
                lexical_errors,
                syntax_errors);
    }

    free_ast(root);
    symtab_free();

    if (parse_result != 0 || semantic_errors > 0) {
        return EXIT_FAILURE;
    }

    return exit_code;
}

void yyerror(const char *message) {
    syntax_errors++;
    fprintf(stderr,
            "Erro sintatico na linha %d: %s (proximo token: '%s')\n",
            yylloc.first_line > 0 ? yylloc.first_line : yylineno,
            message,
            (yytext && yytext[0] != '\0') ? yytext : "EOF");
}
