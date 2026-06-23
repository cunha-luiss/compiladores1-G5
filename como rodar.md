flex scanner.l
bison -d parser.y
gcc -o parser parser.tab.c lex.yy.c ast.c symtab.c semantic.c eval.c -lfl
./parser

### OBS.: toda expressão terminar com o ; e finalizar leitura do compilador com Ctrl+D

## Caso queira rodar com um teste válido
./parser < tests/atribuicao/simples.txt


### Testes:
cd src
./run_tests.sh

Os testes ficam em `src/tests/` organizados por categoria:
- `atribuicao/`      – atribuição e cópia de variáveis
- `aritmetica/`      – expressões matemáticas (+, -, *, /, parênteses)
- `logico_relacional/` – comparações (==, !=, <, >)
- `controle/`        – blocos `if` e `while`
- `strings/`         – literais `str` e `char`
- `erros/`           – casos que devem gerar erro semântico

### Cobertura (gera HTML com lcov)
cd src
make coverage
# relatório: src/coverage_html/index.html