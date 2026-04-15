# Skill Paths Reference

Canonical reference for where skills are discovered by each harness and how our governance model maps to them.

## Governance: Single Source of Truth

```
~/.agents/skills/<name>/SKILL.md    ← WRITE HERE (source of truth)
~/.claude/skills/<name>/            ← SYMLINK (relative: ../../.agents/skills/<name>)
~/.config/opencode/skills/<name>/   ← SYMLINK (absolute: /Users/<user>/.agents/skills/<name>)
```

## All Discovery Paths

Both Claude Code and OpenCode discover skills from multiple locations. Our governance uses the agent-compatible path as the single source, with symlinks into the harness-specific paths.

### OpenCode Discovery Paths

Source: https://opencode.ai/docs/skills/

| Scope | Path |
|-------|------|
| Project config | `.opencode/skills/<name>/SKILL.md` |
| Global config | `~/.config/opencode/skills/<name>/SKILL.md` |
| Project Claude-compatible | `.claude/skills/<name>/SKILL.md` |
| Global Claude-compatible | `~/.claude/skills/<name>/SKILL.md` |
| Project agent-compatible | `.agents/skills/<name>/SKILL.md` |
| Global agent-compatible | `~/.agents/skills/<name>/SKILL.md` |

### Claude Code Discovery Paths

Claude Code discovers skills from:

| Scope | Path |
|-------|------|
| Global user skills | `~/.claude/skills/<name>/SKILL.md` |
| Global agent-compatible | `~/.agents/skills/<name>/SKILL.md` |
| Project skills | `.claude/skills/<name>/SKILL.md` |
| Project agent-compatible | `.agents/skills/<name>/SKILL.md` |

## Skill Name Rules

From OpenCode docs (Claude Code follows the same conventions):

- 1-64 characters
- Lowercase alphanumeric with single hyphen separators
- Must not start or end with `-`
- Must not contain consecutive `--`
- Regex: `^[a-z0-9]+(-[a-z0-9]+)*$`
- **Directory name must match the `name` field in frontmatter**

## SKILL.md Frontmatter

Required fields:
```yaml
---
name: my-skill-name          # required, must match directory name
description: What this does   # required, 1-1024 chars
---
```

Optional fields: `license`, `compatibility`, `metadata` (string-to-string map).

## Symlink Commands

### For a new skill install:

```bash
# 1. Write files to source of truth
mkdir -p ~/.agents/skills/<name>
# write SKILL.md + supporting files here

# 2. Create Claude Code symlink (relative path)
ln -s ../../.agents/skills/<name> ~/.claude/skills/<name>

# 3. Create OpenCode symlink (absolute path)
ln -s /Users/<user>/.agents/skills/<name> ~/.config/opencode/skills/<name>
```

### Why different path styles:

- **Claude Code** (`~/.claude/skills/`): relative `../../.agents/skills/<name>` works because `~/.claude/` and `~/.agents/` are both two levels under `$HOME`.
- **OpenCode** (`~/.config/opencode/skills/`): absolute path needed because `~/.config/opencode/skills/` is three levels deep under `$HOME`, making the relative path to `~/.agents/` fragile.

## Existing Special Cases

These directories in `~/.config/opencode/skills/` use their own nested symlink trees and should NOT be touched by the installer:

- `runpod/` -- RunPod-specific skills, symlinks into `~/.config/opencode/claude-plugins/`
- `superpowers/` -- symlink to `~/.config/opencode/superpowers/skills`
