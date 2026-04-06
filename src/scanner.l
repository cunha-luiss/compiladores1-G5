%{
/* arquivo de exemplo da "semana 03"*/
#include <stdio.h>
%}

/* Definições de padrões de token e ações */
%%

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

if     ""     { printf("KW_IF\n"); }
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
