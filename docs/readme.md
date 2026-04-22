# Documentação do Interpretador

Este diretório contém a documentação oficial do plano de implementação do interpretador, publicada com MkDocs Material no GitHub Pages.

## Itens obrigatórios

- Estrutura do projeto
- Decisões técnicas
- Planejamento no Kanban
- Problemas encontrados e soluções adotadas

## Navegação

- Página inicial: [index.md](./index.md)
- Escopo da fase: [escopo.md](./escopo.md)
- Estrutura do projeto: [estrutura-do-projeto.md](./estrutura-do-projeto.md)
- Decisões técnicas: [decisoes-tecnicas.md](./decisoes-tecnicas.md)
- Planejamento no Kanban: [planejamento-kanban.md](./planejamento-kanban.md)
- Quadro Kanban: [kanban](https://github.com/users/cunha-luiss/projects/2)
- Problemas e soluções: [problemas-e-solucoes.md](./problemas-e-solucoes.md)

## Stack da documentação

- Gerador do site: MkDocs
- Tema: Material for MkDocs
- Configuração principal: `mkdocs.yml` na raiz do repositório
- Dependências de docs: `requirements-docs.txt`

## Política de atualização

Ao final de cada revisão semanal do Kanban, atualizar no mínimo:

1. progresso das tarefas no quadro,
2. mudanças de escopo da fase,
3. problemas identificados e soluções adotadas.

## Funções de teste do Pages

Use estas funções antes de cada publicação:


### 1. Teste local do site

Instalar dependências de documentação:

```powershell
python -m pip install -r requirements-docs.txt
```

Subir ambiente local de documentação:

```powershell
mkdocs serve
```

### 2. Teste de build estrito

Executar build com validação de links e estrutura de navegação:

```powershell
mkdocs build --strict
```

### 3. Teste de consistência de conteúdo

Antes do merge, conferir se os quatro tópicos exigidos pelo professor estão presentes:

- Estrutura do projeto
- Decisões técnicas
- Planejamento no Kanban
- Problemas encontrados e soluções adotadas

## Funções de lançamento do Pages

### 1. Publicar alterações de documentação

Comandos sugeridos:

```powershell
git checkout -b docs/pages-atualizacao
git add docs mkdocs.yml requirements-docs.txt .github/workflows/docs.yml
git commit -m "docs(mkdocs): atualiza site e pipeline de pages"
git push origin docs/pages-atualizacao
```

Depois disso:

1. abrir Pull Request para a branch oficial do projeto;
2. revisar e aprovar mudanças;
3. fazer merge.

### 2. Configurar o GitHub Pages

No repositório do GitHub:

1. acessar `Settings`;
2. abrir `Pages`;
3. em `Build and deployment`, selecionar `Source: GitHub Actions`;
4. salvar.

O deploy passa a ser feito automaticamente pelo workflow em `.github/workflows/docs.yml`.

### 3. Validar lançamento

Após o deploy:

1. abrir a URL publicada do GitHub Pages;
2. validar navegação entre as páginas;
3. confirmar conteúdo atualizado;
4. registrar qualquer problema em `problemas-e-solucoes.md`.