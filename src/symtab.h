#pragma once
#include <stddef.h>

typedef struct ASTNode ASTNode;

#define SYMTAB_GLOBAL_SCOPE 0

typedef struct Symbol {
    char *name;
    char *type;
    int scope;
    int defined_line;
    int last_used_line;
    int use_count;
    int assign_count;
    /* valor atual (opcional) */
    enum {
        VAL_NONE,
        VAL_NUM,
        VAL_STR
    } val_type;
    double num_val;
    char *str_val;
    struct Symbol *next;
} Symbol;

void symtab_init(void);
int symtab_insert(const char *name, const char *type, int scope, int line);
const Symbol *symtab_lookup_in_scope(const char *name, int scope);
const Symbol *symtab_lookup_visible(const char *name, int scope);
void symtab_remove_scope(int scope);
void symtab_define(const char *name, int line);
void symtab_assign(const char *name, ASTNode *val, int line);
void symtab_use(const char *name, int line);
const Symbol *symtab_lookup(const char *name);
void symtab_set_value_num(const char *name, double val);
void symtab_set_value_str(const char *name, const char *str);
void symtab_dump(void);
void symtab_free(void);
