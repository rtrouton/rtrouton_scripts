#!/bin/bash

username=AD_account_here

id $username

if [ $? -ne 0 ]; then
   sleep 120

   id $username
   if [ $? -ne 0 ]; then
      result=No
      echo "<result>$result</result>"
   fi

   id $username
   if [ $? -eq 0 ]; then
      result=Yes
      echo "<result>$result</result>"
   fi
  exit 0
fi

if [ $? -eq 0 ]; then
      result=Yes
      echo "<result>$result</result>"
fi