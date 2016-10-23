#!/usr/bin/env bash

CURDIR="`pwd`"

PUBLIC_DIR=public
DEPLOY_DIR=kdbruin.github.io

if [ ! -d "../$DEPLOY_DIR" ]; then
	echo 'Cannot find deployment repository'
	exit 1
fi

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo

# Sync with the deployment directory
rsync -n -av --delete --exclude .git "$PUBLIC_DIR/" "../$DEPLOY_DIR"

# Go to deployment directory
cd "../$DEPLOY_DIR"

# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come back
cd "$CURDIR"

