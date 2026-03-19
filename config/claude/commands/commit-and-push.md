Stage all changes, generate a clear commit message based on the diff, commit, and push to the remote.

Steps:
1. Run `git status` to see what changed
2. Run `git diff --staged` and `git diff` to understand the changes
3. Run `git log --oneline -5` to match the repo's commit message style
4. Stage all changes with `git add -A`
5. Generate a concise commit message focusing on "why" not "what"
6. Commit the changes
7. Push to the remote with `git push`
8. Report the commit hash and push result