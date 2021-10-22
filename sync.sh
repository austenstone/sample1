#!/bin/bash
set -x

# Cleanup remotes.
git remote rm sample1 || true
git remote rm sample2 || true

# Add all the remotes that exist.
git remote add sample1 git@github.com:astone2014/sample1.git
git remote add sample2 git@github.com:astone2014/sample2.git

# Fetch from all remotes.
git fetch --all

# Merge all remote main branches.
git merge origin/main sample1/main sample2/main

# Cleanup push remotes.
git remote set-url --delete --push origin sample.*

# Add all remotes to push to.
git remote set-url --add --push origin git@github.com:astone2014/sample1.git
git remote set-url --add --push origin git@github.com:astone2014/sample2.git

# push main
git push origin main