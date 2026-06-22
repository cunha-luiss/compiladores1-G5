#include "ast.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static ASTNode *alloc_node(void) {
    ASTNode *node = calloc(1, sizeof(ASTNode));

    if (!node) {
        perror("calloc failed");
        exit(EXIT_FAILURE);
    }

    return node;
}

static void print_indent(int indent) {
    int i;

    for (i = 0; i < indent; i++) {
        printf("  ");
    }
}

const char *operator_to_string(OperatorType op) {
    switch (op) {
        case OP_ADD: return "+";
        case OP_SUB: return "-";
        case OP_MUL: return "*";
        case OP_DIV: return "/";
        case OP_LT: return "<";
        case OP_GT: return ">";
        case OP_LE: return "<=";
        case OP_GE: return ">=";
        case OP_EQ: return "==";
        case OP_NEQ: return "!=";
        case OP_AND: return "&&";
        case OP_OR: return "||";
    }

    return "?";
}

ASTNode *new_num(double val) {
    ASTNode *node = alloc_node();
    node->type = NODE_NUM;
    node->num_val = val;
    return node;
}

ASTNode *new_var(char *name, int line) {
    ASTNode *node = alloc_node();
    node->type = NODE_VAR;
    node->line = line;
    node->var_name = name;
    return node;
}

ASTNode *new_binop(OperatorType op, ASTNode *left, ASTNode *right) {
    ASTNode *node = alloc_node();
    node->type = NODE_BINOP;
    node->binop.op = op;
    node->binop.left = left;
    node->binop.right = right;
    return node;
}

ASTNode *new_if(ASTNode *cond, ASTNode *then_branch, ASTNode *else_branch) {
    ASTNode *node = alloc_node();
    node->type = NODE_IF;
    node->if_node.cond = cond;
    node->if_node.then_branch = then_branch;
    node->if_node.else_branch = else_branch;
    return node;
}

ASTNode *new_while(ASTNode *cond, ASTNode *body) {
    ASTNode *node = alloc_node();
    node->type = NODE_WHILE;
    node->while_node.cond = cond;
    node->while_node.body = body;
    return node;
}

ASTNode *new_block(ASTNode *statement, ASTNode *next) {
    ASTNode *node = alloc_node();
    node->type = NODE_BLOCK;
    node->block.statement = statement;
    node->block.next = next;
    return node;
}

ASTNode *append_block(ASTNode *block, ASTNode *statement) {
    ASTNode *tail;

    if (!block) {
        return new_block(statement, NULL);
    }

    tail = block;
    while (tail->type == NODE_BLOCK && tail->block.next) {
        tail = tail->block.next;
    }

    if (tail->type == NODE_BLOCK) {
        tail->block.next = new_block(statement, NULL);
    }

    return block;
}

ASTNode *new_decl(char *name, SymbolType type, ASTNode *value, int line) {
    ASTNode *node = alloc_node();
    node->type = NODE_DECL;
    node->line = line;
    node->decl.name = name;
    node->decl.declared_type = type;
    node->decl.value = value;
    return node;
}

ASTNode *new_assign(char *name, ASTNode *value, int line) {
    ASTNode *node = alloc_node();
    node->type = NODE_ASSIGN;
    node->line = line;
    node->assign.name = name;
    node->assign.value = value;
    return node;
}

ASTNode *new_scope(ASTNode *body, int line) {
    ASTNode *node = alloc_node();
    node->type = NODE_SCOPE;
    node->line = line;
    node->scope.body = body;
    return node;
}

ASTNode *new_string_literal(char *str) {
    ASTNode *node = alloc_node();
    node->type = NODE_STRING;
    node->str_val = str;
    return node;
}

ASTNode *new_char_literal(char *ch) {
    ASTNode *node = alloc_node();
    node->type = NODE_CHAR;
    node->str_val = ch;
    return node;
}

void print_ast(ASTNode *node, int indent) {
    if (!node) {
        return;
    }

    print_indent(indent);

    switch (node->type) {
        case NODE_NUM:
            printf("NUM(%.2f)\n", node->num_val);
            break;

        case NODE_VAR:
            printf("VAR(%s, linha %d)\n", node->var_name, node->line);
            break;

        case NODE_BINOP:
            printf("BINOP(%s)\n", operator_to_string(node->binop.op));
            print_ast(node->binop.left, indent + 1);
            print_ast(node->binop.right, indent + 1);
            break;

        case NODE_IF:
            printf("IF\n");
            print_ast(node->if_node.cond, indent + 1);
            print_ast(node->if_node.then_branch, indent + 1);
            print_ast(node->if_node.else_branch, indent + 1);
            break;

        case NODE_WHILE:
            printf("WHILE\n");
            print_ast(node->while_node.cond, indent + 1);
            print_ast(node->while_node.body, indent + 1);
            break;

        case NODE_DECL:
            printf("DECL(%s, tipo %s, linha %d)\n",
                   node->decl.name,
                   symbol_type_to_string(node->decl.declared_type),
                   node->line);
            print_ast(node->decl.value, indent + 1);
            break;

        case NODE_ASSIGN:
            printf("ASSIGN(%s, linha %d)\n",
                   node->assign.name,
                   node->line);
            print_ast(node->assign.value, indent + 1);
            break;

        case NODE_STRING:
            printf("STRING(%s)\n", node->str_val);
            break;

        case NODE_CHAR:
            printf("CHAR(%s)\n", node->str_val);
            break;

        case NODE_BLOCK:
            printf("BLOCK\n");
            print_ast(node->block.statement, indent + 1);
            print_ast(node->block.next, indent + 1);
            break;

        case NODE_SCOPE:
            printf("SCOPE(linha %d)\n", node->line);
            print_ast(node->scope.body, indent + 1);
            break;
    }
}

void free_ast(ASTNode *node) {
    if (!node) {
        return;
    }

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

        case NODE_WHILE:
            free_ast(node->while_node.cond);
            free_ast(node->while_node.body);
            break;

        case NODE_DECL:
            free(node->decl.name);
            free_ast(node->decl.value);
            break;

        case NODE_ASSIGN:
            free(node->assign.name);
            free_ast(node->assign.value);
            break;

        case NODE_STRING:
        case NODE_CHAR:
            free(node->str_val);
            break;

        case NODE_BLOCK:
            free_ast(node->block.statement);
            free_ast(node->block.next);
            break;

        case NODE_SCOPE:
            free_ast(node->scope.body);
            break;
    }

    free(node);
}
