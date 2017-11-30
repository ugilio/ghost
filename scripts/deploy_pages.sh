#!/bin/bash
set -e

SCRIPTDIR=`dirname $0`

#Are we building a release?
if [ "z$TRAVIS_TAG" != "z" ]
then
  source $SCRIPTDIR/deploy_pages_release.sh
else
  source $SCRIPTDIR/deploy_pages_unstable.sh
fi

