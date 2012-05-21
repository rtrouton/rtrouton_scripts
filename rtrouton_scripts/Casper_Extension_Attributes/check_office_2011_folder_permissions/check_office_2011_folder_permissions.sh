#!/bin/sh

if ls -ld /Applications/Microsoft\ Office\ 2011 > /dev/null; then
  if ls -ld /Applications/Microsoft\ Office\ 2011 | grep -q ^drwxrwxr-x
    then
     result=Yes         
    else
     result=No               
   fi
   echo "<result>$result</result>"
fi
