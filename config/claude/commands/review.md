---
description: "Invoke code-reviewer agent to analyze code changes"
---
Use the code-reviewer subagent to analyze the code. Focus on:
- Code cleanliness and dead code
- Performance and latency issues
- Opportunities to use established libraries

## Git Context

**Current Branch**: $GIT_BRANCH
**Default Branch**: $GIT_DEFAULT_BRANCH
**Uncommitted Changes**: $GIT_DIRTY

**Git Remotes** (identifies GitHub/GitLab/etc):
```
!git remote -v
```

**Unstaged Changes**:
```
!git diff
```

**Staged Changes**:
```
!git diff --cached
```

**Commits on this branch** (if on feature branch):
```
!git log $GIT_DEFAULT_BRANCH..$GIT_BRANCH --oneline 2>/dev/null || echo "On default branch or no commits ahead"
```

$ARGUMENTS
