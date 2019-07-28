#!/bin/bash

echo "\033[0;32mDeploying updates to GitHub...\033[0m"

cd ../yongju-jin.github.io

if [[ $(git status -s) ]]
then
    echo "The directory is dirty. Please commit any pending changes."
    cd ../$(dirname "$0")
    exit 1;
fi
rm -rf *
cd $(dirname "$0")
hugo -d ../yongju.jin.github.io/
cd ../yongju-jin.github.io
# Add changes to git
git add --all
# Commit changes
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

git commit -m "$msg" -s
# Push source and build repos.
git push origin master

# Come Back up to the Project Root
cd ../$(dirname "$0")