#include "symtab.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static Symbol *symtab_head = NULL;
static int current_scope = 0;

static char *copy_string(const char *text) {
    size_t size = strlen(text) + 1;
    char *copy = malloc(size);

    if (!copy) {
        perror("malloc failed");
        exit(EXIT_FAILURE);
    }

    memcpy(copy, text, size);
    return copy;
}

static Symbol *find_visible(const char *name) {
    Symbol *current = symtab_head;

    while (current) {
        if (current->scope <= current_scope &&
            strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }

    return NULL;
}

static Symbol *find_in_scope(const char *name, int scope) {
    Symbol *current = symtab_head;

    while (current) {
        if (current->scope == scope && strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }

    return NULL;
}

static void free_symbol(Symbol *symbol) {
    free(symbol->name);
    free(symbol->str_val);
    free(symbol);
}

const char *symbol_type_to_string(SymbolType type) {
    switch (type) {
        case SYMBOL_TYPE_INT: return "int";
        case SYMBOL_TYPE_FLOAT: return "float";
        case SYMBOL_TYPE_DOUBLE: return "double";
        case SYMBOL_TYPE_CHAR: return "char";
        case SYMBOL_TYPE_STRING: return "str";
        case SYMBOL_TYPE_BOOL: return "bool";
        case SYMBOL_TYPE_UNKNOWN: return "desconhecido";
    }

    return "desconhecido";
}

void symtab_init(void) {
    symtab_head = NULL;
    current_scope = 0;
}

void symtab_reset(void) {
    symtab_free();
    symtab_init();
}

void symtab_enter_scope(void) {
    current_scope++;
}

void symtab_remove_scope(int scope) {
    Symbol **link;

    link = &symtab_head;
    while (*link) {
        Symbol *symbol = *link;

        if (symbol->scope == scope) {
            *link = symbol->next;
            free_symbol(symbol);
        } else {
            link = &symbol->next;
        }
    }
}

void symtab_leave_scope(void) {
    if (current_scope == 0) {
        return;
    }

    symtab_remove_scope(current_scope);
    current_scope--;
}

int symtab_current_scope(void) {
    return current_scope;
}

int symtab_insert(const char *name, SymbolType type, int line) {
    Symbol *symbol;

    if (find_in_scope(name, current_scope)) {
        return 0;
    }

    symbol = calloc(1, sizeof(Symbol));
    if (!symbol) {
        perror("calloc failed");
        exit(EXIT_FAILURE);
    }

    symbol->name = copy_string(name);
    symbol->type = type;
    symbol->scope = current_scope;
    symbol->defined_line = line;
    symbol->last_used_line = line;
    symbol->val_type = VAL_NONE;
    symbol->next = symtab_head;
    symtab_head = symbol;
    return 1;
}

const Symbol *symtab_lookup(const char *name) {
    return find_visible(name);
}

const Symbol *symtab_lookup_current_scope(const char *name) {
    return find_in_scope(name, current_scope);
}

int symtab_record_use(const char *name, int line) {
    Symbol *symbol = find_visible(name);

    if (!symbol) {
        return 0;
    }

    symbol->last_used_line = line;
    symbol->use_count++;
    return 1;
}

int symtab_record_assignment(const char *name, int line) {
    Symbol *symbol = find_visible(name);

    if (!symbol) {
        return 0;
    }

    symbol->last_used_line = line;
    symbol->assign_count++;
    return 1;
}

int symtab_set_value_num(const char *name, double val) {
    Symbol *symbol = find_visible(name);

    if (!symbol) {
        return 0;
    }

    free(symbol->str_val);
    symbol->str_val = NULL;
    symbol->val_type = VAL_NUM;
    symbol->num_val = val;
    return 1;
}

int symtab_set_value_str(const char *name, const char *str) {
    Symbol *symbol = find_visible(name);
    char *copy;

    if (!symbol) {
        return 0;
    }

    copy = str ? copy_string(str) : NULL;
    free(symbol->str_val);
    symbol->str_val = copy;
    symbol->val_type = VAL_STR;
    return 1;
}

void symtab_dump(void) {
    const Symbol *current = symtab_head;

    printf("\n--- Tabela de Simbolos ---\n");
    printf("%-16s %-10s %-7s %-10s %-10s %-6s %-7s %-12s\n",
           "Nome",
           "Tipo",
           "Escopo",
           "LinhaDef",
           "LinhaUso",
           "Usos",
           "Atrib",
           "Valor");

    while (current) {
        char value[64] = "-";

        if (current->val_type == VAL_NUM) {
            snprintf(value, sizeof(value), "%.2f", current->num_val);
        } else if (current->val_type == VAL_STR && current->str_val) {
            snprintf(value, sizeof(value), "%s", current->str_val);
        }

        printf("%-16s %-10s %-7d %-10d %-10d %-6d %-7d %-12s\n",
               current->name,
               symbol_type_to_string(current->type),
               current->scope,
               current->defined_line,
               current->last_used_line,
               current->use_count,
               current->assign_count,
               value);
        current = current->next;
    }
}

void symtab_free(void) {
    Symbol *current = symtab_head;

    while (current) {
        Symbol *next = current->next;
        free_symbol(current);
        current = next;
    }

    symtab_head = NULL;
    current_scope = 0;
}
