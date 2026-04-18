# Estrutura do projeto

## Organização atual do repositório

- `src/`: código-fonte do interpretador (scanner, parser e guias técnicos).
- `docs/`: documentação pública no GitHub Pages.
- `README.md`: visão geral do projeto e fluxo de contribuição.

## Pipeline técnico do interpretador

O fluxo de execução planejado para o projeto é:

1. Código-fonte de entrada.
2. Scanner (Flex) identifica tokens.
3. Parser (Bison) aplica regras gramaticais.
4. AST é construída progressivamente pelas ações semânticas.
5. Etapas futuras podem interpretar a AST diretamente.

## Mapeamento de arquivos relevantes

- `src/scanner.l`: regras léxicas com expressões regulares e retorno de tokens.
- `src/parser.y`: gramática sintática, precedência de operadores e ações semânticas.
- `src/Guia - Projeto de um compilador.md`: referência de macroplanejamento da disciplina.

## Estrutura da documentação

- `index.md`: visão geral e navegação.
- `escopo.md`: fronteira de implementação da fase.
- `decisoes-tecnicas.md`: justificativas das escolhas principais.
- `planejamento-kanban.md`: plano de execução em fluxo contínuo Kanban.
- `kanban.md`: modelo de quadro e backlog inicial.
- `problemas-e-solucoes.md`: histórico vivo de riscos e correções.
- `publicacao-github-pages.md`: passo a passo de publicação.
