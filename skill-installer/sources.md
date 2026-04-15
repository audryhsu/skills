# Skill Sources

How to fetch skills and MCP server configs from different source types.

## Source Type 1: GitHub URL

User provides a URL like:
- `https://github.com/user/repo/blob/main/plugins/my-skill/README.md`
- `https://github.com/user/repo/tree/main/skills/my-skill`

### Step 1: Identify the skill directory

From a README URL, navigate to the parent directory to find the skill structure:
- Look for `skills/<name>/SKILL.md` or `<name>/SKILL.md`
- The README often lives alongside or above the skill files

### Step 2: Construct raw URLs

Convert GitHub blob/tree URLs to raw content URLs:
```
https://github.com/user/repo/blob/main/path/to/SKILL.md
→ https://raw.githubusercontent.com/user/repo/main/path/to/SKILL.md
```

### Step 3: Fetch SKILL.md first

Download the SKILL.md and parse it to find references to supporting files:
- Look for markdown links like `[implementation.md](implementation.md)`
- Look for references like "See [categories.md](categories.md)"
- These are sibling files in the same directory

### Step 4: Fetch supporting files

For each referenced sibling file, construct the raw URL and fetch it:
```
https://raw.githubusercontent.com/user/repo/main/path/to/implementation.md
https://raw.githubusercontent.com/user/repo/main/path/to/categories.md
```

### Step 5: Handle directory listings

If the user provides a tree URL (directory), fetch the GitHub page to discover file names, then fetch each file's raw content.

---

## Source Type 2: Local Path

User provides a local directory path like:
- `/path/to/repo/skills/my-skill/`
- `./plugins/my-skill/`

### Step 1: Validate

Confirm the path exists and contains a SKILL.md:
```bash
test -f /path/to/skill/SKILL.md || echo "No SKILL.md found"
```

### Step 2: Copy files

Copy the entire directory to the source of truth:
```bash
cp -r /path/to/skill/ ~/.agents/skills/<name>/
```

Or if the user wants to maintain a link to the local source (development workflow), symlink instead:
```bash
ln -s /path/to/skill ~/.agents/skills/<name>
```

Ask the user which approach they prefer if unclear.

---

## Source Type 3: Registry / Discovery

User describes a capability they want rather than providing a specific source.

### Step 1: Search known registries

Check these sources:
1. **GitHub search**: Search for `SKILL.md` files in repos matching the capability
   ```
   https://github.com/search?q=SKILL.md+<capability>&type=code
   ```
2. **npm skills package**: Check if the `skills` npm package has a matching skill
   ```bash
   npx skills search <query>
   ```
3. **Awesome lists**: Check known curated lists of agent skills
4. **MCP registry** (for MCP servers): Check `https://api.anthropic.com/mcp-registry/v0/servers`

### Step 2: Present options

Show the user what was found with:
- Skill name and description
- Source URL
- Compatibility notes (if any)

### Step 3: User selects

User picks which skill to install, then proceed with the GitHub URL or local path workflow.

---

## Handling MCP Server Sources

MCP servers typically come from:

1. **Direct URL**: User provides the MCP server endpoint URL
2. **npm package**: User provides an npm package name to run via `npx`
3. **GitHub repo**: README with install instructions to translate into config
4. **MCP Registry**: Anthropic's registry at `https://api.anthropic.com/mcp-registry/v0/servers`

For MCP servers, there are no files to write -- only config entries to add. See [mcp-config.md](mcp-config.md) for the config format per harness.
