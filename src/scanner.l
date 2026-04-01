%{
/* arquivo de exemplo da "semana 03"*/
#include <stdio.h>
%}

/* Definições de padrões de token e ações */
%%

if          { printf("KW_IF\n"); }
while       { printf("KW_WHILE\n"); }
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
