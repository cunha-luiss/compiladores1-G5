#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "symtab.h"
#include "eval.h"

double eval_ast(ASTNode *node) {
    if (!node) return 0.0;

    switch (node->type) {
        
        case NODE_NUM:
            return node->num_val;

        case NODE_VAR: {
            // A análise semântica já garantiu que a variável existe e foi inicializada
            const Symbol *sym = symtab_lookup(node->var_name);
            if (sym && sym->val_type == VAL_NUM) {
                return sym->num_val;
            }
            return 0.0; 
        }

        case NODE_BLOCK: {
            // Executa a instrução atual do bloco e depois passa para a próxima
            eval_ast(node->block.statement); 
            eval_ast(node->block.next);      
            return 0.0; 
        }

        case NODE_ASSIGN: {
            double result = 0.0;
            if (node->assign.value) {
                
                // Caso 1: Atribuição de Strings ou Chars literais
                if (node->assign.value->type == NODE_STRING || node->assign.value->type == NODE_CHAR) {
                    symtab_set_value_str(node->assign.name, node->assign.value->str_val);
                    printf("Execucao => Atribuido string \"%s\" para a variavel %s\n", node->assign.value->str_val, node->assign.name);
                    return 0.0;
                } 
                
                // Caso 2: Cópia de String entre variáveis (ex: a = b, onde 'b' é string)
                else if (node->assign.value->type == NODE_VAR) {
                    const Symbol *sym = symtab_lookup(node->assign.value->var_name);
                    if (sym && sym->val_type == VAL_STR) {
                        symtab_set_value_str(node->assign.name, sym->str_val);
                        printf("Execucao => Atribuido string \"%s\" para a variavel %s\n", sym->str_val, node->assign.name);
                        return 0.0;
                    }
                }
                
                // Caso 3: Atribuição numérica padrão ou resultado de expressão matemática
                result = eval_ast(node->assign.value);
                symtab_set_value_num(node->assign.name, result);
                printf("Execucao => Atribuido valor %.2f para a variavel %s\n", result, node->assign.name);
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
                    // Divisão por zero ainda é um erro em tempo de execução (runtime error)
                    if (right == 0) {
                        fprintf(stderr, "Erro de execucao: divisao por zero.\n");
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

            printf("Executado: %.2f %s %.2f => %.2f\n", left, operator_to_string(node->binop.op), right, result);
            return result;
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
        
        case NODE_STRING:
        case NODE_CHAR:
            return 0.0;

        default:
            // Se a análise semântica funcionou, este caso nunca deve ser alcançado
            fprintf(stderr, "Erro interno: Tipo de no desconhecido na execucao.\n");
            break;
    }
    
    return 0.0;
}