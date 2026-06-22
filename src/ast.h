#ifndef AST_H
#define AST_H

#include "types.h"

typedef enum {
    NODE_NUM,
    NODE_VAR,
    NODE_BINOP,
    NODE_IF,
    NODE_WHILE,
    NODE_DECL,
    NODE_ASSIGN,
    NODE_STRING,
    NODE_BLOCK,
    NODE_SCOPE,
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
    int line;

    union {
        double num_val;
        char *var_name;
        char *str_val;

        struct {
            OperatorType op;
            struct ASTNode *left;
            struct ASTNode *right;
        } binop;

        struct {
            struct ASTNode *cond;
            struct ASTNode *then_branch;
            struct ASTNode *else_branch;
        } if_node;

        struct {
            struct ASTNode *cond;
            struct ASTNode *body;
        } while_node;

        struct {
            struct ASTNode *statement;
            struct ASTNode *next;
        } block;

        struct {
            char *name;
            SymbolType declared_type;
            struct ASTNode *value;
        } decl;

        struct {
            char *name;
            struct ASTNode *value;
        } assign;

        struct {
            struct ASTNode *body;
        } scope;
    };
} ASTNode;

ASTNode *new_num(double val);
ASTNode *new_var(char *name, int line);
ASTNode *new_binop(OperatorType op, ASTNode *left, ASTNode *right);
ASTNode *new_if(ASTNode *cond, ASTNode *then_branch, ASTNode *else_branch);
ASTNode *new_while(ASTNode *cond, ASTNode *body);
ASTNode *new_block(ASTNode *statement, ASTNode *next);
ASTNode *append_block(ASTNode *block, ASTNode *statement);
ASTNode *new_decl(char *name, SymbolType type, ASTNode *value, int line);
ASTNode *new_assign(char *name, ASTNode *value, int line);
ASTNode *new_scope(ASTNode *body, int line);
ASTNode *new_string_literal(char *str);
ASTNode *new_char_literal(char *ch);

void print_ast(ASTNode *node, int indent);
void free_ast(ASTNode *node);
const char *operator_to_string(OperatorType op);

#endif
