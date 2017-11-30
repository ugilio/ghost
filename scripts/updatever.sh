#!/bin/bash
PATTERN='String GHOSTC_VERSION = ';
VERFILE="com.github.ugilio.ghost.standalonecompiler/src/main/java/com/github/ugilio/ghost/standalonecompiler/Main.java"

NEWVER="$1"
OLDVER=`egrep "$PATTERN" "$VERFILE" | perl -p -e "s/^.*$PATTERN\"([^\"]+)\".*$/\1/"`

function toBundleVer() {
  echo "$1" | egrep '\-SNAPSHOT$' > /dev/null
  local isSnap=$?
  if [ $isSnap == 0 ]
  then
    echo $(echo $1 | perl -p -e 's/-.*$//').qualifier
  else
    echo $1
  fi
}

OLDQVER=`toBundleVer $OLDVER`
NEWQVER=`toBundleVer $NEWVER`

if [ "z$NEWVER" == "z" ]
then
  echo "Usage: $0 <newversion>" > /dev/stderr
  exit 1
fi

if [ "z$OLDVER" == "z" ]
then
  echo "Cannot find old version" > /dev/stderr
  exit 1
fi

echo "Updating version from $OLDVER to $NEWVER..."

perl -p -i -e "s/$OLDVER/$NEWVER/g" `find com.github.ugilio* -type f -name pom.xml` $VERFILE

if [ "$OLDQVER" != "$NEWQVER" ]
then
  perl -p -i -e "s/(\s*Bundle-Version:\s*)$OLDQVER/\${1}$NEWQVER/g" `find com.github.ugilio* -type f -name MANIFEST.MF`
  perl -p -i -e "s/$OLDQVER/$NEWQVER/" com.github.ugilio.ghost.sdk/feature.xml 
fi
