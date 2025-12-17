# Global Claude Code Preferences

## Package Managers & Tools
- Always use **UV** when interacting with Python codebases
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

## Testing
- Write tests that test behavior, not implementation
- Use descriptive test names that explain the scenario
- Follow Arrange-Act-Assert pattern

## Documentation
- Only add comments when the code isn't self-explanatory
- Don't create README or documentation files unless explicitly asked
