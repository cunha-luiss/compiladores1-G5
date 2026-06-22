#include "eval.h"
#include "symtab.h"

#include <stdio.h>
#include <stdlib.h>

static double assign_value(const char *name, ASTNode *value, int line) {
    double result;

    if (!value) {
        return 0.0;
    }

    symtab_record_assignment(name, line);

    if (value->type == NODE_STRING || value->type == NODE_CHAR) {
        symtab_set_value_str(name, value->str_val);
        printf("Atribuido %s para a variavel %s\n", value->str_val, name);
        return 0.0;
    }

    if (value->type == NODE_VAR) {
        const Symbol *source = symtab_lookup(value->var_name);

        if (source && source->val_type == VAL_STR) {
            symtab_record_use(value->var_name, value->line);
            symtab_set_value_str(name, source->str_val);
            printf("Atribuido %s para a variavel %s\n", source->str_val, name);
            return 0.0;
        }
    }

    result = eval_ast(value);
    symtab_set_value_num(name, result);
    printf("Atribuido valor %.2f para a variavel %s\n", result, name);
    return result;
}

double eval_ast(ASTNode *node) {
    if (!node) {
        return 0.0;
    }

    switch (node->type) {
        case NODE_NUM:
            return node->num_val;

        case NODE_VAR: {
            const Symbol *symbol = symtab_lookup(node->var_name);

            if (!symbol) {
                fprintf(stderr,
                        "Erro interno: variavel '%s' ausente durante execucao.\n",
                        node->var_name);
                return 0.0;
            }

            symtab_record_use(node->var_name, node->line);
            if (symbol->val_type == VAL_NUM) {
                return symbol->num_val;
            }

            if (symbol->val_type == VAL_NONE) {
                fprintf(stderr,
                        "Variavel '%s' nao possui valor atribuido.\n",
                        node->var_name);
            }
            return 0.0;
        }

        case NODE_BINOP: {
            double left = eval_ast(node->binop.left);
            double right = eval_ast(node->binop.right);

            switch (node->binop.op) {
                case OP_ADD: return left + right;
                case OP_SUB: return left - right;
                case OP_MUL: return left * right;
                case OP_DIV:
                    if (right == 0.0) {
                        fprintf(stderr, "Erro de execucao: divisao por zero.\n");
                        exit(EXIT_FAILURE);
                    }
                    return left / right;
                case OP_LT: return left < right;
                case OP_GT: return left > right;
                case OP_LE: return left <= right;
                case OP_GE: return left >= right;
                case OP_EQ: return left == right;
                case OP_NEQ: return left != right;
                case OP_AND: return left && right;
                case OP_OR: return left || right;
            }
            return 0.0;
        }

        case NODE_DECL:
            if (!symtab_insert(node->decl.name,
                               node->decl.declared_type,
                               node->line)) {
                fprintf(stderr,
                        "Erro interno: redeclaracao de '%s' durante execucao.\n",
                        node->decl.name);
                return 0.0;
            }
            return assign_value(node->decl.name, node->decl.value, node->line);

        case NODE_ASSIGN:
            return assign_value(
                node->assign.name, node->assign.value, node->line);

        case NODE_IF:
            if (eval_ast(node->if_node.cond) != 0.0) {
                eval_ast(node->if_node.then_branch);
            } else {
                eval_ast(node->if_node.else_branch);
            }
            return 0.0;

        case NODE_WHILE:
            while (eval_ast(node->while_node.cond) != 0.0) {
                eval_ast(node->while_node.body);
            }
            return 0.0;

        case NODE_BLOCK:
            eval_ast(node->block.statement);
            eval_ast(node->block.next);
            return 0.0;

        case NODE_SCOPE:
            symtab_enter_scope();
            eval_ast(node->scope.body);
            symtab_leave_scope();
            return 0.0;

        case NODE_STRING:
        case NODE_CHAR:
            return 0.0;
    }

    return 0.0;
}
