# Problemas encontrados e soluções adotadas

Esta página deve ser mantida viva durante o projeto.

## Registro de riscos iniciais

### 1. Ferramentas Flex/Bison ausentes no Windows

Impacto:

- bloqueia geração de scanner e parser localmente.

Solução adotada:

- usar WinFlexBison quando necessário;
- documentar instalação e configuração de PATH para toda equipe.

Status: Aberto (monitoramento contínuo).

### 2. Escopo amplo demais para o tempo da disciplina

Impacto:

- risco de atraso e entregas incompletas.

Solução adotada:

- limitar fase atual a linguagem + léxico + sintático + base de AST;
- registrar explicitamente itens fora de escopo.

Status: Em mitigação.

### 3. Divergência entre documentação e implementação

Impacto:

- perda de rastreabilidade e inconsistência em apresentações.

Solução adotada:

- atualizar docs ao fim de cada revisão semanal do Kanban;
- revisar Kanban e páginas obrigatórias na review semanal.

Status: Em mitigação.

## Template para novos problemas

Use o formato abaixo para cada novo registro:

- Problema:
- Causa provável:
- Impacto:
- Solução adotada:
- Dono:
- Status:
- Data de registro:
