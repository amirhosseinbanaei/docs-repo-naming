# Repository Naming Convention — Specification 1.0.0

The key words **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT** and **MAY** are to be read as
described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).

## 1. Scope

This specification defines how repositories in a GitHub organization (or personal account) are
named. It applies to every new repository and to every rename. It does not cover branch, tag or
package names.

**Principle:** the name says *what the repository is*, which never changes. Everything that can
change — status, owner, team, stage, confidentiality — lives in
[custom properties](#7-metadata-outside-the-name) and topics, never in the name.

## 2. Character rules

1. A name **MUST** use only lowercase ASCII letters `a–z`, digits `0–9` and the hyphen `-`.
   (GitHub itself also allows uppercase, `_` and `.`; this convention does not.)
2. A name **MUST** be 40 characters or fewer. (GitHub's own limit is 100.)
3. A name **MUST NOT** start or end with a hyphen or contain two hyphens in a row.
4. Words **MUST** be English.
5. A name **MUST NOT** repeat the owner: inside `acme/` write `org-site`, not `acme-org-site`.

## 3. Format

Every name starts with exactly one **type** prefix from [section 4](#4-types). What follows
depends on the type's shape.

### 3.1 Product-shaped types — `client`, `product`, `venture`

```
<type>-<scope>[-<component>]
```

- **scope** — the client, product or venture name as **one token** with no hyphen:
  `moonshot`, not `moon-shot`.
- **component** — optional, **MUST** come from the
  [component list](#5-components). Omit it while the scope has a single repository.

### 3.2 Topic-shaped types — all other types

```
<type>-<topic>
```

- **topic** — what the repository is about, 1–3 words joined by hyphens: `lib-ui`,
  `sample-rag-chatbot`, `docs-incident-playbook`.

### 3.3 Forbidden content

A name **MUST NOT** contain:

- status or age words: `old`, `new`, `final`, `tmp`, `temp`, `copy`, `backup`, `test`;
- versions or dates: `v2`, `2026`;
- division, department or team names (they change; use the `owner-team` property);
- the technology stack (`-react`, `-django`), except where the technology **is** the topic
  (`template-nextjs`, `sample-jwt-auth`).

Use GitHub's **Archive** for retired repositories, **releases and tags** for versions, and
**custom properties** for everything else.

## 4. Types

An organization **MAY** adopt a subset of these types. It **MUST NOT** invent a prefix without
adding it to its own copy of this table.

### A. Work for others

| Prefix | Shape | Use for | Examples |
| :--- | :--- | :--- | :--- |
| `client-` | product | Any paid engagement for an external client — software, sites, AI systems, deliverables, campaigns — including pre-sale proofs of concept. | `client-acme-web`, `client-acme-api`, `client-acme-poc` |
| `showcase-` | topic | Polished portfolio pieces that demonstrate capability publicly. | `showcase-3d-landing`, `showcase-ai-lookbook` |
| `sample-` | topic | Small, focused reference implementations that explain one idea. | `sample-jwt-auth`, `sample-rag-chatbot` |

### B. Own work

| Prefix | Shape | Use for | Examples |
| :--- | :--- | :--- | :--- |
| `org-` | topic | The organization itself: corporate site, brand, handbook, internal operations, legal and HR tooling. | `org-site`, `org-brand`, `org-handbook` |
| `product-` | product | Products and services the organization owns: SaaS, apps, AI products. | `product-nova-web`, `product-nova-api` |
| `venture-` | product | Businesses built from zero that may later spin out as their own company. | `venture-atlas-platform`, `venture-atlas-strategy` |

### C. Shared foundations

| Prefix | Shape | Use for | Examples |
| :--- | :--- | :--- | :--- |
| `lib-` | topic | Shared libraries, packages, SDKs and design-system code. | `lib-ui`, `lib-ai-core`, `lib-auth` |
| `template-` | topic | Starter kits; mark them as GitHub template repositories. | `template-nextjs`, `template-fastapi` |
| `infra-` | topic | Infrastructure as code, CI/CD, servers, cloud, Kubernetes. | `infra-k8s`, `infra-terraform`, `infra-ci` |
| `tool-` | topic | Internal tools, automations, bots, scripts, production pipelines. | `tool-invoice-bot`, `tool-image-pipeline` |

### D. Knowledge and research

| Prefix | Shape | Use for | Examples |
| :--- | :--- | :--- | :--- |
| `docs-` | topic | Knowledge: playbooks, methodologies, architecture decisions, standards. | `docs-engineering`, `docs-incident-playbook` |
| `edu-` | topic | Courses, workshops and training material. | `edu-ai-workshop`, `edu-git-course` |
| `lab-` | topic | R&D, experiments and internal proofs of concept. A lab repository graduates to `product-`/`venture-` or is archived. | `lab-agents`, `lab-voice-clone` |

## 5. Components

Used only by product-shaped types (`client`, `product`, `venture`).

| Component | Meaning |
| :--- | :--- |
| `web` | Web application or frontend |
| `site` | Marketing or informational website |
| `app` | Mobile or desktop application |
| `api` | Backend API or service |
| `admin` | Admin panel or back-office dashboard |
| `worker` | Background jobs and queue consumers |
| `ai` | Models, prompts, agents |
| `data` | Data pipelines, ETL, analytics |
| `sdk` | Developer SDK |
| `cli` | Command-line tool |
| `infra` | Infrastructure for this scope only |
| `design` | Design files and assets |
| `docs` | Documentation for this scope only |
| `campaign` | Marketing or media campaign assets and code |
| `strategy` | Business model, financial model, strategy documents |
| `poc` | Proof of concept or pre-sale demo |
| `platform` | Monorepo holding the whole scope |

An organization **MAY** add a component when none fits; it **MUST** add it to this list in its
own copy before the first repository uses it.

## 6. Names fixed by GitHub or an ecosystem

These names are dictated by a platform, so they take precedence over sections 3–5. Their
type is still recorded in the `type` custom property.

| Name | Required by |
| :--- | :--- |
| `.github` | Organization public profile (`profile/README.md`) and default community health files, issue and PR templates |
| `.github-private` | Organization profile visible only to members |
| `<username>` in the account `<username>` | Personal profile README |
| `<owner>.github.io` | GitHub Pages user or organization site |
| `terraform-<provider>-<name>` | Terraform Registry modules |
| `terraform-provider-<name>` | Terraform Registry providers |
| `homebrew-<name>` | Homebrew taps |
| upstream name | Forks and mirrors keep the upstream repository's name |

## 7. Metadata outside the name

The name is permanent; metadata is not. Organizations **SHOULD** define these repository
[custom properties](https://docs.github.com/en/organizations/managing-organization-settings/managing-custom-properties-for-repositories-in-your-organization)
and **SHOULD** make the required ones mandatory.

| Property | Type | Values | Required |
| :--- | :--- | :--- | :--- |
| `type` | single select | the prefixes in use (`client`, `product`, …) | yes — must equal the prefix |
| `stage` | single select | `idea`, `active`, `production`, `maintenance`, `sunset` | yes |
| `confidentiality` | single select | `public`, `internal`, `confidential` | yes |
| `owner-team` | string | team slug | recommended |
| `client` | string | client legal or display name | for `client-` repositories |
| `business-unit` | multi select | the organization's divisions | optional |

- Use **topics** for the technology stack and search tags (`nextjs`, `python`, `terraform`).
  GitHub topics are lowercase letters, digits and hyphens, at most 50 characters, at most 20 per
  repository, and are always public.
- Rulesets can target custom properties — for example, require reviews and block force pushes
  where `stage = production`.
- Custom properties exist only for organizations. Personal accounts follow sections 2–6 and
  use topics for the metadata.
- Custom properties on a public repository are visible to anyone.

## 8. Lifecycle and renames

1. An idea starts as `lab-<topic>`.
2. When it becomes real, it is renamed or recreated as `product-<scope>[-<component>]` or
   `venture-<scope>[-<component>]`.
3. When a venture becomes its own company, it gets its own GitHub organization. Its repositories
   transfer there and drop the type and scope, which the new organization now carries:
   `acme/venture-atlas-platform` → `atlas/platform`, `acme/venture-atlas-api` → `atlas/api`.
4. Retired repositories are **archived**, never renamed to `*-old`.

Before renaming, know what GitHub redirects:

- Web URLs, issues, wikis, stars, followers and `git clone`/`fetch`/`push` to the old name are
  redirected automatically. Update local remotes anyway: `git remote set-url origin NEW_URL`.
- **GitHub Pages project-site URLs are not redirected.** Use a custom domain before renaming.
- **Workflows using an action hosted in the renamed repository fail** with
  `repository not found`. For a published action, create a new repository and archive the old one.
- **Never reuse an old name** for a new repository: it silently breaks the redirect.

## 9. Validation

A name is shape-valid when it matches this regular expression (PCRE / JavaScript / Python):

```regex
^(?=.{1,40}$)(?!.*(?:^|-)(?:old|new|final|tmp|temp|copy|backup|test|v[0-9]+|[0-9]{4})(?:-|$))(?:(?:client|product|venture)-[a-z0-9]+(?:-(?:web|site|app|api|admin|worker|ai|data|sdk|cli|infra|design|docs|campaign|strategy|poc|platform))?|(?:org|showcase|sample|lib|template|infra|tool|docs|edu|lab)-[a-z0-9]+(?:-[a-z0-9]+){0,2})$
```

Audit an organization (needs the [GitHub CLI](https://cli.github.com/)); names from
[section 6](#6-names-fixed-by-github-or-an-ecosystem) will be listed and can be ignored:

```bash
RE='<the regular expression above>'
gh repo list ORG --limit 1000 --json name --jq '.[].name' | grep -Pv "$RE"
```

The expression checks shape, the 40-character limit and the forbidden words in
[3.3](#33-forbidden-content). It cannot judge meaning — that a `lib-` repository really is a
library — and a forbidden word used legitimately inside a topic (`docs-new-hires`) is rejected
on purpose: rephrase it (`docs-onboarding`). If you trim the type or component lists, trim the
expression to match.

## 10. Decision guide

1. Is the name fixed by GitHub or an ecosystem? → [section 6](#6-names-fixed-by-github-or-an-ecosystem).
2. Is it paid work for someone else? → `client-<scope>[-<component>]`.
3. Is it something the organization sells or runs as a product? → `product-`; as a new business → `venture-`.
4. Is it about the organization itself? → `org-`.
5. Is it reused by other repositories? → `lib-` (code), `template-` (starter), `infra-` (infrastructure), `tool-` (internal tool).
6. Is it meant to teach or demonstrate? → `sample-` (one idea), `showcase-` (portfolio), `edu-` (course).
7. Is it knowledge? → `docs-`. An experiment? → `lab-`.

## 11. Versioning of this specification

This document follows [Semantic Versioning](https://semver.org/): a new **major** version
changes a rule so that compliant names become non-compliant; a **minor** version adds types,
components or guidance; a **patch** fixes wording. See [CHANGELOG.md](CHANGELOG.md).
