#ifndef SYMTAB_H
#define SYMTAB_H

#include "types.h"

typedef enum {
    VAL_NONE,
    VAL_NUM,
    VAL_STR
} SymbolValueType;

typedef struct Symbol {
    char *name;
    SymbolType type;
    int scope;
    int defined_line;
    int last_used_line;
    int use_count;
    int assign_count;
    SymbolValueType val_type;
    double num_val;
    char *str_val;
    struct Symbol *next;
} Symbol;

void symtab_init(void);
void symtab_reset(void);
void symtab_enter_scope(void);
void symtab_leave_scope(void);
void symtab_remove_scope(int scope);
int symtab_current_scope(void);

int symtab_insert(const char *name, SymbolType type, int line);
const Symbol *symtab_lookup(const char *name);
const Symbol *symtab_lookup_current_scope(const char *name);
int symtab_record_use(const char *name, int line);
int symtab_record_assignment(const char *name, int line);

int symtab_set_value_num(const char *name, double val);
int symtab_set_value_str(const char *name, const char *str);

void symtab_dump(void);
void symtab_free(void);

#endif
