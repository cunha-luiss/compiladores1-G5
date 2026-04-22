#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

// AUXILIAR


static ASTNode *alloc_node() {
    ASTNode *n = malloc(sizeof(ASTNode));
    if (!n) {
        perror("malloc failed");
        exit(1);
    }
    return n;
}

static void print_indent(int indent) {
    for (int i = 0; i < indent; i++)
        printf("  ");
}


// CONSTRUTORES


ASTNode *new_num(double val) {
    ASTNode *n = alloc_node();
    n->type = NODE_NUM;
    n->num_val = val;
    return n;
}

ASTNode *new_var(char *name) {
    ASTNode *n = alloc_node();
    n->type = NODE_VAR;
    n->var_name = strdup(name);
    return n;
}

ASTNode *new_binop(char op, ASTNode *l, ASTNode *r) {
    ASTNode *n = alloc_node();
    n->type = NODE_BINOP;
    n->binop.op = op;
    n->binop.left = l;
    n->binop.right = r;
    return n;
}

ASTNode *new_if(ASTNode *cond, ASTNode *then, ASTNode *els) {
    ASTNode *n = alloc_node();
    n->type = NODE_IF;
    n->if_node.cond = cond;
    n->if_node.then_branch = then;
    n->if_node.else_branch = els;
    return n;
}

ASTNode *new_assign(char *name, ASTNode *val) {
    ASTNode *n = alloc_node();
    n->type = NODE_ASSIGN;
    n->assign.name = strdup(name);
    n->assign.value = val;
    return n;
}


// PRINT DA ÁRVORE


void print_ast(ASTNode *node, int indent) {
    if (!node) return;

    print_indent(indent);

    switch (node->type) {

        case NODE_NUM:
            printf("NUM(%.2f)\n", node->num_val);
            break;

        case NODE_VAR:
            printf("VAR(%s)\n", node->var_name);
            break;

        case NODE_BINOP:
            printf("BINOP(%c)\n", node->binop.op);

            print_indent(indent + 1);
            printf("LEFT:\n");
            print_ast(node->binop.left, indent + 2);

            print_indent(indent + 1);
            printf("RIGHT:\n");
            print_ast(node->binop.right, indent + 2);
            break;

        case NODE_IF:
            printf("IF\n");

            print_indent(indent + 1);
            printf("COND:\n");
            print_ast(node->if_node.cond, indent + 2);

            print_indent(indent + 1);
            printf("THEN:\n");
            print_ast(node->if_node.then_branch, indent + 2);

            if (node->if_node.else_branch) {
                print_indent(indent + 1);
                printf("ELSE:\n");
                print_ast(node->if_node.else_branch, indent + 2);
            }
            break;

        case NODE_ASSIGN:
            printf("ASSIGN(%s)\n", node->assign.name);

            print_indent(indent + 1);
            printf("VALUE:\n");
            print_ast(node->assign.value, indent + 2);
            break;
    }
}


// FREE (EVITAR MEMORY LEAK)


void free_ast(ASTNode *node) {
    if (!node) return;

    switch (node->type) {

        case NODE_NUM:
            break;

        case NODE_VAR:
            free(node->var_name);
            break;

        case NODE_BINOP:
            free_ast(node->binop.left);
            free_ast(node->binop.right);
            break;

        case NODE_IF:
            free_ast(node->if_node.cond);
            free_ast(node->if_node.then_branch);
            free_ast(node->if_node.else_branch);
            break;

        case NODE_ASSIGN:
            free(node->assign.name);
            free_ast(node->assign.value);
            break;
    }

    free(node);
}