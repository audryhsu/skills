---
name: sso-login
description: Use when starting a work session and AWS CLI calls fail with an expired SSO token, or GitHub/gh commands fail because the Okta-backed GitHub SSO session has timed out — refreshes both the AWS SSO session and GitHub's Okta SSO session in one step.
metadata:
  requires:
    bins:
      - aws
      - gh
---

# SSO Login

## Overview

Consolidates two separate daily logins — AWS SSO and GitHub's Okta-backed SSO — into one invocable step. Each still requires a real browser and an interactive MFA/Okta approval, so this doesn't eliminate the human step, it just triggers both prompts for you instead of you remembering and typing two things.

No secrets are read, stored, or hardcoded anywhere in this skill. Both steps rely entirely on your existing SSO/Okta session state and browser-based MFA — that's what makes this safe to share with a team.

## When to use

- AWS CLI commands fail with `ExpiredToken` / "SSO session associated with this profile has expired."
- `gh` commands or a GitHub PR page in the browser bounce you through an Okta login redirect.
- Start-of-day routine, before other tooling that depends on AWS or GitHub auth.

## What it does

1. `aws sso login --profile <profile>` — opens a browser tab for AWS SSO login + MFA.
2. `aws-export-credentials --profile <profile> -c default` — exports the short-lived SSO credentials into `~/.aws/credentials` under the `default` profile, for tools that expect static credentials rather than SSO-aware config.
3. Opens `https://github.com` in your default browser — if your Okta session has expired, GitHub redirects you through Okta; approve there and you're bounced back.

## Usage

```
scripts/sso-login.sh [aws-profile]
```

Defaults to profile `dev` if no argument is given.

## Prerequisites

- AWS CLI v2 with an SSO profile configured in `~/.aws/config` (default assumed: `dev`).
- `aws-export-credentials` on `PATH` — a personal helper script that exports SSO creds into `~/.aws/credentials`, not an AWS CLI built-in. Install/alias it yourself before relying on this skill.
- A default browser available to `open` (macOS) / `xdg-open` (Linux).

## Scheduling

Because both steps need a live browser and a human MFA/Okta tap, this can't run fully headless — "scheduling" means having something pop both prompts for you automatically, so you only need to approve them.

## Common mistakes

- **Running this in a cloud/remote Claude sandbox.** It has no local browser and no local AWS CLI config — `open`/`xdg-open` will fail or no-op, and the AWS SSO browser flow has nowhere to go. This only works in a session on your own machine.
- **Assuming `aws-export-credentials` ships with the AWS CLI.** It doesn't — it's a personal helper script. Confirm it's installed before relying on step 2.
- **Expecting this to be silent/unattended.** MFA and Okta approval are still manual taps; this only removes the "remember and type two commands" step.
