#!/bin/bash

username=AD_account_here

id $username 1>/dev/null
if [ $? -eq 0 ]; then
      result=Yes
else
      result=No
fi
echo $result
