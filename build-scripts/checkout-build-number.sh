#!/bin/bash

BRANCH="$1"
BUILD_NUMBER="$2"

if [ "$BRANCH" == "" -o "$BUILD_NUMBER" == "" ]; then
    echo "Updates the files in the working tree to match a specific build number in a branch:"
    echo ""
    echo "Usage: $(basename $0) <branch> <build number>"
    echo "<branch>        The git branch that generated the build you'd like to check out (e.g. \"dev\")."
    echo "<build number>  The build number you'd like to check out (e.g. 1528)."
    echo ""
    exit 1
fi

CURRENT=`git rev-list "$BRANCH" --count`
DIFF=`expr $CURRENT - $BUILD_NUMBER`

git rev-list "$BRANCH" --skip=$DIFF | head -1 | xargs git checkout