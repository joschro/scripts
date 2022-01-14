#!/bin/sh

test -f .git/config && sed -i "s/\/\/github/\/\/joschro@github/" .git/config
test -n "$(git config --global user.email)" || git config --global user.email "jo@joschro.de"

rpm -q gh || {
  dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  dnf install gh -y
}
gh auth status || {
  gh config set git_protocol https -h github.com
  gh auth setup-git
  echo -n "Please enter your GitHub access token: "; read ANSW
  echo "$ANSW" | gh auth login --with-token
}

git pull
git add -A
git commit -a
git push

