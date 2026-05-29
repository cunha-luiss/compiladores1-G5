#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "symtab.h"
#include "eval.h"

// Função que percorre a árvore e avalia
double eval_ast(ASTNode *node) {
    if (!node) return 0.0;

    switch (node->type) {
        
        case NODE_NUM:
            return node->num_val;

        case NODE_VAR: {
            const Symbol *sym = symtab_lookup(node->var_name);
            if (sym && sym->val_type == VAL_NUM) {
                return sym->num_val;
            } else if (sym && sym->val_type == VAL_NONE) {
                printf("Variavel %s nao possui valor atribuido.\n", node->var_name);
                return 0.0;
            } else if (!sym) {
                printf("Variavel %s nao declarada.\n", node->var_name);
                return 0.0;
            }
            return 0.0; 
        }

        case NODE_BLOCK: {
            eval_ast(node->block.statement); 
            eval_ast(node->block.next);      
            return 0.0; 
        }

        case NODE_ASSIGN: {
            double result = 0.0;
            if (node->assign.value) {
                result = eval_ast(node->assign.value);
                symtab_set_value_num(node->assign.name, result);
                printf("Execução => Atribuido valor %.2f para a variavel %s\n", result, node->assign.name);
            }
            return result;
        }

        case NODE_BINOP: {
            double left = eval_ast(node->binop.left);
            double right = eval_ast(node->binop.right);
            double result = 0.0;

            switch (node->binop.op) {
                case OP_ADD: result = left + right; break;
                case OP_SUB: result = left - right; break;
                case OP_MUL: result = left * right; break;
                case OP_DIV: 
                    if (right == 0) {
                        printf("Erro de execução: divisao por zero.\n");
                        exit(1);
                    }
                    result = left / right;
                    break;
                case OP_LT:  result = left < right; break;
                case OP_GT:  result = left > right; break;
                case OP_EQ:  result = left == right; break;
                case OP_NEQ: result = left != right; break;
                case OP_LE:  result = left <= right; break;
                case OP_GE:  result = left >= right; break;
                case OP_AND: result = left && right; break;
                case OP_OR:  result = left || right; break;
            }

            printf("Executado: %.2f %s %.2f => %.2f\n", left, operator_to_string(node->binop.op), right, result);            return result;
        }

        case NODE_IF: {
            double cond = eval_ast(node->if_node.cond);
            if (cond != 0) {
                eval_ast(node->if_node.then_branch);
            } else if (node->if_node.else_branch) {
                eval_ast(node->if_node.else_branch);
            }
            return 0.0;
        }

        case NODE_WHILE: {
            while (eval_ast(node->while_node.cond) != 0) {
                eval_ast(node->while_node.body);
            }
            return 0.0;
        }
        
        // Trate TYPE_STRING e outros que criar, por ora ignora:
        case NODE_STRING:
        case NODE_CHAR:
            return 0.0;

        default:
            printf("No de tipo desconhecido na execucao.\n");
            break;
    }
    
    return 0.0;
}