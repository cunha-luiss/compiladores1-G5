# **Compiladores1-G5**

## O que faremos?

O nosso projeto é um mini interpretador de C com o seguinte escopo da linguagem:


- Tipos básicos: inteiro, ponto flutuante, booleano e char.
- Expressões aritméticas.
- Comparações simples (== &&).
- Atribuição de variáveis.
- Blocos e comandos básicos de controle de decisão (blocos if e while).


Além disso, a base do nosso interpretador é a AST que é primeiro preenchida, depois percorrida e interpretada. A tabela de símbolos foi implementada com lista encadeada por ser uma estrutura de dados que o grupo mais está confortável. Também implementamos o tipo str para denotar strings e facilidar o uso de printf sem a necessidade de lidar com ponteiros e arrays.


### Testes e Cobertura
Para rodar os testes e gerar o relatório de cobertura de código, utilize a automação do `make` (é necessário ter o `lcov` instalado):
```bash
cd src
make coverage
```
O relatório HTML detalhado será gerado na pasta `src/coverage_html`.

Caso queira apenas rodar os testes sem relatório:
```bash
cd src
./run_tests.sh
```

## Build do interpretador

Para gerar o parser, o scanner (Bison/Flex) e compilar o executável, basta usar o `make`:

```bash
cd src
make
```

Executar com arquivo de entrada:

```bash
./parser < arquivo_entrada.txt
```

Já, se quiser rodar você mesmo indo colocando o código no terminal:

```bash
./parser
```
Obs.: sempre que quiser terminar uma sessão, rode Ctrl+D que cria o EOF para acabar com o processo!

## Arquivos

### ast.c
Responsável pelas funções relacionadas à árvore sintática abstrata, atuando na sua montagem, exibição e liberação da memória

### eval.c

Funções responsáveis pelo percorrimento da árvore sintática, manipulando dados, julgando operadores lógicos, controlando o fluxo em blocos if while e atualizando definições na tabela de símbolos

### semantic.c

Percorre a árvore sintática em busca de erros sintáticos

### symtab.c

Funções relacionadas a tabela de símbolos
