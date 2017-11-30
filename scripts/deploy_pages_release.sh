#!/bin/bash
#Inspired by https://gist.github.com/domenic/ec8b0fc8ab45f39403dd
set -e

PAGES="gh-pages"

VERSION=`echo $TRAVIS_TAG | perl -p -e 's/^v(\d+(\.\d+)*)$/\1/'` # vX.Y.Z => X.Y.Z

#This script should only be run when building new releases
if [ "z$TRAVIS_TAG" == "z" -o "z$TRAVIS_TAG" == "z$VERSION" ]
then
  exit 0;
fi

eval `ssh-agent -s`
ssh-add `dirname $0`/deploy_key

cd $TRAVIS_BUILD_DIR

REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
UPDZIP=$TRAVIS_BUILD_DIR/com.github.ugilio.ghost.updatesite/target/com.github.ugilio.ghost.updatesite-$VERSION.zip
UPDDIR=update/$TRAVIS_TAG
VERFILE="_includes/latestrelease.inc"

cd "$HOME"
git clone $REPO --branch "$PAGES" --single-branch "$PAGES"
cd "$PAGES"
rm -Rf $UPDDIR
mkdir -p $UPDDIR
rm -f update/latest
ln -s $TRAVIS_TAG update/latest
echo -n $VERSION > $VERFILE

cd $UPDDIR
unzip -d . $UPDZIP

cd "$HOME/$PAGES"
git config user.name "Travis CI"
git config user.email "Travis CI"

git add -A .
git commit -m "Added Eclipse Update Site for release $VERSION"

git push $SSH_REPO $PAGES

cd $TRAVIS_BUILD_DIR
