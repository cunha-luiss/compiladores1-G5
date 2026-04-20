# Planejamento no Kanban

Este plano organiza o trabalho em fluxo contínuo, usando apenas Kanban e sem divisão por ciclos fixos.

## Modelo de trabalho

- Método principal: Kanban.
- Fluxo: puxado por prioridade do backlog.
- Objetivo: manter entrega contínua e previsível.

## Cadência de acompanhamento

- Daily curta: quartas-feiras para remover bloqueios.
- Review semanal do quadro: validar progresso e repriorizar tarefas.
- Revisão mensal de escopo: confirmar aderência ao que foi combinado.

## Frentes de trabalho no backlog

1. Definição da linguagem interpretada.
2. Análise léxica com Flex.
3. Análise sintática com Bison.
4. Base para geração da AST.
5. Documentação e publicação do site.

## Políticas do Kanban

- Limite de WIP em `In Progress` para evitar multitarefa excessiva.
- Todo card deve ter responsável, prioridade e critério de pronto.
- Card bloqueado deve registrar impedimento e ação de desbloqueio.
- Atualizações de documentação acompanham a conclusão dos cards.

## Critérios de pronto (Definition of Done)

1. Objetivo técnico do card concluído.
2. Evidência de validação registrada.
3. Documentação atualizada quando aplicável.
4. Card movido para `Done` com descrição final do resultado.

## Entregáveis esperados da fase

- Linguagem com escopo formal definido.
- Scanner com tokens essenciais do recorte.
- Parser cobrindo as construções principais do recorte.
- Registro atualizado de decisões técnicas e problemas resolvidos.
- Site em GitHub Pages refletindo o estado real do projeto.
