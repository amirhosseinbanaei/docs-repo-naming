<div align="center">

# Repository Naming Convention

**Name a repository once, and anyone can tell what it is from the name alone.**

A naming standard for GitHub repositories that stays readable from 10 repositories
to 1,000. It also works for AI agents: they can follow the rules and check their
own names before they create anything.

[![Spec](https://img.shields.io/badge/spec-1.0.0-2563eb)](SPEC.md)
[![RFC 2119](https://img.shields.io/badge/wording-RFC%202119-6b7280)](https://www.rfc-editor.org/rfc/rfc2119)
[![Agents](https://img.shields.io/badge/AI%20agents-AGENTS.md%20%2B%20CLAUDE.md-8b5cf6)](AGENTS.md)
[![Checker](https://img.shields.io/badge/checker-bash%203.2%2B-16a34a)](scripts/check-repo-name.sh)

```
<type>-<scope>[-<component>]     client-acme-web · product-nova-api · venture-atlas-platform
<type>-<topic>                   lib-ui · infra-k8s · sample-rag-chatbot · docs-engineering
```

</div>

---

## The problem

Every organization ends up with a repository list like this:

```text
Website            website-new          api_v2              old-backend
nova               nova-FINAL           test-repo-2          shared
frontend-react     johns-experiment     acme-acme-site       infra-stuff
```

Which one is live? Which one is a client's? Which one can you delete? Nobody
knows, so nobody deletes anything.

## The fix

```text
client-globex-site      client-globex-api       product-nova-web       product-nova-api
org-site                lib-ui                  infra-k8s              tool-invoice-bot
docs-engineering        sample-rag-chatbot      lab-voice-clone        template-nextjs
```

The **name** says what the repository is, which never changes. Everything that
does change, such as stage, team, owner and confidentiality, goes in GitHub
**custom properties** and **topics**, so you never have to rename for it.

## Try it in 10 seconds

No install, no clone. Check any name:

```bash
curl -fsSL https://raw.githubusercontent.com/amirhosseinbanaei/repository-naming-structure/main/scripts/check-repo-name.sh \
  | bash -s -- --owner acme client-globex-web Acme_Website product-nova-api-v2 lib-ui .github
```

```text
✔ client-globex-web
✖ Acme_Website
    • only lowercase a-z, 0-9 and single hyphens are allowed; found uppercase letters, underscores
    • no type prefix. Start with one of: client, product, venture, org, showcase, sample, lib, template, infra, tool, docs, edu, lab
    • repeats the owner 'acme': the account already says it
    → characters fixed: acme-website
✖ product-nova-api-v2
    • 'product' names are product-<scope>[-<component>]; write the scope as one token without hyphens
    • 'v2' is a version: use releases and tags
✔ lib-ui
◆ .github (organization profile and community files)
```

Audit a whole organization or account with the [GitHub CLI](https://cli.github.com/):

```bash
curl -fsSL https://raw.githubusercontent.com/amirhosseinbanaei/repository-naming-structure/main/scripts/check-repo-name.sh \
  | bash -s -- --org YOUR_ORG
```

## The rules in one minute

1. Use lowercase ASCII letters, digits and hyphens only, in English, with at most 40 characters.
2. Every name starts with exactly one **type** prefix.
3. `client`, `product` and `venture` names are `<type>-<scope>[-<component>]`. The scope is one
   token, and the component comes from a fixed list (`web`, `api`, `app`, `admin`, `worker`, …).
4. All other types are `<type>-<topic>`, where the topic is 1–3 words.
5. Don't put status, versions, dates, teams or the owner's name in a name. Archive retired
   repositories, use releases for versions, and use custom properties for the rest.
6. Names that GitHub or an ecosystem dictates (`.github`, `<owner>.github.io`,
   `terraform-<provider>-<name>`, `homebrew-<name>`, forks) take precedence.

## Types

| Group | Prefixes |
| :--- | :--- |
| 🤝 Work for others | `client-` · `showcase-` · `sample-` |
| 🏢 Own work | `org-` · `product-` · `venture-` |
| 🧱 Shared foundations | `lib-` · `template-` · `infra-` · `tool-` |
| 📚 Knowledge and research | `docs-` · `edu-` · `lab-` |

An organization can adopt only the types it needs. A company without clients might use only
`product`, `lib`, `infra`, `tool`, `docs` and `lab`.

**Not sure which one?** Take the first "yes": fixed by a platform? → paid work for someone? →
something you sell? → a new business? → about the organization itself? → reused code? → teaching
or demo? → knowledge? → experiment? The full guide is in [SPEC.md § 10](SPEC.md#10-decision-guide).

## Examples

| ✅ Good | ❌ Bad | Why |
| :--- | :--- | :--- |
| `client-acme-web` | `Acme_Website` | uppercase, underscore, no type |
| `product-nova-api` | `nova-backend-v2` | no type, version in the name |
| `lib-ui` | `acme-shared-ui-library` | repeats the owner, too long |
| `infra-terraform` | `devops-team-terraform` | team names change |
| `lab-voice-clone` | `voice-clone-test-old` | status words; archive instead |
| `venture-atlas-platform` | `venture-atlas-monorepo-react` | `platform` is the component; stack goes in topics |

## 🤖 Built for AI agents

AI coding agents create repositories all the time, and left alone they name them
`my-app`, `project-new` or `test-2`. This repository gives them rules they can
follow:

| File | Read by | What it does |
| :--- | :--- | :--- |
| [`AGENTS.md`](AGENTS.md) | Codex, Cursor, Copilot, Gemini and other agents | When the rules apply, a type decision table, the hard rules, validation, custom properties, safe renames |
| [`CLAUDE.md`](CLAUDE.md) | Claude Code | Imports `AGENTS.md`, plus rules for editing this repository |
| [`scripts/check-repo-name.sh`](scripts/check-repo-name.sh) | everyone | The checker: exit `0` valid, `1` invalid, with a reason for each error |

To make agents follow the convention **in your own projects**, paste this into
that project's `AGENTS.md` or `CLAUDE.md`, or into `~/.claude/CLAUDE.md` to apply
it everywhere:

```markdown
## Repository naming

Before creating, naming or renaming any GitHub repository, read and follow
https://raw.githubusercontent.com/amirhosseinbanaei/repository-naming-structure/main/AGENTS.md
and validate every proposed name first:

    curl -fsSL https://raw.githubusercontent.com/amirhosseinbanaei/repository-naming-structure/main/scripts/check-repo-name.sh \
      | bash -s -- --owner <owner> <name>

Never create a repository whose name fails the check.
```

## Check your organization with one regex

Prefer a single regular expression? It does the same shape check as the script:

```bash
RE='^(?=.{1,40}$)(?!.*(?:^|-)(?:old|new|final|tmp|temp|copy|backup|test|v[0-9]+|[0-9]{4})(?:-|$))(?:(?:client|product|venture)-[a-z0-9]+(?:-(?:web|site|app|api|admin|worker|ai|data|sdk|cli|infra|design|docs|campaign|strategy|poc|platform))?|(?:org|showcase|sample|lib|template|infra|tool|docs|edu|lab)-[a-z0-9]+(?:-[a-z0-9]+){0,2})$'
gh repo list ORG --limit 1000 --json name --jq '.[].name' | grep -Pv "$RE"
```

It prints every repository name that doesn't comply. Names fixed by GitHub or an
ecosystem show up too, and you can ignore those. The script recognizes them, as well
as forks and the owner rule. See [SPEC.md § 9](SPEC.md#9-validation) for what the
check can and can't catch.

## Adopting it

1. Copy [SPEC.md](SPEC.md) into your organization, for example into `docs-engineering`, and
   delete the types and components you don't use. Trim the lists at the top of
   `scripts/check-repo-name.sh` to match.
2. Create the custom properties from [SPEC.md § 7](SPEC.md#7-metadata-outside-the-name) and
   make `type`, `stage` and `confidentiality` required.
3. Add the agent block above to your projects so AI agents follow the rules too.
4. Name every new repository by the spec. Rename old ones only after reading
   [SPEC.md § 8](SPEC.md#8-lifecycle-and-renames): Pages URLs and Actions are not redirected.

## Contents

| File | What it holds |
| :--- | :--- |
| [SPEC.md](SPEC.md) | The normative specification: format, types, components, exceptions, metadata, lifecycle, validation |
| [AGENTS.md](AGENTS.md) | How AI agents apply the specification |
| [CLAUDE.md](CLAUDE.md) | Claude Code entry point |
| [scripts/check-repo-name.sh](scripts/check-repo-name.sh) | Name checker and organization audit (`--help`, `--self-test`) |
| [CHANGELOG.md](CHANGELOG.md) | Versions of the specification |

## Contributing

Issues and pull requests are welcome. Any change to the types, components or forbidden words
must update `SPEC.md`, the regex in this README, `AGENTS.md` and the checker in the same pull
request. `scripts/check-repo-name.sh --self-test` checks that they still agree.
