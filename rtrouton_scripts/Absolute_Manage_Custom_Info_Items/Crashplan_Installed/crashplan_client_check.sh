#!/bin/bash

CWD=`pwd`

if [ -d /Applications/CrashPlan.app ]; then
	echo "Yes" >>  $CWD/crashplantemp.txt
else
	echo "No" >>  $CWD/crashplantemp.txt
fi
cat $CWD/crashplantemp.txt
rm $CWD/crashplantemp.txt