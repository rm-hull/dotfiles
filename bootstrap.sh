#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE}")"
git pull origin main
git submodule init
git submodule update --init --recursive
git submodule foreach '
  branch=$(git config -f $toplevel/.gitmodules submodule.$name.branch || echo master)
  echo "Updating $name on branch $branch"
  git fetch origin $branch
  git checkout $branch
  git pull origin $branch
'

cd .pyenv
git pull origin master
git submodule init
git submodule update
git submodule foreach git pull origin master
cd ..


function doIt() {
    rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
        --exclude "README.md" --exclude "LICENSE-MIT.txt" -av --no-perms . ~
    source ~/.bash_profile
}
if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt
    fi
fi
unset doIt
