#!/bin/bash

# Create a /tmp/icons.XXXX directory to
# store the copied images and icon files
 
TMPDIR=`/usr/bin/mktemp -d /tmp/icons.XXXX`

# The function below uses the image file 
# format specified by the "filetype" variable 
# to copy the relevant image and icon files
# from /Applications and /System/Library

GetIcons () {

mkdir "$TMPDIR"/"$filetype"
mkdir "$TMPDIR"/"$filetype"/Applications
mkdir "$TMPDIR"/"$filetype"/System

echo "Copying $filetype files to $TMPDIR/$filetype"
find /Applications 2>/dev/null -iname "*.$filetype" -type f -print0 | xargs -0 -I '{}' cp "{}" $TMPDIR/$filetype/Applications 2>/dev/null
find /System/Library 2>/dev/null -iname "*.$filetype" -type f -print0 | xargs -0 -I '{}' cp "{}" $TMPDIR/$filetype/System 2>/dev/null
 

}

filetype="icns"
GetIcons

filetype="png"
GetIcons

filetype="pdf"
GetIcons

echo "All finished! Copied images and icon files are available in $TMPDIR"