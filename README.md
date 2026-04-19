# **Compiladores1-G5**

## **Pontos de Controle (P1 e P2):**  
   - **P1:** A equipe apresenta:
     - Definição do projeto
     - Linguagem de programação escolhida
  - Planejamento no método Kanban
     - O que foi implementado
   - **P2:** Avaliação do progresso, incluindo:
     - Funcionalidades principais desenvolvidas
     - Melhorias desde o P1
     - Ajustes no planejamento

## Commits

Formato:
```
<type>[optional scope]!: <short summary>

[body]
```
Tipos comuns: `feat`, `fix`, `docs`, `style`, `refactor`, `build`, `ci`, `add`, `revert`.

Ex.: `feat(api): adiciona rota de login`.

## Branches

Formato:
```
<type>/<short summary>-<author name>
```
Tipos comuns: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.

Ex.: `feat/AdicionaRotaDeLogin-EnzoGabriel`.

## Contribuição

Siga o workflow abaixo para contribuir:

1. Crie uma branch a partir da `development`:
    ```bash
    git checkout dev
    git pull
    git checkout -b tipo/SuaFeature-SeuNome
    ```

2. Faça suas alterações e commits na nova branch.

3. Envie sua branch para o repositório remoto:
    ```bash
    git push origin tipo/SuaFeature-SeuNome
    ```
4. Abra um Pull Request (PR) da sua branch para a branch `dev` (só ir no site e colocar Base: dev <-- compare: sua-feature).

## Documentação (MkDocs Material)

O site de documentação usa MkDocs com tema Material.

### Rodar localmente

```bash
python -m pip install -r requirements-docs.txt
mkdocs serve
```

### Validar build

```bash
mkdocs build --strict
```

### Publicar no GitHub Pages

O deploy é automático pelo workflow `.github/workflows/docs.yml`.
No GitHub, configure `Settings -> Pages -> Source: GitHub Actions`.

**Desenvolvido para Compiladores 1 FCTE-UnB 2026-1** 🎓