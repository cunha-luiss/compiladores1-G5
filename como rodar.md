flex scanner.l
bison -d parser.y
gcc -o parser parser.tab.c lex.yy.c ast.c symtab.c -lfl
./parser < ../teste_ast.txt


### Testes:
cd src
./run_tests.sh