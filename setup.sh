#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$REPO_DIR/.env"
USER_SKILLS_DIR="$HOME/.claude/skills"
USAGE_LOG="$HOME/.claude/skill-usage.log"
FEEDBACK_LOG="$HOME/.claude/skill-feedback.log"

# --- Source environment ---
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  echo "Loaded config from $ENV_FILE"
else
  echo "No .env found — generating from .env.example"
  cp "$REPO_DIR/.env.example" "$ENV_FILE"
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  echo "Created $ENV_FILE — edit it for your environment, then re-run."
  exit 0
fi

PROJECTS_DIR="${PROJECTS_DIR:-$HOME/projects}"
GITHUB_ORG="${GITHUB_ORG:-}"

# Project mappings: repo subdir → target project dir.
# Add your own project-scoped skill directories here.
# Example:
#   [myproject]="$PROJECTS_DIR/myproject"
declare -A PROJECTS=(
  # [myproject]="$PROJECTS_DIR/myproject"
)

echo ""
echo "=== Claude Skills Setup ==="
echo "Repo:     $REPO_DIR"
echo "Projects: $PROJECTS_DIR"
echo ""

# --- Validate SKILL.md files (agentskills.io spec) ---
echo "--- Validating SKILL.md files (agentskills.io spec) ---"
errors=0
for skill_file in $(find "$REPO_DIR" -name "SKILL.md" -not -path "*/node_modules/*" -not -path "*/archive/*"); do
  rel_path="${skill_file#"$REPO_DIR/"}"
  dir_name="$(basename "$(dirname "$skill_file")")"

  # Required: name field
  skill_name="$(head -20 "$skill_file" | grep "^name:" | sed 's/^name: *//' | tr -d '[:space:]')"
  if [ -z "$skill_name" ]; then
    echo "  [FAIL] $rel_path — missing 'name:' in frontmatter"
    errors=$((errors + 1))
    continue
  fi

  # Required: description field
  if ! head -20 "$skill_file" | grep -q "^description:"; then
    echo "  [FAIL] $rel_path — missing 'description:' in frontmatter"
    errors=$((errors + 1))
    continue
  fi

  # Spec: name must match directory name
  if [ "$skill_name" != "$dir_name" ]; then
    echo "  [FAIL] $rel_path — name '$skill_name' does not match directory '$dir_name'"
    errors=$((errors + 1))
    continue
  fi

  # Spec: lowercase alphanumeric + hyphens only, max 64 chars
  if ! echo "$skill_name" | grep -qE '^[a-z0-9]([a-z0-9-]*[a-z0-9])?$'; then
    echo "  [FAIL] $rel_path — name '$skill_name' must be lowercase alphanumeric + hyphens"
    errors=$((errors + 1))
    continue
  fi

  # Spec: no consecutive hyphens
  if echo "$skill_name" | grep -q '\-\-'; then
    echo "  [FAIL] $rel_path — name '$skill_name' contains consecutive hyphens"
    errors=$((errors + 1))
    continue
  fi

  # Spec: max 64 characters
  if [ "${#skill_name}" -gt 64 ]; then
    echo "  [FAIL] $rel_path — name '$skill_name' exceeds 64 characters"
    errors=$((errors + 1))
    continue
  fi

  # Spec: description max 1024 characters
  desc="$(head -20 "$skill_file" | grep "^description:" | sed 's/^description: *//')"
  if [ "${#desc}" -gt 1024 ]; then
    echo "  [WARN] $rel_path — description exceeds 1024 characters"
  fi

  # Spec: body under 500 lines (warning, not fatal)
  body_lines="$(awk '/^---$/{n++; next} n>=2' "$skill_file" | wc -l)"
  if [ "$body_lines" -gt 500 ]; then
    echo "  [WARN] $rel_path — body is $body_lines lines (recommended < 500)"
  fi

  echo "  [ok] $rel_path"
done

