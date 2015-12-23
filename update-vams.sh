#!/bin/bash

# NOTE: This script won't work if you don't have the vams-subtree remote set up:
#  --> git remote add vams-subtree https://github.com/TouchFrame/VAMS.git

git subtree pull --prefix=build-scripts/VAMS vams-subtree master --squash
