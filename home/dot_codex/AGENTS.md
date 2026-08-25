# Global Codex Preferences

## Package Managers & Tools
- Always use **UV** when interacting with Python codebases or tools
- Always use the **UV's build backend `uv_build`** unless specified otherwise
- Always make use of available linters, language servers, and formatting tools
- Use **cargo** for Rust projects

## Docker & Containers
- When a required tool is not installed locally, prefer using **Docker** instead of asking the user to install it
- Always check for existing `.devcontainer/` configs or `docker-compose.yml` / `Dockerfile` before suggesting new setups
- Leverage devcontainers when available for consistent development environments

## Code Style
- Write concise, readable code - avoid over-engineering
- Prefer explicit over implicit
- Use meaningful variable and function names
- Keep functions small and focused on a single responsibility

## Git Workflow
- Write clear, descriptive commit messages focusing on "why" not "what"
- Keep commits atomic - one logical change per commit
- Always check `git status` before committing
- Before finishing committed or pushed work, check whether the repo defines CI in `.github/workflows/`, `Taskfile.yml`, `justfile`, `Makefile`, package scripts, or similar project automation

## Testing
- Write tests that verify code behavior, not implementation details
- Focus tests on application logic and user-visible behavior, not incidental config-file structure
- Use descriptive test names that explain the scenario
- Follow Arrange-Act-Assert pattern
- Prefer parametrized test suites when they make related scenarios clearer without hiding important differences
- When a repo has CI, take a reasonable local stab at reproducing the relevant pipeline before calling the work done
- Run the available test, formatting, linting, type-checking, and build commands that correspond to the files changed
- If the full CI pipeline is impractical locally, run the closest meaningful subset and clearly report what was and was not verified

## Agents & Parallelism
- Leverage **subagents** and **agent teams** as much as possible to parallelize work
- Prefer spawning multiple agents for independent tasks (e.g., research, testing, code review) rather than doing them sequentially
- Use agent teams for complex multi-step workflows where different agents can own different responsibilities
- Default to running independent agents in parallel to maximize throughput

## Documentation
- Only add comments when the code isn't self-explanatory
- Don't create README or documentation files unless explicitly asked
