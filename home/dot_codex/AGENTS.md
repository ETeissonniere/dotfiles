# Global Codex Preferences

## Follow-through & Scope
- Treat requests such as "can you" as instructions to do the work. Complete the authorized task through validation and delivery.
- Resolve routine choices from the request, repo conventions, and prior context. Ask only when missing information materially affects the result; continue independent work while waiting.
- Reuse authorization already given in the session. Prepare a concrete, reviewable result before asking for any additional permission needed for an external or irreversible action.
- Follow explicit user instructions over skill guidelines. If an instruction blocks progress, identify its source and explain the actual blocker.

## Package Managers & Tools
- Always use **UV** when interacting with Python codebases or tools
- Always use the **UV's build backend `uv_build`** unless specified otherwise
- Use available linters, language servers, and formatting tools relevant to the change
- Use **cargo** for Rust projects

## Docker & Containers
- When a required tool is not installed locally, prefer using **Docker** instead of asking the user to install it
- Always check for existing `.devcontainer/` configs or `docker-compose.yml` / `Dockerfile` before suggesting new setups
- Leverage devcontainers when available for consistent development environments

## Code Style
- Write concise, readable code - avoid over-engineering and follow KISS methodology
- Add backward compatibility only when the task or existing compatibility contract requires it; clarify only when that choice affects the requested behavior
- Prefer explicit over implicit
- Use meaningful variable and function names with human friendly, easy to understand, names
- Keep functions small and focused on a single responsibility
- Use an independent review when the complexity or risk makes it useful

## Git Workflow
- Write clear, descriptive commit messages focusing on "why" not "what"
- Keep commits atomic - one logical change per commit
- Always check `git status` before committing
- Before finishing committed or pushed work, check whether the repo defines CI in `.github/workflows/`, `Taskfile.yml`, `justfile`, `Makefile`, package scripts, or similar project automation

## Testing
- Write tests that verify code behavior, not implementation details
- Focus tests on application logic and user-visible behavior, not incidental config-file structure
- Use descriptive test names that explain the scenario
- When possible, prefer using a test suite or array over writing multiple tests
- When a repo has CI, take a reasonable local stab at reproducing the relevant pipeline before calling the work done
- Run the available test, formatting, linting, type-checking, and build commands that correspond to the files changed
- If the full CI pipeline is impractical locally, run the closest meaningful subset and clearly report what was and was not verified
- Match validation to the change and complete required checks. Broaden or repeat passing checks only for new changes, failures, or unresolved concerns
- Do not add tests that only assert wording or mirror implementation details for low-impact edits

## Agents & Parallelism
- Delegate bounded, independent work when it saves time or adds useful scrutiny, while continuing useful work locally
- Give each agent a clear outcome, relevant context, and ownership boundaries. Avoid duplicate investigation and overlapping edits
- Batch independent reads and checks; keep dependent operations and shared mutations sequential

## Communication
- Lead with the outcome. Use concise, plain language and add structure only when it helps the reader
- Report what changed, meaningful validation, and any remaining blocker or limitation. Distinguish local checks from CI and live verification

## Documentation
- Only add comments when the code isn't self-explanatory
- Don't create README or documentation files unless explicitly asked
