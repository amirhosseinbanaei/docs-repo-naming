#!/usr/bin/env bash
# check-repo-name.sh: check GitHub repository names against the Repository
# Naming Convention (SPEC.md). Works on bash 3.2+ (macOS) and Linux, no deps
# except the GitHub CLI for --org.
#
# Keep PRODUCT_TYPES, TOPIC_TYPES, COMPONENTS and FORBIDDEN in sync with
# SPEC.md sections 3.3, 4 and 5. `--self-test` cross-checks this script against
# the regular expression in SPEC.md section 9 when SPEC.md is next to it.

SPEC_VERSION="1.0.0"
PRODUCT_TYPES="client product venture"
TOPIC_TYPES="org showcase sample lib template infra tool docs edu lab"
COMPONENTS="web site app api admin worker ai data sdk cli infra design docs campaign strategy poc platform"
FORBIDDEN="old new final tmp temp copy backup test"
MAX_LEN=40

usage() {
  cat <<EOF
check-repo-name.sh: Repository Naming Convention $SPEC_VERSION

Usage:
  check-repo-name.sh [--owner OWNER] NAME...   check one or more names
  check-repo-name.sh --org OWNER               audit every repository of an
                                               organization or user (needs gh)
  check-repo-name.sh --self-test               run the built-in tests
  check-repo-name.sh --help

Options:
  --owner OWNER   the account the repositories live in. Enables the owner
                  rules: no repeating the owner, <owner>.github.io, and the
                  <owner> profile repository.
  --quiet         print only invalid names.

Exit status: 0 = all valid, 1 = at least one invalid, 2 = usage error.

Format:
  client|product|venture-<scope>[-<component>]
  org|showcase|sample|lib|template|infra|tool|docs|edu|lab-<topic of 1-3 words>
EOF
}

# ---------------------------------------------------------------- output
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_OK=$'\033[32m'; C_BAD=$'\033[31m'; C_EX=$'\033[36m'; C_DIM=$'\033[2m'; C_B=$'\033[1m'; C_0=$'\033[0m'
else
  C_OK=""; C_BAD=""; C_EX=""; C_DIM=""; C_B=""; C_0=""
fi
QUIET=0

in_list() { # word "list of words"
  local w=$1 x
  for x in $2; do [ "$x" = "$w" ] && return 0; done
  return 1
}

lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

# Lowercase, turn _ . and spaces into hyphens, squeeze and trim hyphens.
normalize() {
  lower "$1" | sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//'
}

# exemption <name> <owner> -> prints a reason and returns 0 if the name is fixed
# by GitHub or an ecosystem (SPEC.md section 6).
exemption() {
  local name=$1 owner lname
  owner=$(lower "$2"); lname=$(lower "$1")
  case "$name" in
    .github)         echo "organization profile and community files"; return 0 ;;
    .github-private) echo "members-only organization profile"; return 0 ;;
  esac
  if [ -n "$owner" ] && [ "$lname" = "$owner" ]; then
    echo "personal profile README"; return 0
  fi
  if [[ $lname =~ ^[a-z0-9-]+\.github\.io$ ]]; then
    if [ -z "$owner" ] || [ "$lname" = "$owner.github.io" ]; then
      echo "GitHub Pages site"; return 0
    fi
    return 1
  fi
  if [[ $name =~ ^terraform-provider-[a-z0-9-]+$ ]]; then echo "Terraform Registry provider"; return 0; fi
  if [[ $name =~ ^terraform-[a-z0-9]+-[a-z0-9-]+$ ]]; then echo "Terraform Registry module"; return 0; fi
  if [[ $name =~ ^homebrew-[a-z0-9-]+$ ]]; then echo "Homebrew tap"; return 0; fi
  return 1
}

