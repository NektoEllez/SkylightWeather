# Project MCP Rules

## HIGHEST PRIORITY: Data & Secret Security (Mandatory)

This rule overrides all convenience and speed considerations.

1. Never store real secrets in git:
- API keys
- tokens
- passwords
- private certificates
- connection strings with credentials

2. Never hardcode secrets in source code, project files, plist files, or build settings checked into git.

3. Use local-only secret injection:
- environment variables
- local `.xcconfig` files excluded from git (for example `Secrets.xcconfig`)
- CI secret storage

4. If a secret is discovered in the repository or commit history:
- treat it as compromised immediately
- rotate/revoke it immediately
- remove it from tracked files
- prevent recurrence with ignore/rules updates

5. Before any commit/push, perform a secret exposure check in changed files.

6. Do not publish or repeat real secret values in issues, PRs, chats, logs, screenshots, or docs.

Security first is mandatory for every task in this repository.
