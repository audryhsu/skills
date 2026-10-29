---
name: manage-skills
description: Add, remove, update, list, and audit agent skills across Claude Code and OpenCode using the gh skill CLI.
---

# Skill Management

Full lifecycle management of agent skills using the `gh skill` CLI.

## When to Use

- User asks to install/add a skill (from GitHub, local path, or by description)
- User asks to remove/uninstall a skill
- User asks to update skills (check for newer versions)
- User asks to list their skills or check what's installed
- User asks to search for available skills

## Architecture

```
~/.agents/skills/              # OpenCode reads skills from here
├── <name>/SKILL.md
└── ...

~/.claude/skills/              # Claude Code reads skills from here
├── <name>/SKILL.md
└── ...
```

Both directories contain real files (no symlinks). The `gh skill` CLI manages installation to each location independently. To make a skill available to both agents, install it twice -- once per target.

## Skill Name Rules

- Regex: `^[a-z0-9]+(-[a-z0-9]+)*$`
- 1-64 characters, lowercase alphanumeric, single hyphens only
- Directory name MUST match the `name` field in SKILL.md frontmatter

## The `gh skill` CLI

The GitHub CLI has built-in skill management via `gh skill`. Requires `gh` >= 2.90.0.

```bash
gh skill search <query>                    # Search for skills across GitHub
gh skill preview <owner/repo> <skill>      # Preview a skill before installing
gh skill install <owner/repo> <skill>      # Install a skill
gh skill update --all                      # Update all installed skills
gh skill update <skill-name>               # Update a specific skill
gh skill publish --dry-run                 # Validate skills for publishing
```

### Key flags for `gh skill install`

| Flag | Purpose |
|------|---------|
| `--dir <path>` | Install to a custom directory (use `~/.agents/skills` for OpenCode) |
| `--agent <name>` | Target agent: github-copilot, claude-code, cursor, codex, gemini |
| `--scope <scope>` | `project` (default) or `user` |
| `--force` | Overwrite existing skills without prompting |
| `--from-local` | Install from a local directory/path instead of a GitHub repo |
| `--pin <ref>` | Pin to a specific git tag or commit SHA |

### Source tracking metadata

`gh skill install` injects tracking metadata into SKILL.md frontmatter:
```yaml
metadata:
    github-path: skills/my-skill
    github-ref: refs/heads/main
```
This enables `gh skill update` to detect changes and pull new versions.

## Workflows

### List Skills

```bash
ls ~/.agents/skills/       # OpenCode skills
ls ~/.claude/skills/       # Claude Code skills
```

### Install a Skill

Every install requires **two commands** -- one for each agent:

#### From a GitHub repo

```bash
# Install for OpenCode
gh skill install <owner/repo> <skill-name> --dir ~/.agents/skills --force

# Install for Claude Code
gh skill install <owner/repo> <skill-name> --agent claude-code --scope user --force
```

For a skill at a specific path in a large repo (faster, skips full discovery):
```bash
gh skill install <owner/repo> skills/author/skill-name --dir ~/.agents/skills --force
gh skill install <owner/repo> skills/author/skill-name --agent claude-code --scope user --force
```

#### Parsing a GitHub URL

When given a URL like `https://github.com/owner/repo/tree/main/skills/my-skill`:
- Repository: `owner/repo`
- Skill name: `my-skill` (last path segment)
- Full path: `skills/my-skill` (can be used for efficient install)

```bash
# Example: https://github.com/audryhsu/personal-assistant/tree/main/skills/todoist-agent-board
gh skill install audryhsu/personal-assistant todoist-agent-board --dir ~/.agents/skills --force
gh skill install audryhsu/personal-assistant todoist-agent-board --agent claude-code --scope user --force
```

#### From a local path (homegrown skills)

Use `--from-local` with the absolute path to the skill directory:

```bash
# Install for OpenCode
gh skill install /absolute/path/to/skills-repo <skill-name> --from-local --dir ~/.agents/skills --force

# Install for Claude Code
gh skill install /absolute/path/to/skills-repo <skill-name> --from-local --agent claude-code --scope user --force
```

#### Post-install verification

After any install, confirm the skill landed in both locations:
```bash
test -f ~/.agents/skills/<name>/SKILL.md && echo "OpenCode: OK"
test -f ~/.claude/skills/<name>/SKILL.md && echo "Claude Code: OK"
```

### Remove a Skill

```bash
rm -rf ~/.agents/skills/<name>
rm -rf ~/.claude/skills/<name>
```

Always confirm with the user before deleting.

### Update Skills

```bash
# Update all installed skills
gh skill update --all

# Update a specific skill
gh skill update <skill-name>
```

For locally-authored skills not from GitHub, re-install from the local path using `--from-local`.

### Search for Skills

```bash
gh skill search <query>
```

## Important Rules

- **Install to both locations** -- OpenCode reads `~/.agents/skills/`, Claude Code reads `~/.claude/skills/`. A skill must be installed to each to be available in both agents.
- **Use `--from-local` for homegrown skills** -- pass the absolute path to the local repo/directory instead of a GitHub `owner/repo`.
- **MCP server management** is handled by the `mcp-manage` skill, not this one.
- **Confirm before destructive operations** (remove, overwrite).
