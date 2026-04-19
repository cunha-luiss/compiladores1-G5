%{
/* arquivo léxico do interpretador*/
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"  /* contém definições geradas pelo Bison (NUM, PLUS, etc.) */
%}

/* Definições de padrões de token e ações */
%%

_Alignas    { return KW_ALIGNAS; }
_Alignof    { return KW_ALIGNOF; }
_Atomic     { return KW_ATOMIC; }
_Bool       { return KW_BOOL; }
_Complex    { return KW_COMPLEX; }
_Decimal128 { return KW_DECIMAL128; }
_Decimal32  { return KW_DECIMAL32; }
_Decimal64  { return KW_DECIMAL64; }
_Generic    { return KW_GENERIC; }
_Imaginary  { return KW_IMAGINARY; }
_Noreturn   { return KW_NORETURN; }
_Static_assert  { return KW_STATIC_ASSERT; }

_Thread_local { return THREAD_STORAGE; }
alignas     { return KW_ALIGNMENT; }
alignof     { return KW_OPERATOR; }
auto        { return TYPE_INFERENCE; }
bool        { return TYPE; }
break       { return DECLARATION; }
case        { return KW_SWITCH; }
char        { return TYPE; }
const       { return TYPE; }
constexpr   { return SPECIFIER; }
continue    { return STATEMENT; }

default     { return SWITCH_STATEMENT; }
do          { return LOOP; }
double      { return TYPE; }
else        { return STATEMENT; }
enum        { return ENUMERATION_TYPE; }
extern      { return STORAGE_CLASS_SPECIFIER; }
false       { return BOOLEAN; }
float       { printf("TYPE\n"); }
for         { printf("LOOP\n"); }
fortran     { printf("TYPE_SPECIFIER\n"); }
goto        { printf("STATEMENT\n"); }
if          { printf("STATEMENT\n"); }

inline     { printf("INLINE FUNCTION SPECIFIER\n"); }
int    { printf("TYPE\n"); }
long     { printf("TYPE MODIFIER\n"); }
nullptr     { printf("POINTER CONSTANT\n"); }
register     { printf("AUTOMATIC DURATION STORAGE-CLASS SPECIFIER\n"); }
restrict     { printf("TYPE QUALIFIER\n"); }
return     { printf("STATEMENT\n"); }
short     { printf("TYPE MODIFIER\n"); }
signed     { printf("TYPE MODIFIER\n"); }
sizeof     { printf("OPERATOR\n"); }
static     { printf("STORAGE CLASS SPECIFIER\n"); }
static_assert     { printf("STATIC ASSERT DECLARATION\n"); }

struct      { printf("KW_DECLARATION_OF_A_COMPOUND_TYPE\n");}
switch      { printf("KW_SWITCH_STATEMENT\n");}
thread_local    { printf("KW_THREAD_STORAGE_CLASS_SPECIFIER\n");}
true        { printf("KW_BOOLEAN_CONSTANT_STATE\n");}
typedef     { printf("KW_DECLARATION\n");}
typeof      { printf("KW_OPERATOR\n");}
typeof_unqual   { printf("KW_OPERATOR_THAT_REMOVES_QUALIFIERS\n");}
union       { printf("KW_DECLARATION_OF_A_UNION_TYPE\n");}
unsigned    { printf("KW_TYPE_MODIFIER\n");}
void        { printf("KW_TYPE_OF_VARIABLE_OR_PARAMETER_OF_FUNCTION_OR_RETURN_VALUE\n");}
volatile    { printf("KW_TYPE_QUALIFIER\n");}

while       { printf("KW_WHILE\n"); }



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