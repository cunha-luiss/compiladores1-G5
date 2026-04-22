#pragma once
#include <stdlib.h>

typedef enum {
    NODE_NUM,
    NODE_VAR,
    NODE_BINOP,
    NODE_IF,
    NODE_ASSIGN,
} NodeType;

typedef struct ASTNode {
    NodeType type;
    union {
        double num_val;         // número
        char  *var_name;        // variável

        struct {                // operação binária
            char op;
            struct ASTNode *left;
            struct ASTNode *right;
        } binop;

        struct {                // if
            struct ASTNode *cond;
            struct ASTNode *then_branch;
            struct ASTNode *else_branch;
        } if_node;

        struct {                // atribuição
            char *name;
            struct ASTNode *value;
        } assign;
    };
} ASTNode;

// construtores
ASTNode *new_num(double val);
ASTNode *new_var(char *name);
ASTNode *new_binop(char op, ASTNode *l, ASTNode *r);
ASTNode *new_if(ASTNode *cond, ASTNode *then, ASTNode *els);
ASTNode *new_assign(char *name, ASTNode *val);

// utilidades
void print_ast(ASTNode *node, int indent);
void free_ast(ASTNode *node);