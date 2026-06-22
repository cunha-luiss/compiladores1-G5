#ifndef TYPES_H
#define TYPES_H

typedef enum {
    SYMBOL_TYPE_INT,
    SYMBOL_TYPE_FLOAT,
    SYMBOL_TYPE_DOUBLE,
    SYMBOL_TYPE_CHAR,
    SYMBOL_TYPE_STRING,
    SYMBOL_TYPE_BOOL,
    SYMBOL_TYPE_UNKNOWN
} SymbolType;

const char *symbol_type_to_string(SymbolType type);

#endif