if [ "$errors" -gt 0 ]; then
  echo ""
  echo "FATAL: $errors skill(s) failed validation. Fix before continuing."
  exit 1
fi
echo ""

# --- Validating Custom Framework Standards ---
echo "--- Validating Custom Framework Standards ---"
fw_errors=0
fw_warnings=0

for skill_file in $(find "$REPO_DIR" -name "SKILL.md" -not -path "*/node_modules/*" -not -path "*/archive/*"); do
  rel_path="${skill_file#"$REPO_DIR/"}"

  # Hardcoded path check: fail if SKILL.md contains /root/projects
  if grep -q '/root/projects' "$skill_file"; then
    echo "  [FAIL] $rel_path — contains hardcoded path '/root/projects' (use \$PROJECTS_DIR or \${CLAUDE_SKILL_DIR})"
    fw_errors=$((fw_errors + 1))
  fi

  # Step 0 check: fail if SKILL.md does not contain Step 0: Usage Logging
  if ! grep -q 'Step 0: Usage Logging' "$skill_file"; then
    echo "  [FAIL] $rel_path — missing 'Step 0: Usage Logging'"
    fw_errors=$((fw_errors + 1))
  fi

  # Internal path check: warn if referencing internal files without ${CLAUDE_SKILL_DIR}
  # Look for references/, scripts/, assets/ paths that don't use the variable
  if grep -E '(cat|bash|source|read)\s+.*(references/|scripts/|assets/)' "$skill_file" | grep -v 'CLAUDE_SKILL_DIR' | grep -qv '^\s*#'; then
    echo "  [WARN] $rel_path — references internal files without \${CLAUDE_SKILL_DIR}"
    fw_warnings=$((fw_warnings + 1))
  fi
done

if [ "$fw_errors" -gt 0 ]; then
  echo ""
  echo "FATAL: $fw_errors skill(s) failed framework standards. Fix before continuing."
  exit 1
fi
if [ "$fw_warnings" -gt 0 ]; then
  echo "  $fw_warnings warning(s) — review recommended"
fi
echo ""

# --- Generate skills-env.sh (sourced by skills at runtime) ---
echo "--- Skills runtime environment ---"
SKILLS_ENV="$HOME/.claude/skills-env.sh"
cat > "$SKILLS_ENV" <<ENVEOF
# Auto-generated by ai-skills setup.sh — do not edit manually.
# Re-run setup.sh to regenerate after changing .env.
export PROJECTS_DIR="${PROJECTS_DIR}"
export GITHUB_ORG="${GITHUB_ORG}"
export SKILL_USAGE_LOG="${USAGE_LOG}"
export SKILL_FEEDBACK_LOG="${FEEDBACK_LOG}"
ENVEOF
echo "  [ok] $SKILLS_ENV"
echo ""

# --- Usage & feedback logs ---
echo "--- Usage tracking ---"
touch "$USAGE_LOG"
echo "  [ok] $USAGE_LOG"
touch "$FEEDBACK_LOG"
echo "  [ok] $FEEDBACK_LOG"
echo ""

# --- User-level skills ---
echo "--- User-level skills → $USER_SKILLS_DIR ---"
mkdir -p "$USER_SKILLS_DIR"

for skill_dir in "$REPO_DIR"/user/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$USER_SKILLS_DIR/$skill_name"

  if [ -L "$target" ]; then
    current="$(readlink "$target")"
    if [ "$current" = "$skill_dir" ] || [ "$current" = "${skill_dir%/}" ]; then
      echo "  [ok] $skill_name (already linked)"
      continue
    fi
    rm "$target"
  elif [ -e "$target" ]; then
    echo "  [skip] $skill_name (non-symlink exists, remove manually)"
    continue
  fi

  ln -s "${skill_dir%/}" "$target"
  echo "  [new] $skill_name → $skill_dir"
done

