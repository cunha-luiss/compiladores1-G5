#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "symtab.h"

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

static int is_numeric_constant(ASTNode *node) {
    return node && node->type == NODE_NUM;
}

static double fold_binop(OperatorType op, double left, double right, int *can_fold) {
    *can_fold = 1;

    switch (op) {
        case OP_ADD: return left + right;
        case OP_SUB: return left - right;
        case OP_MUL: return left * right;
        case OP_DIV:
            if (right == 0) {
                *can_fold = 0;
                return 0.0;
            }
            return left / right;
        case OP_LT:  return left < right;
        case OP_GT:  return left > right;
        case OP_LE:  return left <= right;
        case OP_GE:  return left >= right;
        case OP_EQ:  return left == right;
        case OP_NEQ: return left != right;
        case OP_AND: return left != 0 && right != 0;
        case OP_OR:  return left != 0 || right != 0;
    }

    *can_fold = 0;
    return 0.0;
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
    n->var_name = name; 
    return n;
}

ASTNode *new_binop(OperatorType op, ASTNode *l, ASTNode *r) {
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

ASTNode *new_while(ASTNode *cond, ASTNode *body) {
    ASTNode *n = alloc_node();
    n->type = NODE_WHILE;

    n->while_node.cond = cond;
    n->while_node.body = body;

    return n;
}

ASTNode *new_block(ASTNode *statement, ASTNode *next) {
    ASTNode *n = alloc_node();

    n->type = NODE_BLOCK;

    n->block.statement = statement;
    n->block.next = next;

    return n;
}

ASTNode *append_block(ASTNode *block, ASTNode *statement) {
    if (!block) {
        return new_block(statement, NULL);
    }

    ASTNode *tail = block;

    while (tail->type == NODE_BLOCK && tail->block.next != NULL) {
        tail = tail->block.next;
    }

    if (tail->type == NODE_BLOCK) {
        tail->block.next = new_block(statement, NULL);
    }

    return block;
}

ASTNode *new_assign(char *name, ASTNode *val) {
    ASTNode *n = alloc_node();
    n->type = NODE_ASSIGN;
    n->assign.name = name; 
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
            printf("BINOP(%s)\n", operator_to_string(node->binop.op));

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

        case NODE_WHILE:
            printf("WHILE\n");

            print_indent(indent + 1);
            printf("COND:\n");
            print_ast(node->while_node.cond, indent + 2);

            print_indent(indent + 1);
            printf("BODY:\n");
            print_ast(node->while_node.body, indent + 2);

            break;

        case NODE_BLOCK:
            printf("BLOCK\n");

            print_indent(indent + 1);
            printf("STATEMENT:\n");
            print_ast(node->block.statement, indent + 2);

            if (node->block.next) {
                print_indent(indent + 1);
                printf("NEXT:\n");
                print_ast(node->block.next, indent + 2);
            }

            break;

        case NODE_STRING:
            printf("STRING(%s)\n", node->str_val);
            break;

        case NODE_CHAR:
            printf("CHAR(%s)\n", node->str_val);
            break;

        case NODE_ASSIGN:
            printf("ASSIGN(%s)\n", node->assign.name);

            print_indent(indent + 1);
            printf("VALUE:\n");
            print_ast(node->assign.value, indent + 2);
            break;
        
    }
}


ASTNode *optimize_ast(ASTNode *node) {
    if (!node) return NULL;

    switch (node->type) {
        case NODE_NUM:
        case NODE_VAR:
        case NODE_STRING:
        case NODE_CHAR:
            return node;

        case NODE_BINOP: {
            node->binop.left = optimize_ast(node->binop.left);
            node->binop.right = optimize_ast(node->binop.right);

            if (is_numeric_constant(node->binop.left) && is_numeric_constant(node->binop.right)) {
                int can_fold = 0;
                double result = fold_binop(
                    node->binop.op,
                    node->binop.left->num_val,
                    node->binop.right->num_val,
                    &can_fold
                );

                if (can_fold) {
                    free_ast(node->binop.left);
                    free_ast(node->binop.right);
                    node->type = NODE_NUM;
                    node->num_val = result;
                }
            }

            return node;
        }

        case NODE_IF: {
            node->if_node.cond = optimize_ast(node->if_node.cond);
            node->if_node.then_branch = optimize_ast(node->if_node.then_branch);
            node->if_node.else_branch = optimize_ast(node->if_node.else_branch);

            if (is_numeric_constant(node->if_node.cond)) {
                ASTNode *replacement = (node->if_node.cond->num_val != 0)
                                           ? node->if_node.then_branch
                                           : node->if_node.else_branch;
                ASTNode *discarded = (replacement == node->if_node.then_branch)
                                         ? node->if_node.else_branch
                                         : node->if_node.then_branch;

                free_ast(discarded);
                free(node->if_node.cond);
                free(node);
                return replacement;
            }

            return node;
        }

        case NODE_WHILE:
            node->while_node.cond = optimize_ast(node->while_node.cond);
            node->while_node.body = optimize_ast(node->while_node.body);

            if (is_numeric_constant(node->while_node.cond) && node->while_node.cond->num_val == 0) {
                free_ast(node->while_node.body);
                free(node->while_node.cond);
                free(node);
                return NULL;
            }

            return node;

        case NODE_ASSIGN:
            node->assign.value = optimize_ast(node->assign.value);
            return node;

        case NODE_BLOCK: {
            node->block.statement = optimize_ast(node->block.statement);
            node->block.next = optimize_ast(node->block.next);

            if (!node->block.statement) {
                ASTNode *next = node->block.next;
                free(node);
                return next;
            }

            return node;
        }
    }

    return node;
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

        case NODE_WHILE:
            free_ast(node->while_node.cond);
            free_ast(node->while_node.body);
            break;

        case NODE_BLOCK:
            free_ast(node->block.statement);
            free_ast(node->block.next);
            break;

        case NODE_STRING:
            free(node->str_val);
            break;

        case NODE_CHAR:
            free(node->str_val);
            break;

        case NODE_ASSIGN:
            free(node->assign.name);
            free_ast(node->assign.value);
            break;
        
    }

    free(node);
}

ASTNode *new_string_literal(char *str) {
    ASTNode *n = alloc_node();
    n->type = NODE_STRING;
    n->str_val = str;
    return n;
}

ASTNode *new_char_literal(char *ch) {
    ASTNode *n = alloc_node();
    n->type = NODE_CHAR;
    n->str_val = ch; // Ou criar uma variável específica na union
    return n;
}