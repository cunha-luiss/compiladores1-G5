#include "symtab.h"

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
    printf("%-20s %-12s %-12s %-8s %-8s\n",
           "Nome",
           "LinhaDef",
           "LinhaUso",
           "Usos",
           "Atrib");

    while (cur) {
        printf("%-20s %-12d %-12d %-8d %-8d\n",
               cur->name,
               cur->defined_line,
               cur->last_used_line,
               cur->use_count,
               cur->assign_count);
        cur = cur->next;
    }
}

void symtab_free(void) {
    Symbol *cur = symtab_head;
    while (cur) {
        Symbol *next = cur->next;
        free(cur->name);
        free(cur);
        cur = next;
    }

    symtab_head = NULL;
}
