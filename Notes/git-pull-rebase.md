# Git Pull Best Practices: Why Use `--rebase`

## The Problem with Regular `git pull`

When multiple developers work on the same branch, using `git pull` creates **merge commits** that clutter the commit history, making it difficult to track specific features or bug fixes.

## The Solution: `git pull --rebase`

This command maintains a clean, linear commit history by:
1. Temporarily setting aside your local commits
2. Pulling the latest changes from the remote repository
3. Reapplying your commits on top of the updated branch

**Result:** A cleaner, linear commit history that's easier to navigate and understand.

## Handling Merge Conflicts

If `git pull --rebase` encounters conflicts, you have two options:

### Option 1: Abort the Rebase
```bash
git rebase --abort
```
This reverts your repository to its state before the pull.

### Option 2: Pull Normally
After aborting, perform a regular `git pull` and resolve conflicts as usual:
```bash
git pull
```

## Best Practices

- **Always try `git pull --rebase` first** for a cleaner history
- **Create an alias** to save typing:
```bash
  git config --global alias.pr 'pull --rebase'
```
  Then use: `git pr`

## Summary

- `git pull` → Creates merge commits (cluttered history)
- `git pull --rebase` → Linear history (cleaner and more maintainable)
- When conflicts occur → Abort and fall back to regular pull if needed