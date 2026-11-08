# AGENTS.md: Repository Naming Convention

Instructions for AI agents (Claude Code, Codex, Cursor, Copilot, Gemini and
others) that create, name, rename, transfer or review GitHub repositories for an
account or organization that has adopted this convention.

[`SPEC.md`](SPEC.md) is the source of truth (version 1.0.0). This file tells you
how to apply it. If the two disagree, follow `SPEC.md` and report the mismatch.

## When this applies

Apply the convention every time you:

- create a repository (`gh repo create`, the REST/GraphQL API, the GitHub MCP
  server, a template, a fork),
- propose a name for a new project, package or service that will get its own repository,
- rename or transfer a repository,
- review a plan, PR, script or Terraform that creates repositories.

It covers repository names only, not branch, tag or package names.

## The two shapes

```
client | product | venture         →  <type>-<scope>[-<component>]
org | showcase | sample | lib |
template | infra | tool | docs |
edu | lab                         →  <type>-<topic>
```

- **scope**: the client, product or venture as **one token**, no hyphen (`moonshot`, not `moon-shot`).
- **component**: optional, only from this list, omitted while the scope has one repository:
  `web` `site` `app` `api` `admin` `worker` `ai` `data` `sdk` `cli` `infra` `design`
  `docs` `campaign` `strategy` `poc` `platform`.
- **topic**: 1–3 words joined by hyphens (`lib-ui`, `sample-rag-chatbot`).

## Hard rules

1. Only lowercase `a-z`, `0-9` and single hyphens; no leading or trailing hyphen.
2. At most 40 characters.
3. English words only.
4. Never repeat the owner: inside `acme/` write `org-site`, not `acme-org-site`.
5. No status or age words: `old`, `new`, `final`, `tmp`, `temp`, `copy`, `backup`, `test`.
6. No versions (`v2`) or years (`2026`).
7. No team, department or division names.
8. No technology stack unless the technology *is* the topic (`template-nextjs` yes, `product-nova-react` no).

## Choosing the type

Take the first "yes" (SPEC.md section 10):

| # | Question | Name |
|---|---|---|
| 1 | Is the name fixed by GitHub or an ecosystem? | see [Platform names](#platform-names) |
| 2 | Is it paid work for someone else, including a pre-sale POC? | `client-<scope>[-<component>]` |
| 3 | Is it a product or service the owner sells or runs? | `product-<scope>[-<component>]` |
| 4 | Is it a new business that may spin out? | `venture-<scope>[-<component>]` |
| 5 | Is it about the organization itself (site, brand, handbook, ops)? | `org-<topic>` |
| 6 | Is it code reused by other repositories? | `lib-<topic>` |
| 7 | Is it a starter kit? | `template-<topic>` (mark it as a template repository) |
| 8 | Is it infrastructure, CI/CD, cloud, Kubernetes? | `infra-<topic>` |
| 9 | Is it an internal tool, bot, script or pipeline? | `tool-<topic>` |
| 10 | Does it explain one idea in a small example? | `sample-<topic>` |
| 11 | Is it a polished public portfolio piece? | `showcase-<topic>` |
| 12 | Is it a course or workshop? | `edu-<topic>` |
| 13 | Is it knowledge: playbooks, standards, decisions? | `docs-<topic>` |
| 14 | Is it an experiment or internal proof of concept? | `lab-<topic>` |

The owner may have adopted only some types. If their copy of the spec lists fewer
types, use only those. If two types fit equally, or none fits, ask the human.
Never invent a prefix or a component.

## Platform names

These names come from GitHub or another platform, so they override the format:
`.github`, `.github-private`, `<username>` (profile README), `<owner>.github.io`,
`terraform-<provider>-<name>`, `terraform-provider-<name>`, `homebrew-<name>`,
and forks or mirrors, which keep the upstream name.

## Validate before you create

Run the checker on every name you propose. Pass `--owner` so the owner rules apply.

```sh
# inside this repository
scripts/check-repo-name.sh --owner acme client-globex-web

# from anywhere, without cloning
curl -fsSL https://raw.githubusercontent.com/amirhosseinbanaei/repository-naming-structure/main/scripts/check-repo-name.sh \
  | bash -s -- --owner acme client-globex-web
```

Exit `0` means valid and `1` means invalid. Each error comes with a reason. Never
create a repository whose name fails. Fix the name and run the checker again.
Passing the checker does not prove the name is right: still check that the type
matches what the repository actually is.

To audit an existing account (needs an authenticated `gh`):

```sh
scripts/check-repo-name.sh --org acme
```

## After creating a repository

For organizations, set the custom properties from SPEC.md section 7 when the
organization has defined them. `type` must equal the prefix.

```sh
gh api -X PATCH repos/acme/client-globex-web/properties/values --input - <<'JSON'
{"properties":[
  {"property_name":"type","value":"client"},
  {"property_name":"stage","value":"active"},
  {"property_name":"confidentiality","value":"confidential"},
  {"property_name":"client","value":"Globex"}
]}
JSON
```

If the call fails because the properties are not defined, tell the human. Don't
skip it silently. Put the stack in topics (`gh repo edit acme/client-globex-web
--add-topic nextjs`). Remember that topics, and custom properties on public
repositories, are visible to everyone.

Personal accounts have no custom properties. Use topics instead.

## Renames

Rename only when the human asks, and list what will break first:

- GitHub redirects web URLs and git operations, but **GitHub Pages project URLs
  are not redirected**, and **workflows that use an action hosted in the renamed
  repository fail**.
- Local remotes, CI secrets, deploy keys, webhooks and package names do not
  follow automatically. Update them with `git remote set-url origin <new-url>` and similar.
- Never give a new repository an old name. That breaks the redirect.
- Archive retired repositories. Never rename them to `*-old`.
- `lab-x` graduates to `product-x-*` or `venture-x-*`. A spun-out venture moves to its
  own organization and drops the prefix (`acme/venture-atlas-api` → `atlas/api`).

## Examples

| Situation | Name |
|---|---|
| Marketing site for client Globex | `client-globex-site` |
| Globex's backend | `client-globex-api` |
| Pre-sale demo for Initech | `client-initech-poc` |
| Your own SaaS "Nova", frontend | `product-nova-web` |
| Company handbook | `org-handbook` |
| Shared UI kit | `lib-ui` |
| Next.js starter | `template-nextjs` |
| Kubernetes manifests | `infra-k8s` |
| RAG chatbot example | `sample-rag-chatbot` |
| Incident playbook | `docs-incident-playbook` |
| Voice-cloning experiment | `lab-voice-clone` |

| ❌ Wrong | ✅ Right | Why |
|---|---|---|
| `Acme_Website` | `org-site` | case, underscore, no type, repeats the owner |
| `nova-backend-v2` | `product-nova-api` | no type, version |
| `client-globex-website` | `client-globex-site` | `website` is not a component |
| `client-moon-shot-web` | `client-moonshot-web` | scope is one token |
| `lab-agents-2026` | `lab-agents` | no dates |
| `docs-new-hires` | `docs-onboarding` | `new` is forbidden even inside a topic |
