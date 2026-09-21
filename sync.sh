#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BRANCH=sync/agent-standards
SKILL_DIRS=(.agents/skills .claude/skills)
SYNCED_PATHS=(.claude .agents .codex)
# A skill directory belongs to the sync only when it holds this file; the sync never replaces one without it.
MARKER=.synced-from

usage() {
  cat <<'EOF'
Usage: sync.sh [--check] [owner/repo ...]

Copies each skill in .agents/skills into .agents/skills and .claude/skills of
each target, merges .claude/settings.json, and adds .codex/config.toml. The
sync marks each skill it copies with a .synced-from file and leaves alone any
skill directory of the same name that lacks the file. Targets default
to the lines of targets.txt. Each change arrives as one pull request from
the branch sync/agent-standards.

  --check   Report pending changes per target and write nothing.
            Exits 1 when any target differs.
EOF
}

check=0
targets=()
for arg in "$@"; do
  case "$arg" in
    --check) check=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) usage >&2; exit 2 ;;
    *) targets+=("$arg") ;;
  esac
done
if [[ ${#targets[@]} -eq 0 ]]; then
  mapfile -t targets < <(grep -Ev '^[[:space:]]*(#|$)' "$ROOT/targets.txt")
fi

source_repo=$(git -C "$ROOT" remote get-url origin | sed -E 's#^(git@github\.com:|https://github\.com/)##; s#\.git$##')
source_sha=$(git -C "$ROOT" rev-parse --short HEAD)
if [[ $check -eq 0 && -n $(git -C "$ROOT" status --porcelain -- .agents/skills .claude/settings.json .codex/config.toml) ]]; then
  echo "Commit the source files first: each pull request cites $source_repo@$source_sha." >&2
  exit 2
fi

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

toml_covers() {
  python3 - "$1" "$2" <<'PY'
import sys, tomllib

def covers(source, target):
    return all(
        key in target
        and (covers(value, target[key]) if isinstance(value, dict) else target[key] == value)
        for key, value in source.items()
    )

with open(sys.argv[1], "rb") as s, open(sys.argv[2], "rb") as t:
    sys.exit(0 if covers(tomllib.load(s), tomllib.load(t)) else 1)
PY
}

apply_standards() {
  local dir=$1 skill name dest existing src dst merged
  notes=()

  for dest in "${SKILL_DIRS[@]}"; do
    mkdir -p "$dir/$dest"
    for skill in "$ROOT"/.agents/skills/*/; do
      name=$(basename "$skill")
      if [[ -e $dir/$dest/$name && ! -f $dir/$dest/$name/$MARKER ]]; then
        notes+=("$dest/$name exists and the sync does not own it; the sync left it alone.")
        continue
      fi
      rm -rf "${dir:?}/$dest/$name"
      cp -R "${skill%/}" "$dir/$dest/$name"
      printf '%s\n' "$source_repo" > "$dir/$dest/$name/$MARKER"
    done
    for existing in "$dir/$dest"/*/; do
      [[ -f $existing$MARKER ]] || continue
      name=$(basename "$existing")
      [[ -d $ROOT/.agents/skills/$name ]] || notes+=("$dest/$name has no source skill; delete it by hand.")
    done
  done

  src=$ROOT/.claude/settings.json
  dst=$dir/.claude/settings.json
  if [[ -f $dst ]]; then
    merged=$(jq -s '.[0] * .[1]' "$dst" "$src")
    if [[ $(jq -S . <<<"$merged") != $(jq -S . "$dst") ]]; then
      printf '%s\n' "$merged" > "$dst"
    fi
  else
    cp "$src" "$dst"
  fi

  src=$ROOT/.codex/config.toml
  dst=$dir/.codex/config.toml
  if [[ ! -f $dst ]]; then
    mkdir -p "$dir/.codex"
    cp "$src" "$dst"
  elif ! toml_covers "$src" "$dst"; then
    notes+=(".codex/config.toml exists and lacks the source keys; merge $source_repo/.codex/config.toml by hand.")
  fi
}

pr_body() {
  cat <<EOF
This pull request copies the agent standards from \`$source_repo\` at commit \`$source_sha\`. \`sync.sh\` in that repository generated it.

The skill directories that hold a \`$MARKER\` file under \`.agents/skills\` and \`.claude/skills\` carry the same skills for Codex and Claude Code. \`.claude/settings.json\` turns off Claude Code auto memory and the attribution lines Claude Code adds to commits and pull requests. \`.codex/config.toml\` turns off Codex memories.

\`sync.sh\` replaces each marked skill directory and force-pushes this branch on each run. Make edits in \`$source_repo\`, not here.
EOF
  if [[ ${#notes[@]} -gt 0 ]]; then
    printf '\nThe sync left these items for a person to resolve.\n\n'
    printf '%s\n\n' "${notes[@]}"
  fi
}

drift=0
for repo in "${targets[@]}"; do
  base=$(gh repo view "$repo" --json defaultBranchRef --jq '.defaultBranchRef.name // ""')
  if [[ -z $base ]]; then
    echo "$repo: skipped; the repository has no default branch to open a pull request against."
    continue
  fi

  dir=$workdir/${repo//\//__}
  gh repo clone "$repo" "$dir" -- --depth 1 --quiet
  apply_standards "$dir"
  tracked=()
  for path in "${SYNCED_PATHS[@]}"; do
    if git -C "$dir" check-ignore -q "$path"; then
      notes+=("The target's .gitignore ignores $path; the sync left it out.")
    else
      tracked+=("$path")
    fi
  done
  [[ ${#notes[@]} -eq 0 ]] || printf '%s: note: %s\n' "$repo" "${notes[@]}"
  if [[ ${#tracked[@]} -eq 0 ]]; then
    echo "$repo: skipped; the target's .gitignore ignores every synced path."
    continue
  fi

  if [[ -z $(git -C "$dir" status --porcelain -- "${tracked[@]}") ]]; then
    echo "$repo: in sync with $source_repo@$source_sha."
    continue
  fi
  if [[ $check -eq 1 ]]; then
    drift=1
    echo "$repo: differs from $source_repo@$source_sha:"
    git -C "$dir" status --short --untracked-files=all -- "${tracked[@]}" | sed 's/^/  /'
    continue
  fi

  git -C "$dir" checkout -q -b "$BRANCH"
  git -C "$dir" add -A -- "${tracked[@]}"
  git -C "$dir" commit -q -m "Sync agent standards from $source_repo@$source_sha"

  if git -C "$dir" fetch -q --depth 1 origin "$BRANCH" 2>/dev/null \
    && [[ $(git -C "$dir" rev-parse 'HEAD^{tree}') == $(git -C "$dir" rev-parse 'FETCH_HEAD^{tree}') ]]; then
    echo "$repo: the open sync branch already holds $source_repo@$source_sha."
    continue
  fi

  # The sync owns this branch: a force-push discards any commit a reviewer added to it.
  git -C "$dir" push -q --force origin "$BRANCH"
  url=$(gh pr list --repo "$repo" --head "$BRANCH" --state open --json url --jq '.[0].url // ""')
  if [[ -z $url ]]; then
    url=$(pr_body | gh pr create --repo "$repo" --base "$base" --head "$BRANCH" \
      --title "Sync agent standards from $source_repo@$source_sha" --body-file -)
  else
    pr_body | gh pr edit "$url" --title "Sync agent standards from $source_repo@$source_sha" --body-file - >/dev/null
  fi
  echo "$repo: $url"
done

exit "$drift"
