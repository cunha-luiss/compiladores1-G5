#include <stdio.h>
#include <stdlib.h>
#include "semantic.h"
#include "symtab.h"

int analyze_ast(ASTNode *node) {
    if (!node) return 0;

    int errors = 0;

    switch (node->type) {
        
        case NODE_NUM:
        case NODE_STRING:
        case NODE_CHAR:
            // Nós lógicos de literais não geram erros semânticos isolados
            break;

        case NODE_VAR: {
            // Verifica se a variável que está sendo usada já foi declarada/definida
            const Symbol *sym = symtab_lookup(node->var_name);
            if (!sym) {
                fprintf(stderr, "Erro semantico: variavel '%s' usada mas nao foi declarada.\n", node->var_name);
                errors++;
            } else {
                // Registra o uso na tabela de símbolos
                // Usamos 0 temporariamente porque a estrutura atual da AST não guarda a linha do nó
                symtab_use(node->var_name, 0); 
            }
            break;
        }

        case NODE_ASSIGN: {
            // 1. Primeiro analisa o valor que está sendo atribuído (pode ser uma expressão complexa ou outra variável)
            if (node->assign.value) {
                errors += analyze_ast(node->assign.value);
            }

            // 2. Agora analisa a variável que está recebendo o valor
            const Symbol *sym = symtab_lookup(node->assign.name);
            
            // Se a variável não existe na tabela, interpretamos este NODE_ASSIGN como a primeira declaração dela
            if (!sym) {
                symtab_define(node->assign.name, 0);
            } else {
                // Se já existe, apenas registramos uma nova atribuição/atualização na tabela
                symtab_define(node->assign.name, 0);
            }
            break;
        }

        case NODE_BINOP:
            // Garante que ambos os lados da operação matemática/lógica são semânticamente válidos
            errors += analyze_ast(node->binop.left);
            errors += analyze_ast(node->binop.right);
            break;

        case NODE_IF:
            errors += analyze_ast(node->if_node.cond);
            errors += analyze_ast(node->if_node.then_branch);
            if (node->if_node.else_branch) {
                errors += analyze_ast(node->if_node.else_branch);
            }
            break;

        case NODE_WHILE:
            errors += analyze_ast(node->while_node.cond);
            errors += analyze_ast(node->while_node.body);
            break;

        case NODE_BLOCK:
            // Percorre o comando atual do bloco e depois avança para os próximos comandos
            errors += analyze_ast(node->block.statement);
            errors += analyze_ast(node->block.next);
            break;

        default:
            fprintf(stderr, "Aviso Semantico: Tipo de no desconhecido detectado.\n");
            break;
    }

    return errors;
}