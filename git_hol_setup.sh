#!/usr/bin/env bash
# =============================================================
# Git Hands-On Lab — automation script
# Based on: 1__Git-HOL.docx
#
# Covers:
#   Step 1: Git configuration (user.name / user.email)
#   Step 2: Set notepad++ as the default Git editor (Windows/Git Bash only)
#   Step 3: Create a repo, add a file, commit, and push it to GitHub
#
# Usage:
#   1. Edit the CONFIG section below with your details.
#   2. Run:  bash git_hol_setup.sh
# =============================================================

set -e  # stop the script if any command fails

# ------------------ CONFIG (edit these) ------------------
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="you@example.com"

# Create an empty repo on GitHub first (e.g. named "GitDemo"),
# then paste its HTTPS or SSH URL here:
REMOTE_URL="https://github.com/<your-username>/GitDemo.git"

PROJECT_DIR="GitDemo"
FILE_NAME="welcome.txt"
FILE_CONTENT="Welcome to Git Hands-On Lab!"
COMMIT_MESSAGE="Initial commit: add welcome.txt"
BRANCH="main"   # GitHub's default branch is now 'main' (was 'master')

# Path to notepad++ (only needed on Windows Git Bash).
# Leave as-is if you're not on Windows, or update the path.
NOTEPADPP_PATH="/c/Program Files/Notepad++/notepad++.exe"
# ------------------------------------------------------------

echo "=== Step 1: Git Configuration ==="

# 1. Confirm Git is installed
git --version

# 2. Set global user name & email
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

# 3. Verify the configuration
echo "--- Current Git config ---"
git config --global user.name
git config --global user.email

echo
echo "=== Step 2: Set Notepad++ as default editor (optional, Windows only) ==="
if [ -f "$NOTEPADPP_PATH" ]; then
    git config --global core.editor "'$NOTEPADPP_PATH' -multiInst -notabbar -nosession -noPlugin"
    echo "Default editor set to Notepad++."
    git config --global -e --no-edit >/dev/null 2>&1 || true
    echo "--- Editor config ---"
    git config --global core.editor
else
    echo "Skipping: Notepad++ not found at '$NOTEPADPP_PATH'."
    echo "Update NOTEPADPP_PATH in this script if you're on Windows and want this step."
fi

echo
echo "=== Step 3: Add a file to the source code repository ==="

# 1. Create the project folder and move into it
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# 2. Initialize the Git repository
git init

# 3. Confirm initialization (shows hidden .git folder)
ls -la

# 4. Create the file and add content
echo "$FILE_CONTENT" > "$FILE_NAME"

# 5. Verify the file was created and check its content
ls -la "$FILE_NAME"
cat "$FILE_NAME"

# 6. Check repository status (file is untracked so far)
git status

# 7. Stage the file so Git tracks it
git add "$FILE_NAME"

# 8. Commit the file with a message
#    (the -m flag avoids opening the default editor for the commit message)
git commit -m "$COMMIT_MESSAGE"

# 9. Confirm the working directory is now clean
git status

echo
echo "=== Push to GitHub ==="

# 10. Rename branch to match GitHub's default (main), if needed
git branch -M "$BRANCH"

# 11. Link the local repo to your GitHub remote repository
git remote add origin "$REMOTE_URL"

# 12. Pull first in case the remote already has content (e.g. a README)
#     --allow-unrelated-histories avoids merge errors on a brand-new repo
git pull origin "$BRANCH" --allow-unrelated-histories --rebase || true

# 13. Push the local commit(s) to GitHub
git push -u origin "$BRANCH"

echo
echo "✅ Done. '$FILE_NAME' has been pushed to: $REMOTE_URL"
