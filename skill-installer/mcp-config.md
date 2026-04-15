# MCP Server Configuration Reference

How to add MCP servers to each harness. Unlike skills, MCP configs are NOT symlinked -- each harness has its own config format and file.

## Claude Code

Source: https://docs.anthropic.com/en/docs/claude-code/mcp

### Preferred: CLI command

```bash
# HTTP/remote server
claude mcp add --transport http <name> <url>

# SSE server (deprecated, prefer http)
claude mcp add --transport sse <name> <url>

# Stdio/local server
claude mcp add --transport stdio <name> -- <command> [args...]

# With environment variables
claude mcp add --transport stdio --env KEY=value <name> -- <command> [args...]

# With auth header
claude mcp add --transport http <name> <url> --header "Authorization: Bearer <token>"
```

### Scopes

| Scope | Flag | Stored in | Loads in |
|-------|------|-----------|----------|
| local (default) | `--scope local` | `~/.claude.json` (under project path) | Current project only |
| project | `--scope project` | `.mcp.json` in project root | Current project, shared with team |
| user | `--scope user` | `~/.claude.json` (top-level mcpServers) | All projects |

### Manual config format

In `~/.claude.json` top-level `mcpServers` key (user scope):

```json
{
  "mcpServers": {
    "my-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp"
    },
    "local-server": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@some/mcp-server"],
      "env": {
        "API_KEY": "value"
      }
    }
  }
}
```

In `.mcp.json` (project scope):

```json
{
  "mcpServers": {
    "shared-server": {
      "command": "/path/to/server",
      "args": [],
      "env": {}
    }
  }
}
```

### Verification

```bash
claude mcp list
claude mcp get <name>
```

---

## OpenCode

Source: https://opencode.ai/docs/mcp-servers/

### Config file

`opencode.json` in project root, or `~/.config/opencode/opencode.json` for global.

### Config format

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-local-server": {
      "type": "local",
      "command": ["npx", "-y", "@some/mcp-server"],
      "enabled": true,
      "environment": {
        "API_KEY": "value"
      }
    },
    "my-remote-server": {
      "type": "remote",
      "url": "https://mcp.example.com",
      "enabled": true,
      "headers": {
        "Authorization": "Bearer token"
      }
    }
  }
}
```

### Key differences from Claude Code

| Aspect | Claude Code | OpenCode |
|--------|------------|----------|
| Transport types | `stdio`, `http`, `sse` | `local`, `remote` |
| Command format | `"command": "npx"` + `"args": [...]` | `"command": ["npx", "..."]` (single array) |
| Env vars key | `"env"` | `"environment"` |
| Config key | `"mcpServers"` | `"mcp"` |
| Enabled flag | not used (presence = enabled) | `"enabled": true/false` |
| CLI install | `claude mcp add ...` | no CLI, edit config directly |

### Verification

No built-in CLI check. Verify by:
1. Confirming `opencode.json` parses as valid JSON
2. Confirming the `mcp` key contains the new entry
3. Starting OpenCode and checking tool availability

---

## Translation Table

When a user provides config for one harness, translate to the other:

### Claude Code stdio → OpenCode local

```json
// Claude Code
{ "type": "stdio", "command": "npx", "args": ["-y", "pkg"], "env": {"K": "V"} }

// OpenCode equivalent
{ "type": "local", "command": ["npx", "-y", "pkg"], "environment": {"K": "V"}, "enabled": true }
```

### Claude Code http → OpenCode remote

```json
// Claude Code
{ "type": "http", "url": "https://example.com/mcp" }

// OpenCode equivalent
{ "type": "remote", "url": "https://example.com/mcp", "enabled": true }
```
