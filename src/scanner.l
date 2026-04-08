%{
/* arquivo de exemplo da "semana 03"*/
#include <stdio.h>
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

[a-zA-Z_][a-zA-Z0-9_]*  { printf("IDENT(%s)\n", yytext); }

[0-9]+(\.[0-9]+)?  { printf("NUMBER(%s)\n", yytext); }

[+\-*/=]   { printf("OPERATOR(%s)\n", yytext); }

[ \t\n]+  { /* Não faz nada */ }

.  { printf("UNKNOWN(%s)\n", yytext); }

%%

/* Função auxiliar do Flex (quando termina o arquivo de entrada) */
int yywrap(void) {
    return 1;
}

/* Função principal: executa o analisador léxico */
int main(void) {
    yylex();
    return 0;
}
