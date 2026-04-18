%{
/* arquivo léxico do interpretador*/
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"  /* contém definições geradas pelo Bison (NUM, PLUS, etc.) */
%}

/* Definições de padrões de token e ações */
%%

_Alignas    { printf("KW_ALIGNAS\n"); }
_Alignof    { printf("KW_ALIGNOF\n"); }
_Atomic     { printf("KW_ATOMIC\n"); }
_Bool       { printf("KW_BOOL\n"); }
_Complex    { printf("KW_COMPLEX\n"); }
_Decimal128 { printf("KW_DECIMAL128\n"); }
_Decimal32  { printf("KW_DECIMAL32\n"); }
_Decimal64  { printf("KW_DECIMAL64\n"); }
_Generic    { printf("KW_GENERIC\n"); }
_Imaginary  { printf("KW_IMAGINARY\n"); }
_Noreturn   { printf("KW_NORETURN\n"); }
_Static_assert  { printf("KW_STATIC_ASSERT\n"); }

_Thread_local {printf("THREAD_STORAGE\n"); }
alignas     {printf("KW_ALIGNMENT\n"); }
alignof     {printf("KW_OPERATOR\n"); }
auto        {printf("TYPE_INFERENCE\n"); }
bool        {printf("TYPE\n"); }
break       {printf("DECLARATION\n"); }
case        {printf("KW_SWITCH\n"); }
char        {printf("TYPE\n"); }
const       {printf("TYPE\n"); }
constexpr   {printf("SPECIFIER\n"); }
continue    {printf("STATEMENT"); }

default     { printf("SWITCH_STATEMENT\n"); }
do          { printf("LOOP\n"); }
double      { printf("TYPE\n"); }
else        { printf("STATEMENT\n"); }
enum        { printf("ENUMERATION_TYPE\n"); }
extern      { printf("STORAGE_CLASS_SPECIFIER\n"); }
false       { printf("BOOLEAN\n"); }
float         { return TYPE; }
for           { return LOOP; }
fortran       { return TYPE_SPECIFIER; }
goto          { return STATEMENT; }
if            { return STATEMENT; }

inline        { return INLINE_FUNCTION_SPECIFIER; }
int           { return TYPE; }
long          { return TYPE_MODIFIER; }
nullptr       { return POINTER_CONSTANT; }
register      { return AUTOMATIC_DURATION_STORAGE_CLASS_SPECIFIER; }
restrict      { return TYPE_QUALIFIER; }
return        { return STATEMENT; }
short         { return TYPE_MODIFIER; }
signed        { return TYPE_MODIFIER; }
sizeof        { return OPERATOR; }
static        { return STORAGE_CLASS_SPECIFIER; }
static_assert { return STATIC_ASSERT_DECLARATION; }

struct        { return KW_DECLARATION_OF_A_COMPOUND_TYPE; }
switch        { return KW_SWITCH_STATEMENT; }
thread_local  { return KW_THREAD_STORAGE_CLASS_SPECIFIER; }
true          { return KW_BOOLEAN_CONSTANT_STATE; }
typedef       { return KW_DECLARATION; }
typeof        { return KW_OPERATOR; }
typeof_unqual { return KW_OPERATOR_THAT_REMOVES_QUALIFIERS; }
union         { return KW_DECLARATION_OF_A_UNION_TYPE; }
unsigned      { return KW_TYPE_MODIFIER; }
void          { return KW_TYPE_OF_VARIABLE_OR_PARAMETER_OF_FUNCTION_OR_RETURN_VALUE; }
volatile      { return KW_TYPE_QUALIFIER; }

while         { return KW_WHILE; }



"//".*     { /* Ignorar comentários de linha */ }

"/*"([^*]|\*+[^*/])*\*+\/    { /* Ignorar comentários de bloco */ }


[0-9]+\.[0-9]+  {
    yylval.floatValue = atof(yytext); // pega texto, converte em float e salva para que o analisador sintático possa usa-lo
    return NUMFLOAT;                   // avisa o analisador sintático que um float foi encontrado
    }

[0-9]+  {
    yylval.intValue = atoi(yytext); // pega texto, converte em inteiro e salva para que o analisador sintático possa usa-lo
    return NUM;                     // avisa o analisador sintático que um inteiro foi encontrado
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

[ \t\n]+  { /* Não faz nada */ }

.  { printf("UNKNOWN(%s)\n", yytext); }

%%

/* Função auxiliar do Flex (quando termina o arquivo de entrada) */
int yywrap(void) {
    return 1;
}


/* Função principal: executa o analisador léxico 
comentado para nao rodar
int main(void) {
    yylex();
    return 0;
}
*/
