#!/usr/bin/env bash
# =============================================================
# Git Hands-On Lab — .gitignore automation script
# Based on: 2__Git-HOL.docx
#
# Objective:
#   - Create a ".log" file and a "log" folder in the Git working directory
#   - Update .gitignore so these (.log files and log/ folder) are ignored
#   - Verify with git status that they no longer show as untracked
#
# Usage:
#   1. Run this INSIDE an existing Git repo (e.g. the "GitDemo" repo
#      created in the previous lab). If you don't have one yet, this
#      script will optionally create one for you.
#   2. bash gitignore_setup.sh
# =============================================================

set -e

PROJECT_DIR="GitDemo"      # existing repo from the previous lab
LOG_FILE="app.log"         # sample ".log" file
LOG_FOLDER="log"           # sample "log" folder
LOG_FOLDER_FILE="log/debug.log"
GITIGNORE_FILE=".gitignore"
COMMIT_MESSAGE="Add .gitignore to exclude log files and log folder"

# ------------------------------------------------------------
# Step 0: Make sure we're inside a Git repo
# ------------------------------------------------------------
if [ ! -d ".git" ]; then
    if [ -d "$PROJECT_DIR/.git" ]; then
        echo "Moving into existing repo: $PROJECT_DIR"
        cd "$PROJECT_DIR"
    else
        echo "No Git repo found here or at ./$PROJECT_DIR."
        echo "Initializing a new one in ./$PROJECT_DIR ..."
        mkdir -p "$PROJECT_DIR"
        cd "$PROJECT_DIR"
        git init
    fi
fi

echo
echo "=== Step 1: Create a .log file and a log folder ==="

# Create a sample ".log" file in the working directory
echo "This is a sample log entry." > "$LOG_FILE"

# Create a "log" folder with a file inside it
mkdir -p "$LOG_FOLDER"
echo "Debug log entry." > "$LOG_FOLDER_FILE"

echo "Created: $LOG_FILE"
echo "Created: $LOG_FOLDER_FILE"

echo
echo "=== git status BEFORE .gitignore (both should show as untracked) ==="
git status

echo
echo "=== Step 2: Create/update .gitignore to exclude them ==="

# Add rules to ignore any ".log" file and the whole "log" folder,
# without duplicating lines if the script is re-run.
touch "$GITIGNORE_FILE"
grep -qxF '*.log' "$GITIGNORE_FILE"   || echo '*.log' >> "$GITIGNORE_FILE"
grep -qxF 'log/'   "$GITIGNORE_FILE"  || echo 'log/'   >> "$GITIGNORE_FILE"

echo "--- .gitignore content ---"
cat "$GITIGNORE_FILE"

echo
echo "=== Step 3: Verify git status AFTER .gitignore ==="
echo "(app.log and log/ should no longer appear as untracked)"
git status

echo
echo "=== Step 4: Commit the .gitignore file itself ==="
git add "$GITIGNORE_FILE"
git commit -m "$COMMIT_MESSAGE"

echo
echo "=== Final git status (working directory clean, log files ignored) ==="
git status

echo
echo "✅ Done. '*.log' files and the 'log/' folder are now ignored by Git."
echo "   Push this with: git push origin main   (or your branch name)"
