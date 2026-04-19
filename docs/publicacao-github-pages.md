# Publicação no GitHub Pages

## Pré-requisitos

- Conteúdo da documentação dentro de `docs/`.
- Arquivo de configuração `mkdocs.yml` presente na raiz.
- Dependências instaladas com `requirements-docs.txt`.
- Workflow de deploy presente em `.github/workflows/docs.yml`.

## Teste local antes de publicar

1. Instalar dependências:

```powershell
python -m pip install -r requirements-docs.txt
```

2. Executar servidor local:

```powershell
mkdocs serve
```

3. Executar build estrito:

```powershell
mkdocs build --strict
```

## Publicação recomendada (GitHub Actions)

1. Commit e push das alterações em `docs/`, `mkdocs.yml` e workflow.
2. Abra Pull Request para a branch oficial.
3. Faça merge após revisão.
4. No GitHub, acesse `Settings -> Pages` e selecione `Source: GitHub Actions`.
5. Aguarde a execução do workflow `docs`.

## Publicação manual (alternativa)

Se precisar publicar sem workflow:

```powershell
python -m pip install -r requirements-docs.txt
mkdocs gh-deploy --force
```

Isso envia o site para a branch `gh-pages`.

## Verificações após publicar

- A página inicial abre corretamente.
- Links de navegação funcionam.
- Conteúdo obrigatório do professor está presente.
- Não há divergência entre escopo documentado e progresso real.

## Rotina de manutenção

- Atualizar documentação ao fim de cada revisão semanal do Kanban.
- Revisar links quebrados em cada entrega.
- Registrar novas decisões técnicas e problemas resolvidos.
