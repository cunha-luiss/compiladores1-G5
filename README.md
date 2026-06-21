# **Compiladores1-G5**

## O que faremos?

O nosso projeto é um mini interpretador de C com o seguinte escopo da linguagem:


- Tipos básicos: inteiro, ponto flutuante, booleano e char.
- Expressões aritméticas.
- Comparações simples (== &&).
- Atribuição de variáveis.
- Blocos e comandos básicos de controle de decisão (blocos if e while).


Além disso, a base do nosso interpretador é a AST que é primeiro preenchida, depois percorrida e interpretada. A tabela de símbolos foi implementada com lista encadeada por ser uma estrutura de dados que o grupo mais está confortável. Também implementamos o tipo str para denotar strings e facilidar o uso de printf sem a necessidade de lidar com ponteiros e arrays.


### Testes:
cd src
./run_tests.sh


## Build do interpretador

Gerar parser e scanner (Bison/Flex) e compilar:

```bash
flex scanner.l
bison -d parser.y
gcc -o parser parser.tab.c lex.yy.c ast.c symtab.c semantic.c eval.c -lfl
```

Executar com arquivo de entrada:

```bash
./parser < arquivo_entrada.txt
```

Rodar casos de teste

```bash
cd src
./run_tests.sh
```

## Arquivos

### ast.c
Responsável pelas funções relacionadas à árvore sintática abstrata, atuando na sua montagem, exibição e liberação da memória

### eval.c

Funções responsáveis pelo percorrimento da árvore sintática, manipulando dados, julgando operadores lógicos, controlando o fluxo em blocos if while e atualizando definições na tabela de símbolos

### semantic.c

Percorre a árvore sintática em busca de erros sintáticos

### symtab.c

Funções relacionadas a tabela de símbolos
