#!/usr/bin/env bash
# Consolidates the daily AWS SSO + GitHub Okta SSO login into one command.
# No secrets are read, stored, or transmitted here — both steps rely on
# your existing SSO/Okta sessions and interactive browser MFA.
set -euo pipefail

PROFILE="${1:-dev}"

command -v aws >/dev/null 2>&1 || { echo "aws CLI not found on PATH" >&2; exit 1; }
command -v aws-export-credentials >/dev/null 2>&1 || { echo "aws-export-credentials not found on PATH (see SKILL.md Prerequisites)" >&2; exit 1; }

echo "==> AWS SSO login (profile: $PROFILE)"
aws sso login --profile "$PROFILE"

echo "==> Exporting SSO credentials to ~/.aws/credentials (default profile)"
aws-export-credentials --profile "$PROFILE" -c default

echo "==> Opening github.com to refresh Okta SSO session"
case "$(uname -s)" in
  Darwin) open "https://github.com" ;;
  Linux) xdg-open "https://github.com" >/dev/null 2>&1 || echo "Open https://github.com manually." ;;
  *) echo "Open https://github.com manually to refresh your Okta session." ;;
esac

echo "==> Done. Approve any MFA/Okta prompts in your browser."
