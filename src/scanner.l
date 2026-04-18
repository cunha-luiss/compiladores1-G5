%{
/* arquivo lexico do interpretador*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"  /* contém definições geradas pelo Bison (NUM, PLUS, etc.) */

static void report_lexical_error(const char *message, const char *lexeme);
static int decode_escape_char(char escape_char, char *decoded);
static int decode_char_literal(const char *lexeme, char *decoded_char);
static char *decode_string_literal(const char *lexeme);
%}

%option yylineno

DIGIT           [0-9]
INT             {DIGIT}+
FLOAT           {DIGIT}+\.{DIGIT}+
CHAR_LITERAL    \'([^\\'\n]|\\.)*\'
STRING_LITERAL  \"([^\\\"\n]|\\.)*\"
UNTERM_CHAR     \'([^\\'\n]|\\.)*
UNTERM_STRING   \"([^\\\"\n]|\\.)*

/* Definicoes de padroes de token e acoes */
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


{FLOAT}  {
    yylval.floatValue = atof(yytext); // pega texto, converte em float e salva para que o analisador sintático possa usa-lo
    return NUMFLOAT;                   // avisa o analisador sintático que um float foi encontrado
    }

{INT}  {
    yylval.intValue = atoi(yytext); // pega texto, converte em inteiro e salva para que o analisador sintático possa usa-lo
    return NUM;                     // avisa o analisador sintático que um inteiro foi encontrado
}

{CHAR_LITERAL} {
    char decoded_char = '\0';

    if (decode_char_literal(yytext, &decoded_char)) {
        yylval.charValue = decoded_char;
        return CHAR;
    }
}

{STRING_LITERAL} {
    char *decoded_string = decode_string_literal(yytext);

    if (decoded_string != NULL) {
        yylval.stringValue = decoded_string;
        return STRING;
    }
}

{UNTERM_STRING} { report_lexical_error("literal STRING nao fechada", yytext); }
{UNTERM_CHAR}   { report_lexical_error("literal CHAR nao fechada", yytext); }

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

static void report_lexical_error(const char *message, const char *lexeme) {
    fprintf(stderr, "Erro lexico (linha %d): %s [%s]\n", yylineno, message, lexeme);
}

static int decode_escape_char(char escape_char, char *decoded) {
    switch (escape_char) {
        case 'n':
            *decoded = '\n';
            return 1;
        case 't':
            *decoded = '\t';
            return 1;
        case 'r':
            *decoded = '\r';
            return 1;
        case '0':
            *decoded = '\0';
            return 1;
        case '\\':
            *decoded = '\\';
            return 1;
        case '"':
            *decoded = '"';
            return 1;
        case '\'':
            *decoded = '\'';
            return 1;
        default:
            return 0;
    }
}

static int decode_char_literal(const char *lexeme, char *decoded_char) {
    size_t content_length;
    size_t length = strlen(lexeme);

    if (length < 2 || lexeme[0] != '\'' || lexeme[length - 1] != '\'') {
        report_lexical_error("literal CHAR malformada", lexeme);
        return 0;
    }

    content_length = length - 2;

    if (content_length == 0) {
        report_lexical_error("literal CHAR vazia", lexeme);
        return 0;
    }

    if (lexeme[1] == '\\') {
        if (content_length != 2) {
            report_lexical_error("literal CHAR com comprimento invalido", lexeme);
            return 0;
        }

        if (!decode_escape_char(lexeme[2], decoded_char)) {
            report_lexical_error("escape invalido em literal CHAR", lexeme);
            return 0;
        }

        return 1;
    }

    if (content_length != 1) {
        report_lexical_error("literal CHAR com comprimento invalido", lexeme);
        return 0;
    }

    *decoded_char = lexeme[1];
    return 1;
}

static char *decode_string_literal(const char *lexeme) {
    char decoded_char;
    char *decoded;
    size_t input_index;
    size_t output_index = 0;
    size_t length = strlen(lexeme);

    if (length < 2 || lexeme[0] != '"' || lexeme[length - 1] != '"') {
        report_lexical_error("literal STRING malformada", lexeme);
        return NULL;
    }

    decoded = (char *)malloc(length);
    if (decoded == NULL) {
        fprintf(stderr, "Erro lexico (linha %d): sem memoria para literal STRING\n", yylineno);
        return NULL;
    }

    for (input_index = 1; input_index < length - 1; ++input_index) {
        if (lexeme[input_index] == '\\') {
            ++input_index;

            if (input_index >= length - 1) {
                report_lexical_error("escape incompleto em literal STRING", lexeme);
                free(decoded);
                return NULL;
            }

            if (!decode_escape_char(lexeme[input_index], &decoded_char)) {
                report_lexical_error("escape invalido em literal STRING", lexeme);
                free(decoded);
                return NULL;
            }

            decoded[output_index++] = decoded_char;
            continue;
        }

        decoded[output_index++] = lexeme[input_index];
    }

    decoded[output_index] = '\0';
    return decoded;
}


/* Função principal: executa o analisador léxico 
comentado para nao rodar
int main(void) {
    yylex();
    return 0;
}
*/