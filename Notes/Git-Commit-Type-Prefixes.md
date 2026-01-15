# Git Commit Type Prefixes

## Common Types

### **feat**: New Feature
- Adding new functionality or capabilities
- Example: `feat: Add user authentication system`

### **fix**: Bug Fix
- Fixing bugs or issues in existing code
- Example: `fix: Resolve login redirect loop`

### **docs**: Documentation
- Changes to documentation only (README, comments, guides)
- Example: `docs: Update API usage examples`

### **chore**: Maintenance Tasks
- Routine tasks, maintenance, or updates that don't modify src or test files
- Example: `chore: Update dependencies to latest versions`


### **style**: Code Style/Formatting
- Changes that don't affect code meaning (whitespace, formatting, semicolons)
- Example: `style: Format code with prettier`

### **refactor**: Code Refactoring
- Restructuring code without changing functionality
- Example: `refactor: Simplify authentication logic`

### **test**: Testing
- Adding or updating tests
- Example: `test: Add unit tests for user service`

### **perf**: Performance Improvements
- Code changes that improve performance
- Example: `perf: Optimize database queries`

### **build**: Build System
- Changes to build process or tools (webpack, npm, gulp)
- Example: `build: Update webpack configuration`

### **ci**: CI/CD Configuration
- Changes to CI/CD pipelines (GitHub Actions, Jenkins)
- Example: `ci: Add automated deployment workflow`

### **revert**: Revert Changes
- Reverting previous commits
- Example: `revert: Revert "feat: Add experimental feature"`

## Format Convention
```
<type>(<optional scope>): <description>

[optional body]

[optional footer]
```

### Examples:
```
feat(auth): Add OAuth2 login support
fix(ui): Resolve button alignment issue on mobile
docs(readme): Add installation instructions
chore(notes): Add Git rebase best practices guide