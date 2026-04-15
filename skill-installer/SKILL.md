---
name: skill-installer
description: Install skills and MCP servers across Claude Code and OpenCode harnesses with symlink governance and post-install verification.
---

# Skill Installer

Install agent skills and MCP servers to work across both Claude Code and OpenCode. Enforces single-source-of-truth governance via symlinks and verifies installs by spawning a fresh agent.

## When to Use

- User asks to install a skill from a GitHub URL, local path, or registry
- User asks to add an MCP server to one or both harnesses
- User asks to check or fix skill governance (duplicates, broken symlinks)

## Governance Model

**Source of truth**: `~/.agents/skills/<name>/` -- real files live here only.

**Consumers via symlinks**:
- `~/.claude/skills/<name>` -> `../../.agents/skills/<name>` (relative)
- `~/.config/opencode/skills/<name>` -> `/Users/<user>/.agents/skills/<name>` (absolute)

**Rule**: Never write real skill files to `~/.claude/skills/` or `~/.config/opencode/skills/` directly. Always write to `~/.agents/skills/` and symlink from the other two.

**Exception**: Harness-specific nested skill directories (e.g. `runpod/`, `superpowers/`) that use their own symlink trees are left as-is.

## Workflow: Installing a Skill

### Step 1: Identify Source Type

Determine the source from user input. See [sources.md](sources.md) for detailed instructions per source type.

- **GitHub URL**: e.g. `https://github.com/user/repo/blob/main/plugins/my-skill/README.md`
- **Local path**: e.g. `/path/to/repo/skills/my-skill/`
- **Registry search**: user describes a capability, search known registries

### Step 2: Fetch Skill Files

Retrieve the SKILL.md and any supporting files (implementation.md, examples.md, etc.). The SKILL.md references to sibling files via relative paths like `[implementation.md](implementation.md)` tell you which supporting files to fetch.

### Step 3: Validate Before Writing

Check the SKILL.md frontmatter:

1. `name` field exists and matches regex: `^[a-z0-9]+(-[a-z0-9]+)*$`
2. `name` is 1-64 characters
3. `description` field exists and is 1-1024 characters
4. `name` will match the directory name

If validation fails, report the issue and ask user how to proceed.

### Step 4: Write to Source of Truth

```bash
mkdir -p ~/.agents/skills/<name>
# Write SKILL.md and all supporting files to ~/.agents/skills/<name>/
```

### Step 5: Create Symlinks

See [skill-paths.md](skill-paths.md) for the canonical path reference.

```bash
# Claude Code consumer
ln -s ../../.agents/skills/<name> ~/.claude/skills/<name>

# OpenCode consumer (use absolute path -- relative depth differs)
ln -s /Users/<user>/.agents/skills/<name> ~/.config/opencode/skills/<name>
```

If symlinks already exist, check if they point to the right target. If they point elsewhere, warn the user before overwriting.

### Step 6: Verify Installation

See [verification.md](verification.md) for the full procedure.

1. **Structural check**: Confirm files exist and symlinks resolve
2. **Live test**: Spawn a fresh `claude -p` agent to confirm the skill is discoverable

## Workflow: Installing an MCP Server

### Step 1: Determine Harness Targets

Ask or infer which harnesses to configure: Claude Code, OpenCode, or both.

### Step 2: Get Server Config

From user input, determine:
- Server name
- Transport type (stdio/http/sse for Claude Code; local/remote for OpenCode)
- Command or URL
- Environment variables or headers

### Step 3: Write Config

See [mcp-config.md](mcp-config.md) for config formats per harness.

**Claude Code**: Use `claude mcp add` CLI when possible (handles scoping). Otherwise edit `~/.claude.json` mcpServers key directly.

**OpenCode**: Add entry to `opencode.json` under the `mcp` key.

### Step 4: Verify

For Claude Code: run `claude mcp list` and confirm the server appears.
For OpenCode: structural check that the config file parses as valid JSON with the new entry.

## Workflow: Audit / Fix Governance

When asked to check or fix skill governance:

1. List all directories in `~/.agents/skills/`, `~/.claude/skills/`, `~/.config/opencode/skills/`
2. For each skill in agents: confirm symlinks exist in both consumers
3. For each real dir in claude or opencode: flag as governance violation (should be symlink)
4. Offer to fix: move real dir to agents, replace with symlink

## Supporting Files

- [skill-paths.md](skill-paths.md) -- Canonical paths for skills per harness
- [mcp-config.md](mcp-config.md) -- MCP server config formats per harness
- [sources.md](sources.md) -- How to fetch from GitHub, local, registry
- [verification.md](verification.md) -- Structural and live verification procedures
