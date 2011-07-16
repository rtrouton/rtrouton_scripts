#!/bin/bash

USERS=$(ls -1 /Users)

for u in $USERS
do
       if [[ $u = .* ]]; then
               echo > /dev/null
       elif [[ "$u" = Deleted* || "$u" = Users* ]]; then
               echo > /dev/null
       elif [ "$u" = "Shared" ]; then
               echo > /dev/null
       else
               echo $u
       fi
done