# Verification Procedures

How to verify that a skill or MCP server was installed correctly.

## Skill Verification

### Phase 1: Structural Checks

Run these checks immediately after writing files and creating symlinks.

#### 1. Source files exist

```bash
test -f ~/.agents/skills/<name>/SKILL.md && echo "OK" || echo "FAIL: SKILL.md missing"
```

#### 2. Symlinks exist and resolve

```bash
# Claude Code
test -L ~/.claude/skills/<name> && test -f ~/.claude/skills/<name>/SKILL.md \
  && echo "Claude: OK" || echo "Claude: FAIL"

# OpenCode
test -L ~/.config/opencode/skills/<name> && test -f ~/.config/opencode/skills/<name>/SKILL.md \
  && echo "OpenCode: OK" || echo "OpenCode: FAIL"
```

#### 3. Frontmatter is valid

Parse the SKILL.md and confirm:
- `name` field exists and matches directory name
- `name` matches regex `^[a-z0-9]+(-[a-z0-9]+)*$`
- `name` is 1-64 characters
- `description` field exists and is 1-1024 characters

```bash
# Quick check: first 5 lines should contain name and description
head -5 ~/.agents/skills/<name>/SKILL.md
```

#### 4. No governance violations

```bash
# Claude consumer should be a symlink, not a real dir
test -L ~/.claude/skills/<name> && echo "OK: symlink" || echo "VIOLATION: real dir"

# OpenCode consumer should be a symlink, not a real dir
test -L ~/.config/opencode/skills/<name> && echo "OK: symlink" || echo "VIOLATION: real dir"
```

### Phase 2: Live Test

Spawn a fresh Claude Code agent to confirm the skill is discoverable. This catches issues that structural checks miss (e.g. frontmatter parse errors, name collisions).

**Important**: Do NOT use bash variable capture. Let output flow to stdout.

```bash
cd ~ && claude -p --output-format json --max-turns 2 \
  "List your available skills. Is there a skill named '<name>'? Reply with exactly 'FOUND: <name>' if yes or 'NOT FOUND: <name>' if no."
```

Parse the JSON response:
- Extract `.result` field
- Check if it contains `FOUND: <name>`
- If `NOT FOUND`, the skill failed to load -- check frontmatter and symlinks

### Reporting Results

After both phases, report to the user:

```
[Skill Installer] Verification for '<name>':
  Source files:     OK (SKILL.md + N supporting files)
  Claude symlink:   OK (resolves correctly)
  OpenCode symlink: OK (resolves correctly)
  Frontmatter:      OK (name='<name>', description present)
  Live test:        OK (skill discoverable in fresh session)
```

Or on failure:

```
[Skill Installer] Verification for '<name>':
  Source files:     OK
  Claude symlink:   OK
  OpenCode symlink: OK
  Frontmatter:      OK
  Live test:        FAIL (skill not found in fresh session)
    → Check: Is the name unique across all skill locations?
    → Check: Are there frontmatter parse errors?
    → Try: Restart your Claude Code / OpenCode session
```

---

## MCP Server Verification

### Claude Code

```bash
claude mcp list
# Confirm the server name appears in the output

claude mcp get <name>
# Confirm config details match what was intended
```

### OpenCode

No built-in CLI verification. Check:

1. Config file parses as valid JSON:
```bash
python3 -m json.tool opencode.json > /dev/null && echo "Valid JSON" || echo "Invalid JSON"
```

2. The `mcp` key contains the new server entry
3. Advise user to restart OpenCode and check tool availability

---

## Common Failure Modes

| Symptom | Cause | Fix |
|---------|-------|-----|
| Skill not found in live test | Frontmatter `name` doesn't match directory | Rename directory or fix frontmatter |
| Broken symlink | Source dir was moved/deleted | Re-run install or fix source path |
| Duplicate skill warning | Same name in multiple locations | Remove the duplicate, keep only agents source + symlinks |
| MCP server not connecting | Wrong transport type or URL | Check mcp-config.md for correct format per harness |
| OpenCode doesn't see skill | Symlink uses wrong path | Use absolute path for opencode symlinks |
