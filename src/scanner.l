%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.tab.h"

int lexical_errors = 0;

static char *copy_text(const char *text, size_t length) {
    size_t size = length + 1;
    char *copy = malloc(size);

    if (!copy) {
        perror("malloc failed");
        exit(EXIT_FAILURE);
    }

    memcpy(copy, text, length);
    copy[length] = '\0';
    return copy;
}

#define YY_USER_ACTION                                  \
    yylloc.first_line = yylineno;                       \
    yylloc.last_line = yylineno;                        \
    yylloc.first_column = 1;                            \
    yylloc.last_column = (int)yyleng;
%}

%option yylineno noinput nounput noyywrap never-interactive

%%

_Alignas      { return KW_ALIGNAS; }
_Alignof      { return KW_ALIGNOF; }
_Atomic       { return KW_ATOMIC; }
_Bool         { yylval.symbol_type = SYMBOL_TYPE_BOOL; return KW_BOOL; }
_Complex      { return KW_COMPLEX; }
_Decimal128   { return KW_DECIMAL128; }
_Decimal32    { return KW_DECIMAL32; }
_Decimal64    { return KW_DECIMAL64; }
_Generic      { return KW_GENERIC; }
_Imaginary    { return KW_IMAGINARY; }
_Noreturn     { return KW_NORETURN; }
_Static_assert { return KW_STATIC_ASSERT; }
_Thread_local { return THREAD_STORAGE; }
alignas       { return KW_ALIGNMENT; }
alignof       { return KW_ALIGNOF; }
auto          { return AUTO_TYPE_INFERENCE; }
bool          { yylval.symbol_type = SYMBOL_TYPE_BOOL; return BOOL_TYPE; }
break         { return DECLARATION; }
case          { return KW_SWITCH; }
char          { yylval.symbol_type = SYMBOL_TYPE_CHAR; return TYPE_SPECIFIER; }
const         { return CONST_LITERAL; }
constexpr     { return SPECIFIER; }
continue      { return CONTINUE_STATEMENT; }
default       { return DEFAULT_STATEMENT; }
do            { return DO_LOOP; }
double        { yylval.symbol_type = SYMBOL_TYPE_DOUBLE; return DOUBLE_TYPE; }
else          { return ELSE_STATEMENT; }
enum          { return ENUMERATION_TYPE; }
extern        { return STORAGE_CLASS_SPECIFIER; }
false         { return FALSE_LITERAL; }
float         { yylval.symbol_type = SYMBOL_TYPE_FLOAT; return TYPE_SPECIFIER; }
for           { return LOOP; }
fortran       { yylval.symbol_type = SYMBOL_TYPE_UNKNOWN; return TYPE_SPECIFIER; }
goto          { return STATEMENT; }
if            { return IF_STATEMENT; }
inline        { return INLINE_FUNCTION_SPECIFIER; }
int           { yylval.symbol_type = SYMBOL_TYPE_INT; return TYPE_SPECIFIER; }
long          { return KW_LONG; }
nullptr       { return POINTER_CONSTANT; }
register      { return AUTOMATIC_DURATION_STORAGE_CLASS_SPECIFIER; }
restrict      { return TYPE_QUALIFIER; }
return        { return RETURN_STATEMENT; }
short         { return TYPE_MODIFIER; }
signed        { return KW_SIZE; }
sizeof        { return OPERATOR; }
static        { return KW_STATIC; }
static_assert { return STATIC_ASSERT_DECLARATION; }
str           { yylval.symbol_type = SYMBOL_TYPE_STRING; return TYPE_SPECIFIER; }
struct        { return KW_DECLARATION_OF_A_COMPOUND_TYPE; }
switch        { return SWITCH_STATEMENT; }
thread_local  { return KW_THREAD_STORAGE_CLASS_SPECIFIER; }
true          { return TRUE_LITERAL; }
typedef       { return KW_TYPE_DECLARATION; }
typeof        { return KW_OPERATOR; }
typeof_unqual { return KW_OPERATOR_THAT_REMOVES_QUALIFIERS; }
union         { return KW_DECLARATION_OF_A_UNION_TYPE; }
unsigned      { return KW_TYPE_MODIFIER; }
void          { return KW_TYPE_OF_VARIABLE_OR_PARAMETER_OF_FUNCTION_OR_RETURN_VALUE; }
volatile      { return KW_TYPE_QUALIFIER; }
while         { return KW_WHILE; }

\"(\\.|[^"\\])*\" {
    yylval.str = copy_text(yytext, (size_t)yyleng);
    return STRING_LITERAL;
}

\'(\\.|[^'\\])*\' {
    yylval.str = copy_text(yytext, (size_t)yyleng);
    return CHAR_LITERAL;
}

"//".*     { }
"/*"([^*]|\*+[^*/])*\*+\/    { }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = copy_text(yytext, (size_t)yyleng);
    return ID;
}

[0-9]+\.[0-9]+ {
    yylval.floatValue = (float)atof(yytext);
    return NUMFLOAT;
}

[0-9]+ {
    yylval.intValue = atoi(yytext);
    return NUM;
}

"+"     { return PLUS; }
"-"     { return MINUS; }
"*"     { return TIMES; }
"/"     { return DIVIDE; }
"("     { return LPAREN; }
")"     { return RPAREN; }
"=="    { return COMPARATION; }
"="     { return EQUAL; }
";"     { return SEMICOLON; }
"{"     { return LBRACE; }
"}"     { return RBRACE; }
"<="    { return LESS_EQUAL; }
">="    { return GREATER_EQUAL; }
"!="    { return NOT_EQUAL; }
"&&"    { return LOGICAL_AND; }
"||"    { return LOGICAL_OR; }
"<"     { return LESS; }
">"     { return GREATER; }

"\n"       { }
[ \t\r]+   { }

. {
    lexical_errors++;
    fprintf(stderr,
            "Erro lexico na linha %d: token invalido '%s'\n",
            yylineno,
            yytext);
}

%%
