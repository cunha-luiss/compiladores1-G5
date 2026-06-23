#include "symtab.h"
#include "ast.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static Symbol *symtab_head = NULL;

static Symbol *symtab_find_in_scope_mut(const char *name, int scope) {
    Symbol *cur = symtab_head;

    while (cur) {
        if (cur->scope == scope && strcmp(cur->name, name) == 0) {
            return cur;
        }
        cur = cur->next;
    }

    return NULL;
}

static Symbol *symtab_find_visible_mut(const char *name, int scope) {
    Symbol *global = NULL;
    Symbol *cur = symtab_head;

    while (cur) {
        if (strcmp(cur->name, name) == 0) {
            if (cur->scope == scope) {
                return cur;
            }
            if (cur->scope == SYMTAB_GLOBAL_SCOPE) {
                global = cur;
            }
        }
        cur = cur->next;
    }

    return global;
}

static Symbol *symtab_new_symbol(const char *name, const char *type, int scope, int line) {
    Symbol *sym = (Symbol *)malloc(sizeof(Symbol));
    if (!sym) {
        perror("malloc failed");
        exit(1);
    }

    sym->name = strdup(name);
    if (!sym->name) {
        perror("strdup failed");
        exit(1);
    }

    sym->type = strdup(type ? type : "unknown");
    if (!sym->type) {
        perror("strdup failed");
        exit(1);
    }

    sym->scope = scope;
    sym->defined_line = line;
    sym->last_used_line = line;
    sym->use_count = 0;
    sym->assign_count = 0;
    sym->val_type = VAL_NONE;
    sym->num_val = 0.0;
    sym->str_val = NULL;
    sym->next = NULL;

    return sym;
}

void symtab_init(void) {
    symtab_head = NULL;
}

int symtab_insert(const char *name, const char *type, int scope, int line) {
    if (symtab_find_in_scope_mut(name, scope)) {
        return 0;
    }

    Symbol *sym = symtab_new_symbol(name, type, scope, line);
    sym->next = symtab_head;
    symtab_head = sym;
    return 1;
}

const Symbol *symtab_lookup_in_scope(const char *name, int scope) {
    return symtab_find_in_scope_mut(name, scope);
}

const Symbol *symtab_lookup_visible(const char *name, int scope) {
    return symtab_find_visible_mut(name, scope);
}

const Symbol *symtab_lookup(const char *name) {
    return symtab_lookup_visible(name, SYMTAB_GLOBAL_SCOPE);
}

void symtab_remove_scope(int scope) {
    Symbol **cur = &symtab_head;

    while (*cur) {
        Symbol *sym = *cur;
        if (sym->scope == scope) {
            *cur = sym->next;
            free(sym->name);
            free(sym->type);
            free(sym->str_val);
            free(sym);
        } else {
            cur = &sym->next;
        }
    }
}

void symtab_define(const char *name, int line) {
    Symbol *sym = symtab_find_visible_mut(name, SYMTAB_GLOBAL_SCOPE);

    if (!sym) {
        symtab_insert(name, "unknown", SYMTAB_GLOBAL_SCOPE, line);
        return;
    }

    if (sym->defined_line < 0) {
        sym->defined_line = line;
    }
    sym->last_used_line = line;
}

void symtab_set_value_num(const char *name, double val) {
    Symbol *sym = symtab_find_visible_mut(name, SYMTAB_GLOBAL_SCOPE);
    if (!sym) {
        return;
    }

    free(sym->str_val);
    sym->str_val = NULL;
    sym->val_type = VAL_NUM;
    sym->num_val = val;
    sym->assign_count += 1;
}

void symtab_set_value_str(const char *name, const char *str) {
    Symbol *sym = symtab_find_visible_mut(name, SYMTAB_GLOBAL_SCOPE);
    if (!sym) {
        return;
    }

    free(sym->str_val);
    sym->str_val = NULL;
    sym->val_type = VAL_STR;
    sym->str_val = strdup(str ? str : "");
    if (!sym->str_val) {
        perror("strdup failed");
        exit(1);
    }
    sym->assign_count += 1;
}

void symtab_assign(const char *name, struct ASTNode *val, int line) {
    Symbol *sym = symtab_find_visible_mut(name, SYMTAB_GLOBAL_SCOPE);
    if (!sym) {
        return;
    }

    if (sym->defined_line < 0) {
        sym->defined_line = line;
    }
    sym->last_used_line = line;

    if (!val) {
        free(sym->str_val);
        sym->str_val = NULL;
        sym->val_type = VAL_NONE;
        return;
    }

    switch (val->type) {
        case NODE_NUM:
            symtab_set_value_num(name, val->num_val);
            break;

        case NODE_STRING:
        case NODE_CHAR:
            symtab_set_value_str(name, val->str_val ? val->str_val : "");
            break;

        default:
            break;
    }
}

void symtab_use(const char *name, int line) {
    Symbol *sym = symtab_find_visible_mut(name, SYMTAB_GLOBAL_SCOPE);
    if (!sym) {
        return;
    }

    sym->last_used_line = line;
    sym->use_count += 1;
}

void symtab_dump(void) {
    Symbol *cur = symtab_head;

    printf("\n--- Tabela de Simbolos ---\n");
    printf("%-20s %-12s %-8s %-12s %-12s %-8s %-8s %-12s\n",
           "Nome",
           "Tipo",
           "Escopo",
           "LinhaDef",
           "LinhaUso",
           "Usos",
           "Atrib",
           "Valor");

    while (cur) {
        char valbuf[64] = {0};
        if (cur->val_type == VAL_NUM) {
            snprintf(valbuf, sizeof(valbuf), "%.2f", cur->num_val);
        } else if (cur->val_type == VAL_STR && cur->str_val) {
            snprintf(valbuf, sizeof(valbuf), "\"%s\"", cur->str_val);
        } else {
            snprintf(valbuf, sizeof(valbuf), "-");
        }

        printf("%-20s %-12s %-8d %-12d %-12d %-8d %-8d %-12s\n",
               cur->name,
               cur->type ? cur->type : "-",
               cur->scope,
               cur->defined_line,
               cur->last_used_line,
               cur->use_count,
               cur->assign_count,
               valbuf);
        cur = cur->next;
    }
}

void symtab_free(void) {
    Symbol *cur = symtab_head;

    while (cur) {
        Symbol *next = cur->next;
        free(cur->name);
        free(cur->type);
        free(cur->str_val);
        free(cur);
        cur = next;
    }

    symtab_head = NULL;
}
