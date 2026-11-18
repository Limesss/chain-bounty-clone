#!/usr/bin/env bash
#
# Install the bounty-clone standalone skill (prompt-only — no shipped scripts).
# Symlinks this directory into the Claude Code skills dir under the skill's name.
#
# Env overrides:
#   SKILLS_DIR  target skills directory (default: ~/.claude/skills)
#   FORCE       set to 1 to replace a non-symlink dir already at the target

set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"
FORCE="${FORCE:-0}"

say()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; exit 1; }

# ── Pre-flight ──────────────────────────────────────────────────────────────
[[ -f "$SKILL_ROOT/SKILL.md" ]] || die "SKILL.md missing in $SKILL_ROOT"

# Runtime tools the skill drives at use time (not hard install deps; warn only)
command -v git     >/dev/null 2>&1 || warn "'git' not in PATH — needed to clone in-scope repos."
command -v python3 >/dev/null 2>&1 || warn "'python3' not in PATH — handy for one-off bulk source fetch."
command -v cast    >/dev/null 2>&1 || warn "'cast' (foundry) not in PATH — optional for EVM source pulls."
[[ -n "${ETHERSCAN_API_KEY:-}" ]]   || warn "ETHERSCAN_API_KEY unset — Blockscout/Sourcify are keyless; key only for Etherscan-family fallback."

# Skill name from SKILL.md frontmatter
SKILL_NAME="$(awk -F': *' '/^name:/{print $2; exit}' "$SKILL_ROOT/SKILL.md" | tr -d '[:space:]')"
[[ -n "$SKILL_NAME" ]] || die "could not read 'name:' from SKILL.md frontmatter."

# ── Symlink into the skills dir ─────────────────────────────────────────────
mkdir -p "$SKILLS_DIR"
LINK="$SKILLS_DIR/$SKILL_NAME"
if [[ -L "$LINK" ]]; then
    say "replacing existing symlink: $LINK"
elif [[ -e "$LINK" ]]; then
    [[ "$FORCE" == "1" ]] || die "$LINK exists and is not a symlink. Re-run with FORCE=1 to replace it."
    warn "backing up $LINK -> $LINK.bak"; rm -rf "$LINK.bak"; mv "$LINK" "$LINK.bak"
fi
ln -sfn "$SKILL_ROOT" "$LINK"

cat <<EOF

  ✓ installed skill: $SKILL_NAME
    skill dir : $SKILL_ROOT
    symlink   : $LINK -> $SKILL_ROOT

  Start a new Claude Code session, then invoke with:
    /$SKILL_NAME <bounty-program-url> [<target-name>]
EOF
