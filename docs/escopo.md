# Escopo da fase atual

Esta página define o que será implementado agora e o que fica explicitamente fora do escopo para evitar promessas além do cronograma.

## Implementar nesta fase

- Definição formal da linguagem interpretada.
- Gramática inicial para o recorte da linguagem.
- Análise léxica com Flex (tokens principais, comentários e espaços).
- Análise sintática com Bison para estruturas centrais do recorte.
- Ações semânticas iniciais no parser para preparar geração da AST.
- Documentação completa da fase com método Kanban.

## Não implementar nesta fase

- Análise semântica robusta e completa.
- Tabela de símbolos avançada com escopo completo.
- Interpretação completa da AST para toda a linguagem.
- Otimizações avançadas de execução.
- Funcionalidades extras fora do recorte acordado.

## Recorte proposto da linguagem

- Tipos básicos: inteiro, ponto flutuante, booleano e char.
- Expressões aritméticas e comparações simples.
- Atribuição em variáveis.
- Blocos e comandos básicos de controle no parser conforme evolução do quadro Kanban.

## Critério de pronto da fase

A fase será considerada concluída quando:

1. o scanner reconhecer corretamente os tokens definidos,
2. o parser validar a gramática do recorte com testes representativos,
3. a documentação estiver coerente com o que foi implementado,
4. o Kanban e os registros de problemas refletirem o andamento real.
