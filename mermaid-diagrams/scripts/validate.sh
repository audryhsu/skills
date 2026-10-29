#!/usr/bin/env bash
# Validate mermaid syntax by attempting to render to SVG with mmdc.
# Usage: validate.sh <diagram.mmd>
#   or:  validate.sh -            (read mermaid source from stdin)
#
# Exits 0 on valid syntax, non-zero with stderr from mmdc on failure.
# Renders to a tempfile and discards it -- this skill validates syntax, not images.

set -euo pipefail

if ! command -v mmdc >/dev/null 2>&1; then
  echo "error: mmdc not installed. install with: npm install -g @mermaid-js/mermaid-cli" >&2
  exit 127
fi

input="${1:-}"
if [[ -z "$input" ]]; then
  echo "usage: $0 <file.mmd|-->" >&2
  exit 2
fi

tmp_dir="$(mktemp -d -t mermaid-validate.XXXXXX)"
trap 'rm -rf "$tmp_dir"' EXIT

tmp_in=""
if [[ "$input" == "-" ]]; then
  tmp_in="$tmp_dir/input.mmd"
  cat > "$tmp_in"
  input="$tmp_in"
fi

tmp_out="$tmp_dir/output.svg"

# Render to SVG; suppress stdout, surface stderr.
if mmdc -i "$input" -o "$tmp_out" -q >/dev/null 2>&1; then
  echo "ok"
  exit 0
else
  # Re-run without -q to capture the actual error message.
  mmdc -i "$input" -o "$tmp_out" 1>&2 || true
  exit 1
fi
