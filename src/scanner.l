%{
/* arquivo de exemplo da "semana 03"*/
#include <stdio.h>
%}

/* Definições de padrões de token e ações */
%%

if          { printf("KW_IF\n"); }
while       { printf("KW_WHILE\n"); }
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
