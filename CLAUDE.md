@AGENTS.md

## Editing this repository

- `SPEC.md` is the source of truth. A change to the types, components or forbidden
  words touches four places in one commit: `SPEC.md` (sections 3.3, 4, 5 and the
  section 9 regex), the identical regex in `README.md`, `AGENTS.md`, and the lists
  at the top of `scripts/check-repo-name.sh`.
- Run `scripts/check-repo-name.sh --self-test` after every edit. It also checks
  that the README regex matches SPEC.md and that the script agrees with that regex.
- Follow SemVer for the spec (SPEC.md section 11) and add a `CHANGELOG.md` entry.
- This repository is public. Never add private organization, client or customer names.