# Remove stale user symlinks (deleted or archived skills)
for link in "$USER_SKILLS_DIR"/*/; do
  [ -L "${link%/}" ] || continue
  link_target="$(readlink "${link%/}")"
  if [[ "$link_target" == "$REPO_DIR/user/"* ]]; then
    if [ ! -d "$link_target" ] || [[ "$link_target" == "$REPO_DIR/archive/"* ]]; then
      rm "${link%/}"
      echo "  [removed] $(basename "${link%/}") (stale)"
    fi
  fi
  # Also catch links that were moved to archive/ (target rewritten by mv)
  if [[ "$link_target" == "$REPO_DIR/archive/"* ]]; then
    rm "${link%/}"
    echo "  [removed] $(basename "${link%/}") (archived)"
  fi
done

echo ""

# --- Project-scoped skills ---
for project in "${!PROJECTS[@]}"; do
  project_dir="${PROJECTS[$project]}"
  skills_target="$project_dir/.claude/skills"
  source_dir="$REPO_DIR/$project"

  echo "--- $project skills → $skills_target ---"

  if [ ! -d "$project_dir" ]; then
    echo "  [skip] Project dir $project_dir does not exist"
    echo ""
    continue
  fi

  if [ ! -d "$source_dir" ]; then
    echo "  [skip] No skills directory $source_dir in repo"
    echo ""
    continue
  fi

  mkdir -p "$skills_target"

  for skill_dir in "$source_dir"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    target="$skills_target/$skill_name"

    if [ -L "$target" ]; then
      current="$(readlink "$target")"
      if [ "$current" = "$skill_dir" ] || [ "$current" = "${skill_dir%/}" ]; then
        echo "  [ok] $skill_name (already linked)"
        continue
      fi
      rm "$target"
    elif [ -e "$target" ]; then
      echo "  [skip] $skill_name (non-symlink exists, remove manually)"
      continue
    fi

    ln -s "${skill_dir%/}" "$target"
    echo "  [new] $skill_name → $skill_dir"
  done

  # Remove stale project symlinks (deleted or archived skills)
  for link in "$skills_target"/*/; do
    [ -L "${link%/}" ] || continue
    link_target="$(readlink "${link%/}")"
    if [[ "$link_target" == "$source_dir/"* ]] && [ ! -d "$link_target" ]; then
      rm "${link%/}"
      echo "  [removed] $(basename "${link%/}") (stale)"
    fi
    if [[ "$link_target" == "$REPO_DIR/archive/"* ]]; then
      rm "${link%/}"
      echo "  [removed] $(basename "${link%/}") (archived)"
    fi
  done

  echo ""
done

# --- Archive summary ---
archived_count=$(find "$REPO_DIR/archive" -name "SKILL.md" 2>/dev/null | wc -l)
if [ "$archived_count" -gt 0 ]; then
  echo "--- Archive ($archived_count archived skills) ---"
  for skill_file in $(find "$REPO_DIR/archive" -name "SKILL.md" | sort); do
    skill_name="$(head -10 "$skill_file" | grep "^name:" | sed 's/^name: *//' | tr -d '[:space:]')"
    echo "  [archived] $skill_name"
  done
  echo ""
fi

# --- Post-merge hook (auto-run setup.sh after git pull) ---
echo "--- Git post-merge hook ---"
HOOK_DIR="$REPO_DIR/.git/hooks"
HOOK_FILE="$HOOK_DIR/post-merge"
if [ -d "$REPO_DIR/.git" ]; then
  mkdir -p "$HOOK_DIR"
  cat > "$HOOK_FILE" <<'HOOKEOF'
#!/usr/bin/env bash
# Auto-run setup.sh after git pull to keep symlinks and env in sync.
REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
echo "Running setup.sh after merge..."
bash "$REPO_DIR/setup.sh"
HOOKEOF
  chmod +x "$HOOK_FILE"
  echo "  [ok] $HOOK_FILE"
else
  echo "  [skip] Not a git repo — no hook installed"
fi
echo ""

echo "=== Done ==="
