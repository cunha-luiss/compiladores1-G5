#include <stdio.h>
#include "semantic.h"
#include "symtab.h"

static int node_line(ASTNode *node) {
    return (node && node->line > 0) ? node->line : 0;
}

static int semantic_error_undeclared(const char *name, int line) {
    fprintf(stderr,
            "Erro semantico na linha %d: variavel '%s' nao declarada.\n",
            line,
            name);
    return 1;
}

static int semantic_error_redeclared(const char *name, int line) {
    fprintf(stderr,
            "Erro semantico na linha %d: variavel '%s' ja declarada neste escopo.\n",
            line,
            name);
    return 1;
}

int analyze_ast(ASTNode *node) {
    if (!node) return 0;

    int errors = 0;

    switch (node->type) {
        case NODE_NUM:
        case NODE_STRING:
        case NODE_CHAR:
            break;

        case NODE_VAR: {
            const Symbol *sym = symtab_lookup_visible(node->var_name, SYMTAB_GLOBAL_SCOPE);
            if (!sym) {
                errors += semantic_error_undeclared(node->var_name, node_line(node));
            } else {
                symtab_use(node->var_name, node_line(node));
            }
            break;
        }

        case NODE_ASSIGN: {
            if (node->assign.is_declaration) {
                if (!symtab_insert(node->assign.name,
                                   node->assign.decl_type,
                                   SYMTAB_GLOBAL_SCOPE,
                                   node_line(node))) {
                    errors += semantic_error_redeclared(node->assign.name, node_line(node));
                }

                if (node->assign.value) {
                    errors += analyze_ast(node->assign.value);
                }
                break;
            }

            if (!symtab_lookup_visible(node->assign.name, SYMTAB_GLOBAL_SCOPE)) {
                errors += semantic_error_undeclared(node->assign.name, node_line(node));
            }

            if (node->assign.value) {
                errors += analyze_ast(node->assign.value);
            }
            break;
        }

        case NODE_BINOP:
            errors += analyze_ast(node->binop.left);
            errors += analyze_ast(node->binop.right);
            break;

        case NODE_IF:
            errors += analyze_ast(node->if_node.cond);
            errors += analyze_ast(node->if_node.then_branch);
            errors += analyze_ast(node->if_node.else_branch);
            break;

        case NODE_WHILE:
            errors += analyze_ast(node->while_node.cond);
            errors += analyze_ast(node->while_node.body);
            break;

        case NODE_BLOCK:
            errors += analyze_ast(node->block.statement);
            errors += analyze_ast(node->block.next);
            break;

        case NODE_PRINTF:
            errors += analyze_ast(node->printf_node.expr);
            break;

        default:
            fprintf(stderr, "Aviso Semantico: Tipo de no desconhecido detectado.\n");
            break;
    }

    return errors;
}
