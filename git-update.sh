#!/bin/sh

test -f .git/config && sed -i "s/\/\/github/\/\/joschro@github/" .git/config
test -n "$(git config --global user.email)" || git config --global user.email "jo@joschro.de"

git pull
git add -A
git commit -a
git push

