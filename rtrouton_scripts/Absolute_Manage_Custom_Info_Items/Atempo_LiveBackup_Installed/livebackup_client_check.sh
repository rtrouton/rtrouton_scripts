#!/bin/bash

CWD=`pwd`

if [ -d /Applications/LiveBackup.app ]; then
	echo "Yes" >>  $CWD/lbtemp.txt
else
	echo "No" >>  $CWD/lbtemp.txt
fi
cat $CWD/lbtemp.txt
rm $CWD/lbtemp.txt