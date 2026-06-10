flex scanner.l
bison -d parser.y
gcc -o parser parser.tab.c lex.yy.c ast.c symtab.c semantic.c eval.c -lfl
./parser

### OBS.: toda expressão terminar com o ; e finalizar leitura do compilador com Ctrl+D

## Caso queira rodar com um teste válido
./parser < tests/teste_valido_ast.txt


### Testes:
cd src
./run_tests.sh