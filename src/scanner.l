%{
/* arquivo de exemplo da "semana 03"*/
#include <stdio.h>
%}

/* Definições de padrões de token e ações */
%%

if          { printf("KW_IF\n"); }
while       { printf("KW_WHILE\n"); }
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
