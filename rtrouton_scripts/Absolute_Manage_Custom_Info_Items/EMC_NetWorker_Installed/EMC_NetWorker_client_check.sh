#!/bin/bash

CWD=`pwd`

if [ -d /nsr ]; then
	echo "Yes" >>  $CWD/nwtemp.txt
else
	echo "No" >>  $CWD/nwtemp.txt
fi
cat $CWD/nwtemp.txt
rm $CWD/nwtemp.txt