#pragma once
#include <stddef.h>

typedef struct ASTNode ASTNode;

typedef struct Symbol {
    char *name;
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
void symtab_define(const char *name, int line);
void symtab_assign(const char *name, ASTNode *val, int line);
void symtab_use(const char *name, int line);
const Symbol *symtab_lookup(const char *name);
void symtab_dump(void);
void symtab_free(void);
