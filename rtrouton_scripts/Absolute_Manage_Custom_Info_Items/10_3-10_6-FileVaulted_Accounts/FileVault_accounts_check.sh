#!/bin/bash

CWD=`pwd`
USERS=$(ls -1 /Users)
OS=`/usr/bin/sw_vers | grep ProductVersion | cut -c 17-20`

for u in $USERS
do
	if [ "$u" = "Shared" ]; then
		echo > /dev/null
	else
		dscl . read /users/$u >> $CWD/temp.txt	
	fi
done

if [ "$OS" = "10.5" ]; then
	grep sparsebundle $CWD/temp.txt | cut -d / -f 5
elif [ "$OS" = "10.6" ]; then
	grep sparsebundle $CWD/temp.txt | cut -d / -f 5
else
	grep sparseimage $CWD/temp.txt | cut -d / -f 5
fi

rm $CWD/temp.txt