# check_one <name> [owner] [note] -> prints the verdict, returns 0 valid / 1 invalid
check_one() {
  local name=$1 owner=${2:-} note=${3:-} reason
  local errs=() hints=()
  local lowner; lowner=$(lower "$owner")

  if reason=$(exemption "$name" "$owner"); then
    [ $QUIET -eq 0 ] && printf '%s◆%s %s %s(%s%s)%s\n' "$C_EX" "$C_0" "$name" "$C_DIM" "$reason" "${note:+, $note}" "$C_0"
    return 0
  fi

  # 2. character rules
  if [[ $(lower "$name") =~ \.github\.io$ ]]; then
    errs+=("a Pages site in this account must be named exactly $owner.github.io")
  fi
  [ ${#name} -gt $MAX_LEN ] && errs+=("${#name} characters; the limit is $MAX_LEN")
  if ! [[ $name =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    local bad=()
    [[ $name =~ [A-Z] ]] && bad+=("uppercase letters")
    [[ $name == *_* ]] && bad+=("underscores")
    [[ $name == *.* ]] && bad+=("dots")
    [[ $name == *--* ]] && bad+=("double hyphens")
    [[ $name == -* || $name == *- ]] && bad+=("a leading or trailing hyphen")
    [[ $name =~ [^A-Za-z0-9._-] ]] && bad+=("characters outside a-z 0-9 -")
    local found="" b
    for b in "${bad[@]}"; do found="${found:+$found, }$b"; done
    errs+=("only lowercase a-z, 0-9 and single hyphens are allowed; found $found")
    local fixed; fixed=$(normalize "$name")
    [ -n "$fixed" ] && [ "$fixed" != "$name" ] && hints+=("characters fixed: $fixed")
  fi

  # 3. format
  local seg=() s
  local OLDIFS=$IFS; IFS=-; read -r -a seg <<< "$(normalize "$name")"; IFS=$OLDIFS
  local n=${#seg[@]} type=${seg[0]:-}

  if in_list "$type" "$PRODUCT_TYPES"; then
    if [ "$n" -lt 2 ]; then
      errs+=("'$type' needs a scope: $type-<scope>[-<component>]")
    elif [ "$n" -gt 3 ]; then
      errs+=("'$type' names are $type-<scope>[-<component>]; write the scope as one token without hyphens")
    elif [ "$n" -eq 3 ] && ! in_list "${seg[2]}" "$COMPONENTS"; then
      errs+=("'${seg[2]}' is not a component. Use one of: ${COMPONENTS// /, }. If it is part of the scope, write the scope as one token")
    fi
  elif in_list "$type" "$TOPIC_TYPES"; then
    if [ "$n" -lt 2 ]; then
      errs+=("'$type' needs a topic: $type-<topic>")
    elif [ "$n" -gt 4 ]; then
      errs+=("the topic has $((n - 1)) words; the limit is 3")
    fi
  else
    errs+=("no type prefix. Start with one of: ${PRODUCT_TYPES// /, }, ${TOPIC_TYPES// /, }")
  fi

  # 3.3 forbidden content
  for s in "${seg[@]}"; do
    if in_list "$s" "$FORBIDDEN"; then
      errs+=("'$s' is a status word: archive retired repositories, rephrase the rest")
    elif [[ $s =~ ^v[0-9]+$ ]]; then
      errs+=("'$s' is a version: use releases and tags")
    elif [[ $s =~ ^[0-9]{4}$ ]]; then
      errs+=("'$s' looks like a year: dates belong in releases or properties")
    fi
  done

  # 2.5 never repeat the owner
  if [ -n "$lowner" ] && [[ -$(normalize "$name")- == *-$lowner-* ]]; then
    errs+=("repeats the owner '$owner': the account already says it")
  fi

  if [ ${#errs[@]} -eq 0 ]; then
    [ $QUIET -eq 0 ] && printf '%s✔%s %s%s\n' "$C_OK" "$C_0" "$name" "${note:+ $C_DIM($note)$C_0}"
    return 0
  fi
  printf '%s✖%s %s%s%s%s\n' "$C_BAD" "$C_0" "$C_B" "$name" "$C_0" "${note:+ $C_DIM($note)$C_0}"
  for s in "${errs[@]}"; do printf '    • %s\n' "$s"; done
  if [ ${#hints[@]} -gt 0 ]; then
    for s in "${hints[@]}"; do printf '    %s→ %s%s\n' "$C_DIM" "$s" "$C_0"; done
  fi
  return 1
}

# ---------------------------------------------------------------- audit
audit() {
  local owner=$1
  command -v gh >/dev/null 2>&1 || { echo "--org needs the GitHub CLI: https://cli.github.com/" >&2; exit 2; }
  local rows
  rows=$(gh repo list "$owner" --limit 1000 --json name,isFork,isArchived \
    --jq '.[] | [.name, (.isFork|tostring), (.isArchived|tostring)] | @tsv') || exit 2
  local total=0 bad=0 name fork archived note
  while IFS=$'\t' read -r name fork archived; do
    [ -z "$name" ] && continue
    total=$((total + 1))
    note=""; [ "$archived" = "true" ] && note="archived"
    if [ "$fork" = "true" ]; then
      [ $QUIET -eq 0 ] && printf '%s◆%s %s %s(fork keeps the upstream name)%s\n' "$C_EX" "$C_0" "$name" "$C_DIM" "$C_0"
      continue
    fi
    check_one "$name" "$owner" "$note" || bad=$((bad + 1))
  done <<< "$rows"
  echo
  if [ $bad -eq 0 ]; then
    printf '%s%s: all %d repositories follow the convention.%s\n' "$C_OK" "$owner" "$total" "$C_0"
    return 0
  fi
  printf '%s%s: %d of %d repositories need a new name.%s Read SPEC.md section 8 before renaming.\n' \
    "$C_BAD" "$owner" "$bad" "$total" "$C_0"
  return 1
}

# ---------------------------------------------------------------- self-test
self_test() {
  local fails=0 total=0 expect owner name got
  QUIET=1
  local cases='
ok   - client-acme-web
ok   - client-acme
ok   - client-acme-poc
ok   - product-nova-api
ok   - venture-atlas-platform
ok   - venture-atlas-strategy
ok   - org-site
ok   - lib-ui
ok   - lib-ai-core
ok   - sample-jwt-auth
ok   - sample-rag-chatbot
ok   - docs-incident-playbook
ok   - lab-voice-clone
ok   - infra-k8s
ok   - template-nextjs
ok   - edu-git-course
ok   - showcase-3d-landing
ok   - tool-invoice-bot
ok   - docs-a-b-c
ok   - .github
ok   - .github-private
ok   - terraform-aws-vpc
ok   - terraform-provider-acme
ok   - homebrew-tools
ok   - octo.github.io
ok   octo octo
ok   octo octo.github.io
ok   acme org-site
fail - Acme_Website
fail - nova-backend-v2
fail - acme-shared-ui-library
fail - devops-team-terraform
fail - voice-clone-test-old
fail - venture-atlas-monorepo-react
fail - client-acme-website
fail - client-moon-shot-web
fail - client
fail - lib
fail - docs-a-b-c-d
fail - lib-ui-v2
fail - lab-agents-2026
fail - docs-new-hires
fail - tool-backup
fail - client--acme
fail - -client-acme
fail - client-acme-
fail - lib.ui
fail - product-averyveryverylongscopenameforrepo-api
fail acme acme-org-site
fail acme lib-acme-ui
fail octo other.github.io
'
  while read -r expect owner name; do
    [ -z "$name" ] && continue
    [ "$owner" = "-" ] && owner=""
    total=$((total + 1))
    if check_one "$name" "$owner" >/dev/null; then got=ok; else got=fail; fi
    if [ "$got" != "$expect" ]; then
      echo "self-test: expected $expect for '$name'${owner:+ (owner $owner)}, got $got"
      fails=$((fails + 1))
    fi
  done <<< "$cases"
  echo "self-test: $((total - fails))/$total rule cases pass"

  # Cross-check against the regular expression in SPEC.md section 9 and the copy in README.md.
  local dir spec_re readme_re
  dir=$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)
  if [ -n "$dir" ] && [ -f "$dir/SPEC.md" ] && echo x | grep -P x >/dev/null 2>&1; then
    spec_re=$(grep -m1 '^\^(?=' "$dir/SPEC.md")
    if [ -f "$dir/README.md" ]; then
      readme_re=$(sed -n "s/^RE='\(.*\)'\$/\1/p" "$dir/README.md" | head -n1)
      if [ "$readme_re" != "$spec_re" ]; then
        echo "self-test: the regular expression in README.md differs from SPEC.md section 9"
        fails=$((fails + 1))
      fi
    fi
    local checked=0 re_ok
    while read -r expect owner name; do
      [ -z "$name" ] || [ "$owner" != "-" ] && continue
      exemption "$name" "" >/dev/null && continue
      if printf '%s\n' "$name" | grep -qP "$spec_re"; then re_ok=ok; else re_ok=fail; fi
      checked=$((checked + 1))
      if [ "$re_ok" != "$expect" ]; then
        echo "self-test: SPEC.md regex says $re_ok for '$name', script expects $expect"
        fails=$((fails + 1))
      fi
    done <<< "$cases"
    echo "self-test: $checked cases agree with the SPEC.md regular expression"
  else
    echo "self-test: SPEC.md or grep -P not available; regex cross-check skipped"
  fi

  [ $fails -eq 0 ] && { echo "self-test: passed"; return 0; }
  echo "self-test: $fails failure(s)"; return 1
}

# ---------------------------------------------------------------- main
OWNER=""; ORG=""; NAMES=()
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)   usage; exit 0 ;;
    --self-test) self_test; exit $? ;;
    --owner)     [ $# -ge 2 ] || { usage >&2; exit 2; }; OWNER=$2; shift ;;
    --org)       [ $# -ge 2 ] || { usage >&2; exit 2; }; ORG=$2; shift ;;
    --quiet)     QUIET=1 ;;
    --)          shift; while [ $# -gt 0 ]; do NAMES+=("$1"); shift; done; break ;;
    -*)          echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    *)           NAMES+=("$1") ;;
  esac
  shift
done

if [ -n "$ORG" ]; then audit "$ORG"; exit $?; fi
[ ${#NAMES[@]} -eq 0 ] && { usage >&2; exit 2; }

status=0
for name in "${NAMES[@]}"; do check_one "$name" "$OWNER" || status=1; done
exit $status
