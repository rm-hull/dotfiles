#!/bin/bash

if [ $(uname) = "Darwin" ]; then
  cmd="/Applications/p4merge.app/Contents/Resources/launchp4merge"
else
  cmd="/usr/local/bin/p4merge"
fi
  
$cmd $*