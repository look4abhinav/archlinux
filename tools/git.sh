#! /usr/bin/bash

# Git Configuration for General Performance Improvement
git config --global core.preloadindex true
git config --global core.fsmonitor true
git config --global core.untrackedcache true
git config --global gc.auto 8000
git config --global pack.threads "0"
git config --global pack.windowMemory "1g"
git config --global pack.packSizeLimit "512m"
git config --global rebase.autoStash true
git config --global merge.autoStash true
git config --global push.default current
git config --global push.autoSetupRemote true
git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global branch.sort -committerdate
git config --global dif.algorithm histogram
git config --global help.autoCorrect prompt

# Aliases: (optional, recommended for workflow speed)
git config --global alias.st "status -s"
git config --global alias.ci "commit"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.lg "log --oneline --graph"

