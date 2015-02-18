#!/bin/bash

username="username_goes_here"
ad_domain="domain_name_goes_here"
check_domain=$( dsconfigad -show | awk '/Active Directory Domain/{print $NF}' )

if [[ "$check_domain" != "$ad_domain" ]]; then
  result="NA"
  echo "<result>$result</result>"
fi

if [[ "$check_domain" == "$ad_domain" ]]; then

  id $username

  if [ $? -ne 0 ]; then
     sleep 240

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

fi

exit 0