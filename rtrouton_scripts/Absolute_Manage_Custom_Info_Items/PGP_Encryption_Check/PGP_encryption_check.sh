#!/bin/bash

CWD=`pwd`

if [ -f /PGPWDE01 ]; then
	echo "Yes" >>  $CWD/pgptemp.txt
else
	echo "No" >>  $CWD/pgptemp.txt
fi
cat $CWD/pgptemp.txt
rm $CWD/pgptemp.txt