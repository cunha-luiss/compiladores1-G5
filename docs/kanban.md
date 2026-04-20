# Quadro Kanban

## Conexao com GitHub Project

O quadro oficial do time fica no GitHub Project. Esta documentacao usa duas camadas:

1. Fonte de verdade operacional: GitHub Project.
2. Espelho de consulta no site: [kanban-sync.md](./kanban-sync.md).

Board oficial configurado:

- [GitHub Project #2 (cunha-luiss)](https://github.com/users/cunha-luiss/projects/2)

Para ativar sincronizacao automatica da pagina de espelho:

1. Defina o secret: `KANBAN_SYNC_TOKEN`.
2. Execute o workflow `sync-kanban-docs` em Actions.
3. Opcional: se quiser trocar de board no futuro, configure as variaveis `GH_PROJECT_OWNER` e `GH_PROJECT_NUMBER`.

Depois disso, o snapshot sera atualizado automaticamente a cada 6 horas.

## Estrutura recomendada

Colunas:

1. Backlog
2. To Do
3. In Progress
4. Review
5. Done

Regras:

- Definir limite de WIP para In Progress.
- Toda tarefa deve ter responsável, prioridade e data de revisão.
- Itens bloqueados devem registrar motivo e ação de desbloqueio.

## Labels sugeridas

- linguagem
- lexer
- parser
- ast
- docs
- risco
- bug

## Backlog inicial da fase

### Linguagem

- Fechar especificação de sintaxe e semântica básica.
- Definir gramática formal do recorte.
- Validar exemplos mínimos da linguagem.

### Léxico (Flex)

- Consolidar tokens de palavras-chave e operadores.
- Incluir identificadores e literais do recorte.
- Padronizar tratamento de comentários e whitespace.

### Sintático (Bison)

- Evoluir produções para comandos do recorte.
- Associar tokens do scanner às regras.
- Revisar precedência e associatividade.
- Definir ações semânticas para AST inicial.

### Documentação

- Atualizar páginas ao fim de cada revisão semanal do Kanban.
- Garantir alinhamento entre plano e implementação real.

## Definição de pronto para cards

Um card só pode ir para Done quando:

1. objetivo técnico foi concluído;
2. evidência de validação foi registrada;
3. documentação correspondente foi atualizada.
