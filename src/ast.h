#pragma once
#include <stdlib.h>

typedef enum {
    NODE_NUM,
    NODE_VAR,
    NODE_BINOP,
    NODE_IF,
    NODE_WHILE,
    NODE_ASSIGN,
    NODE_STRING,
    NODE_BLOCK,
    NODE_CHAR
} NodeType;

typedef enum {
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_LT,
    OP_GT,
    OP_LE,
    OP_GE,
    OP_EQ,
    OP_NEQ,
    OP_AND,
    OP_OR
} OperatorType;

typedef struct ASTNode {
    NodeType type;
    union {
        double num_val;         // número
        char  *var_name;        // variável
        char  *str_val;         // string

        struct {                // operação binária
            OperatorType op;
            struct ASTNode *left;
            struct ASTNode *right;
        } binop;

        struct {                // if
            struct ASTNode *cond;
            struct ASTNode *then_branch;
            struct ASTNode *else_branch;
        } if_node;

        struct {                // while
            struct ASTNode *cond;
            struct ASTNode *body;
        } while_node;

        struct {               // block 
            struct ASTNode *statement;
            struct ASTNode *next;
        } block;

        struct {                // atribuição
            char *name;
            struct ASTNode *value;
        } assign;
    };
} ASTNode;

// construtores
ASTNode *new_num(double val);
ASTNode *new_var(char *name);
ASTNode *new_binop(OperatorType op, ASTNode *l, ASTNode *r);
ASTNode *new_if(ASTNode *cond, ASTNode *then, ASTNode *els);
ASTNode *new_while(ASTNode *cond, ASTNode *body);
ASTNode *new_block(ASTNode *statement, ASTNode *next);
ASTNode *append_block(ASTNode *block, ASTNode *statement);
ASTNode *new_assign(char *name, ASTNode *val);
ASTNode *new_string_literal(char *str);
ASTNode *new_char_literal(char *ch);

// utilidades
void print_ast(ASTNode *node, int indent);
void free_ast(ASTNode *node);
const char *operator_to_string(OperatorType op);