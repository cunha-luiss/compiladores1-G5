#include "symtab.h"
#include "ast.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static Symbol *symtab_head = NULL;

static Symbol *symtab_find(const char *name) {
    Symbol *cur = symtab_head;
    while (cur) {
        if (strcmp(cur->name, name) == 0) {
            return cur;
        }
        cur = cur->next;
    }

    return NULL;
}

void symtab_init(void) {
    symtab_head = NULL;
}

const Symbol *symtab_lookup(const char *name) {
    return symtab_find(name);
}

void symtab_set_value_num(const char *name, double val) {
    Symbol *sym = symtab_find(name);
    if (sym) {
        if (sym->str_val) {
            free(sym->str_val);
            sym->str_val = NULL;
        }
        sym->val_type = VAL_NUM;
        sym->num_val = val;
    }
}

void symtab_set_value_str(const char *name, const char *str) {
    Symbol *sym = symtab_find(name);
    if (sym) {
        if (sym->str_val) {
            free(sym->str_val);
            sym->str_val = NULL;
        }
        sym->val_type = VAL_STR;
        if (str) {
            sym->str_val = strdup(str);
        }
    }
}

void symtab_define(const char *name, int line) {
    Symbol *sym = symtab_find(name);

    if (!sym) {
        sym = (Symbol *)malloc(sizeof(Symbol));
        if (!sym) {
            perror("malloc failed");
            exit(1);
        }

        sym->name = strdup(name);
        if (!sym->name) {
            perror("strdup failed");
            exit(1);
        }

        sym->defined_line = line;
        sym->last_used_line = line;
        sym->use_count = 0;
        sym->assign_count = 1;
        sym->val_type = VAL_NONE;
        sym->num_val = 0.0;
        sym->str_val = NULL;
        sym->next = symtab_head;
        symtab_head = sym;
        return;
    }

    if (sym->defined_line < 0) {
        sym->defined_line = line;
    }

    sym->last_used_line = line;
    sym->assign_count += 1;
}

void symtab_assign(const char *name, struct ASTNode *val, int line) {
    Symbol *sym = symtab_find(name);

    if (!sym) {
        sym = (Symbol *)malloc(sizeof(Symbol));
        if (!sym) {
            perror("malloc failed");
            exit(1);
        }

        sym->name = strdup(name);
        if (!sym->name) {
            perror("strdup failed");
            exit(1);
        }

        sym->defined_line = line;
        sym->last_used_line = line;
        sym->use_count = 0;
        sym->assign_count = 1;
        sym->val_type = VAL_NONE;
        sym->num_val = 0.0;
        sym->str_val = NULL;
        sym->next = symtab_head;
        symtab_head = sym;
    } else {
        if (sym->defined_line < 0) sym->defined_line = line;
        sym->last_used_line = line;
        sym->assign_count += 1;
    }

    if (!val) {
        /* no value provided */
        if (sym->str_val) {
            free(sym->str_val);
            sym->str_val = NULL;
        }
        sym->val_type = VAL_NONE;
        return;
    }

    switch (val->type) {
        case NODE_NUM:
            if (sym->str_val) { free(sym->str_val); sym->str_val = NULL; }
            sym->val_type = VAL_NUM;
            sym->num_val = val->num_val;
            break;

        case NODE_STRING:
        case NODE_CHAR:
            if (sym->str_val) free(sym->str_val);
            sym->val_type = VAL_STR;
            sym->str_val = strdup(val->str_val ? val->str_val : "");
            break;

        default:
            /* complex expression — we don't evaluate here */
            break;
    }
}

void symtab_use(const char *name, int line) {
    Symbol *sym = symtab_find(name);

    if (!sym) {
        sym = (Symbol *)malloc(sizeof(Symbol));
        if (!sym) {
            perror("malloc failed");
            exit(1);
        }

        sym->name = strdup(name);
        if (!sym->name) {
            perror("strdup failed");
            exit(1);
        }

        sym->defined_line = -1;
        sym->last_used_line = line;
        sym->use_count = 1;
        sym->assign_count = 0;
        sym->next = symtab_head;
        symtab_head = sym;

        fprintf(stderr,
                "Aviso semantico: variavel '%s' usada antes de ser atribuida (linha %d)\n",
                name,
                line);
        return;
    }

    sym->last_used_line = line;
    sym->use_count += 1;
}

void symtab_dump(void) {
    Symbol *cur = symtab_head;

    printf("\n--- Tabela de Simbolos ---\n");
    printf("%-20s %-12s %-12s %-8s %-8s %-12s\n",
           "Nome",
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

        printf("%-20s %-12d %-12d %-8d %-8d %-12s\n",
               cur->name,
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
        if (cur->str_val) free(cur->str_val);
        free(cur);
        cur = next;
    }

    symtab_head = NULL;
}
