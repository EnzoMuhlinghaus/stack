#!/bin/sh
# Link every skill of this checkout where agents look for skills:
#   ~/.agents/skills/<name>  -> <checkout>/skills/<name>   (Codex, the skills CLI, Orca)
#   ~/.claude/skills/<name>  -> ~/.agents/skills/<name>    (Claude Code)
# Safe to run again: it replaces its own links, never a real file or folder,
# and removes links it made for skills that no longer exist.
# Override the folders with AGENTS_SKILLS_DIR and CLAUDE_SKILLS_DIR.
set -eu

here=$(cd "$(dirname "$0")" && pwd -P)
agents=${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}
claude=${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}
mkdir -p "$agents" "$claude"

link() { # link <target> <path>
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    echo "skip $2: a real file or folder is there" >&2
    return
  fi
  ln -sfn "$1" "$2"
}

for dir in "$here"/skills/*/; do
  name=$(basename "$dir")
  link "$here/skills/$name" "$agents/$name"
  link "$agents/$name" "$claude/$name"
done

# Drop broken links that point into this checkout or the agents folder.
for path in "$agents"/* "$claude"/*; do
  [ -L "$path" ] && [ ! -e "$path" ] || continue
  case $(readlink "$path") in
    "$here"/skills/* | "$agents"/*) rm "$path" && echo "removed $path" ;;
  esac
done

echo "linked $(ls -d "$here"/skills/*/ | wc -l | tr -d ' ') skills into $agents and $claude"
