#!/usr/bin/env python3
"""Sync a GitHub Project (v2) snapshot into docs/kanban-sync.md.

Required environment variables:
- GH_TOKEN: GitHub token with access to project data

One of the following project selectors is required:
- GH_PROJECT_OWNER + GH_PROJECT_NUMBER
- GH_PROJECT_URL (example: https://github.com/users/<owner>/projects/<number>)

Optional:
- OUTPUT_FILE: output markdown path (default docs/kanban-sync.md)
"""

from __future__ import annotations

import datetime as dt
import json
import os
import re
import sys
import urllib.error
import urllib.request
from collections import defaultdict
from pathlib import Path

API_URL = "https://api.github.com/graphql"


def now_utc() -> str:
    return dt.datetime.now(dt.UTC).strftime("%Y-%m-%d %H:%M UTC")


def write_file(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def parse_project_url(url: str) -> tuple[str, int] | None:
    pattern = r"^https://github\.com/(?:users|orgs)/([^/]+)/projects/(\d+)(?:/.*)?$"
    match = re.match(pattern, url.strip())
    if not match:
        return None
    return match.group(1), int(match.group(2))


def setup_help(output_path: Path, reason: str, project_url: str = "") -> None:
    content = (
        "# Snapshot do GitHub Project\n\n"
        f"Ultima tentativa de atualizacao: {now_utc()}\n\n"
        f"> Nao foi possivel sincronizar automaticamente: {reason}\n\n"
        "## Como ativar a sincronizacao\n\n"
        "1. Defina o secret do repositorio:\n"
        "   - KANBAN_SYNC_TOKEN\n"
        "2. Execute o workflow `sync-kanban-docs` manualmente.\n"
        "3. Opcional: defina `GH_PROJECT_OWNER` e `GH_PROJECT_NUMBER` para sobrescrever o board padrao.\n"
    )

    if project_url:
        content += (
            "\n## Board configurado\n\n"
            f"- URL: {project_url}\n"
        )

    write_file(output_path, content)


def gql(token: str, query: str, variables: dict) -> dict:
    payload = json.dumps({"query": query, "variables": variables}).encode("utf-8")
    req = urllib.request.Request(
        API_URL,
        data=payload,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "Accept": "application/vnd.github+json",
            "User-Agent": "kanban-docs-sync",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {exc.code}: {body}") from exc


def query_project_nodes(token: str, owner: str, number: int, owner_kind: str) -> tuple[dict, list[dict]]:
    query = f"""
query($owner: String!, $number: Int!, $cursor: String) {{
  {owner_kind}(login: $owner) {{
    projectV2(number: $number) {{
      title
      url
      items(first: 100, after: $cursor) {{
        pageInfo {{
          hasNextPage
          endCursor
        }}
        nodes {{
          fieldValues(first: 20) {{
            nodes {{
              ... on ProjectV2ItemFieldSingleSelectValue {{
                name
                field {{
                  ... on ProjectV2SingleSelectField {{
                    name
                  }}
                }}
              }}
            }}
          }}
          content {{
            __typename
            ... on Issue {{
              title
              url
              state
              number
              repository {{ nameWithOwner }}
            }}
            ... on PullRequest {{
              title
              url
              state
              number
              repository {{ nameWithOwner }}
            }}
            ... on DraftIssue {{
              title
            }}
          }}
        }}
      }}
    }}
  }}
}}
"""

    cursor = None
    nodes: list[dict] = []
    project_meta: dict | None = None

    while True:
        res = gql(token, query, {"owner": owner, "number": number, "cursor": cursor})
        if res.get("errors"):
            raise RuntimeError(json.dumps(res["errors"], ensure_ascii=False))

        owner_obj = ((res.get("data") or {}).get(owner_kind) or {})
        project = owner_obj.get("projectV2")
        if not project:
            return {}, []

        project_meta = {"title": project.get("title", "Projeto"), "url": project.get("url", "")}

        items = project["items"]
        nodes.extend(items.get("nodes") or [])

        page = items.get("pageInfo") or {}
        if not page.get("hasNextPage"):
            break
        cursor = page.get("endCursor")

    return project_meta or {}, nodes


def load_project(token: str, owner: str, number: int) -> tuple[dict, list[dict]]:
    for owner_kind in ("organization", "user"):
        meta, nodes = query_project_nodes(token, owner, number, owner_kind)
        if meta:
            return meta, nodes
    raise RuntimeError("Projeto nao encontrado para owner/numero informado")


def get_status(item: dict) -> str:
    values = ((item.get("fieldValues") or {}).get("nodes") or [])
    for value in values:
        field = (value.get("field") or {}).get("name", "").strip().lower()
        if field in {"status", "estado"} and value.get("name"):
            return value["name"]
    return "Sem status"


def item_title(item: dict) -> str:
    content = item.get("content") or {}
    typename = content.get("__typename")
    if typename == "Issue":
        return f"Issue #{content.get('number')} - {content.get('title', 'Sem titulo')}"
    if typename == "PullRequest":
        return f"PR #{content.get('number')} - {content.get('title', 'Sem titulo')}"
    if typename == "DraftIssue":
        return f"Draft - {content.get('title', 'Sem titulo')}"
    return "Item sem conteudo"


def item_url(item: dict) -> str:
    content = item.get("content") or {}
    return content.get("url", "")


def canonical_status_order(status: str) -> tuple[int, str]:
    order = {
        "backlog": 0,
        "todo": 1,
        "to do": 1,
        "in progress": 2,
        "doing": 2,
        "review": 3,
        "done": 4,
    }
    key = status.strip().lower()
    return (order.get(key, 99), key)


def generate_markdown(meta: dict, nodes: list[dict]) -> str:
    grouped: dict[str, list[dict]] = defaultdict(list)

    for node in nodes:
        grouped[get_status(node)].append(node)

    ordered_statuses = sorted(grouped.keys(), key=canonical_status_order)

    lines: list[str] = []
    lines.append("# Snapshot do GitHub Project")
    lines.append("")
    lines.append(f"Atualizado automaticamente em: {now_utc()}")
    lines.append("")
    lines.append(f"Projeto de origem: [{meta['title']}]({meta['url']})")
    lines.append("")
    lines.append("> Esta pagina e sincronizada por workflow e serve como ponte entre o GitHub Project e o site de documentacao.")
    lines.append("")
    lines.append("## Quantidade por status")
    lines.append("")
    lines.append("| Status | Itens |")
    lines.append("| --- | ---: |")
    for status in ordered_statuses:
        lines.append(f"| {status} | {len(grouped[status])} |")

    lines.append("")
    lines.append("## Itens por status")
    lines.append("")

    for status in ordered_statuses:
        lines.append(f"### {status}")
        lines.append("")
        items = sorted(grouped[status], key=lambda i: item_title(i).lower())
        if not items:
            lines.append("- Nenhum item")
            lines.append("")
            continue

        for node in items:
            title = item_title(node)
            url = item_url(node)
            if url:
                lines.append(f"- [{title}]({url})")
            else:
                lines.append(f"- {title}")
        lines.append("")

    return "\n".join(lines).strip() + "\n"


def main() -> int:
    token = os.getenv("GH_TOKEN", "").strip()
    owner = os.getenv("GH_PROJECT_OWNER", "").strip()
    number_raw = os.getenv("GH_PROJECT_NUMBER", "").strip()
    project_url = os.getenv("GH_PROJECT_URL", "").strip()
    output = Path(os.getenv("OUTPUT_FILE", "docs/kanban-sync.md"))

    if not token:
        setup_help(output, "faltam variaveis/secret obrigatorios", project_url)
        return 0

    number: int | None = None

    if owner and number_raw:
        try:
            number = int(number_raw)
        except ValueError:
            setup_help(output, "GH_PROJECT_NUMBER invalido", project_url)
            return 0
    elif project_url:
        parsed = parse_project_url(project_url)
        if not parsed:
            setup_help(output, "GH_PROJECT_URL invalida", project_url)
            return 0
        owner, number = parsed
    else:
        setup_help(output, "faltam variaveis de projeto", project_url)
        return 0

    try:
        meta, nodes = load_project(token, owner, number)
        write_file(output, generate_markdown(meta, nodes))
    except Exception as exc:  # pylint: disable=broad-except
        setup_help(output, str(exc), project_url)

    return 0


if __name__ == "__main__":
    sys.exit(main())
