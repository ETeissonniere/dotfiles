---
description: Show issues organized by risk and difficulty
allowed-tools: Skill
---

Detect the git remote to determine the platform and use the appropriate skill:
- If remote contains `github.com`: use the `github` skill
- If remote contains `gitlab`: use the `gitlab` skill
- If remote contains a Gitea instance: use the `gitea` skill

Fetch all open issues from this repository using the skill's issue list command.

Analyze each issue and create a dashboard table with columns:
- Issue number
- Title
- Risk level (Low/Medium/High) - based on security implications, potential for data loss, or breaking changes
- Difficulty (Easy/Medium/Hard) - based on scope, complexity, and dependencies

Use these indicators:
- Risk: 🟢 Low, 🟡 Medium, 🔴 High
- Difficulty: 🟢 Easy, 🟡 Medium, 🔴 Hard

Sort by risk (highest first), then by difficulty.

After the table, provide:
1. A brief analysis of high-risk items
2. Suggested priority order for tackling the issues
