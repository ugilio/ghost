#!/bin/bash
#Inspired by https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
set -e

BRANCH="master"
PAGES="gh-pages"

#This script should only be run on master
if [ "z$TRAVIS_BRANCH" != "z$BRANCH" ]
then
  exit 0;
fi

eval `ssh-agent -s`
ssh-add `dirname $0`/deploy_key

cd $TRAVIS_BUILD_DIR

REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
UPDZIP=`ls $TRAVIS_BUILD_DIR/com.github.ugilio.ghost.updatesite/target/com.github.ugilio.ghost.updatesite-*.zip`
UPDDIR=update/unstable

cd "$HOME"
git clone $REPO --branch "$PAGES" --single-branch "$PAGES"
cd "$PAGES"

#Remove unstable update site dir, together with any commit that created it
git filter-branch -f --tree-filter "rm -Rf $UPDDIR" --prune-empty "$PAGES"

mkdir -p $UPDDIR
cd $UPDDIR
unzip -d . $UPDZIP

cd "$HOME/$PAGES"
git config user.name "Travis CI"
git config user.email "Travis CI"

git add -A .
git commit -m "Updated unstable Eclipse update site (commit $TRAVIS_COMMIT)"

git push -f $SSH_REPO $PAGES

cd $TRAVIS_BUILD_DIR
