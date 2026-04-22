%{
/* arquivo léxico do interpretador*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"  /* contém definições geradas pelo Bison (NUM, PLUS, etc.) */

int lexical_errors = 0;
%}

%option yylineno noinput nounput

/* Definições de padrões de token e ações */
%%


_Alignas      { return KW_ALIGNAS; }
_Alignof      { return KW_ALIGNOF; }
_Atomic       { return KW_ATOMIC; }
_Bool         { return KW_BOOL; }
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
bool          { return BOOL_TYPE; }
break         { return DECLARATION; }
case          { return KW_SWITCH; }
char          { return CHAR_LITERAL; }
const         { return CONST_LITERAL; }
constexpr     { return SPECIFIER; }
continue      { return CONTINUE_STATEMENT; }
default       { return DEFAULT_STATEMENT; }
do            { return DO_LOOP; }
double        { return DOUBLE_TYPE; }
else          { return ELSE_STATEMENT; }
enum          { return ENUMERATION_TYPE; }
extern        { return STORAGE_CLASS_SPECIFIER; }
false         { return FALSE_LITERAL; }
float         { return NUMFLOAT; }
for           { return LOOP; }
fortran       { return TYPE_SPECIFIER; }
goto          { return STATEMENT; }
if            { return IF_STATEMENT; }
inline        { return INLINE_FUNCTION_SPECIFIER; }
int           { return NUM; }
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
    yylval.str = strdup(yytext);
    return STRING_LITERAL;
}


\'(\\.|[^'\\])*\' {
    yylval.str = strdup(yytext);
    return CHAR_LITERAL;
}

"//".*     { /* Ignorar comentários de linha */ }

"/*"([^*]|\*+[^*/])*\*+\/    { /* Ignorar comentários de bloco */ }


[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return ID;
}


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

.  {
    lexical_errors++;
    fprintf(stderr, "Erro lexico na linha %d: token invalido '%s'\n", yylineno, yytext);
}

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
