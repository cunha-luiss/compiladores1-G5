# Decisões técnicas

## 1. Estratégia de desenvolvimento incremental

Decisão: priorizar uma entrega incremental com foco em linguagem + léxico + sintático antes de avançar para semântica robusta e interpretação completa.

Motivo:

- reduz risco de atrasos nas entregas P1 e P2;
- permite validar rapidamente a base do interpretador;
- cria fundamento estável para as próximas fases.

## 2. Uso de Flex e Bison

Decisão: manter Flex para análise léxica e Bison para análise sintática.

Motivo:

- ferramentas padrão da disciplina;
- separação clara entre responsabilidades (tokenização e parsing);
- boa manutenção da gramática e evolução contínua no Kanban.

## 3. Escopo de linguagem em recorte

Decisão: trabalhar com um subconjunto da linguagem alvo, iniciando por construções essenciais.

Motivo:

- manter o projeto executável no tempo disponível;
- priorizar qualidade e testes sobre quantidade de funcionalidades;
- facilitar depuração em ambiente acadêmico.

## 4. AST como base do interpretador

Decisão: estruturar ações semânticas no parser para construção progressiva da AST.

Motivo:

- simplifica etapas futuras de análise semântica e interpretação;
- evita retrabalho ao sair de parser puramente avaliativo;
- melhora a organização interna do projeto.

## 5. Documentação como artefato de engenharia

Decisão: tratar a documentação em docs/ como artefato obrigatório de acompanhamento no Kanban, não apenas material final.

Motivo:

- aumenta visibilidade do progresso do time;
- facilita review técnico e alinhamento com o professor;
- reduz risco de inconsistência entre implementação e planejamento.

## 6. Ferramental no Windows

Decisão: considerar WinFlexBison no ambiente Windows quando Flex/Bison não estiverem disponíveis nativamente.

Motivo:

- reduzir bloqueios de setup local;
- padronizar instruções de execução para o grupo.
