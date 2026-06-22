#include "semantic.h"
#include "symtab.h"

#include <stdio.h>

static int semantic_error(int line, const char *name, const char *message) {
    fprintf(stderr,
            "Erro semantico na linha %d: variavel '%s' %s\n",
            line,
            name,
            message);
    return 1;
}

int analyze_ast(ASTNode *node) {
    int errors = 0;

    if (!node) {
        return 0;
    }

    switch (node->type) {
        case NODE_NUM:
        case NODE_STRING:
        case NODE_CHAR:
            break;

        case NODE_VAR:
            if (!symtab_lookup(node->var_name)) {
                errors += semantic_error(
                    node->line, node->var_name, "nao declarada");
            } else {
                symtab_record_use(node->var_name, node->line);
            }
            break;

        case NODE_BINOP:
            errors += analyze_ast(node->binop.left);
            errors += analyze_ast(node->binop.right);
            break;

        case NODE_DECL:
            if (symtab_lookup_current_scope(node->decl.name)) {
                errors += semantic_error(
                    node->line,
                    node->decl.name,
                    "redeclarada no mesmo escopo");
            } else {
                symtab_insert(node->decl.name,
                              node->decl.declared_type,
                              node->line);
                if (node->decl.value) {
                    symtab_record_assignment(node->decl.name, node->line);
                }
            }
            errors += analyze_ast(node->decl.value);
            break;

        case NODE_ASSIGN:
            if (!symtab_lookup(node->assign.name)) {
                errors += semantic_error(
                    node->line, node->assign.name, "nao declarada");
            } else {
                symtab_record_assignment(node->assign.name, node->line);
            }
            errors += analyze_ast(node->assign.value);
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

        case NODE_SCOPE:
            symtab_enter_scope();
            errors += analyze_ast(node->scope.body);
            symtab_leave_scope();
            break;
    }

    return errors;
}
