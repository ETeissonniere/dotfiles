---
description: Show issues organized by risk and difficulty
---

Fetch all open issues from the current repository. Detect the platform from `git remote -v` and use the matching CLI (`gh issue list` for GitHub, `tea issue list` for Gitea).

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
