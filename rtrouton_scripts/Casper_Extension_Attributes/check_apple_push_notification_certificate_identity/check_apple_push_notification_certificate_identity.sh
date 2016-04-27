#!/bin/bash

osvers_major=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $2}')

# Checks to see if the OS on the Mac is 10.x.x. If it is not, the 
# following message is displayed without quotes:
#
# "NA"
#
# NA stands for Not Applicable.

if [[ ${osvers_major} -ne 10 ]]; then
  result="NA"
fi

# Checks to see if the OS on the Mac is 10.7.x or higher.
# If it is not, the following message is displayed without quotes:
#
# "NA"
#
# NA stands for Not Applicable.

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 7 ]]; then
  result="NA"
fi

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 7 ]]; then
 
# Checks the Apple Push Notification Service certificate identifier
# on Macs running 10.7.x or higher. If an Apple Push Notification 
# Service certificate identifier is not returned, the following message
# is displayed without quotes:
#
# "NA"
#
# NA stands for Not Applicable.
#
# Otherwise the Apple Push Notification Service certificate identifier
# is returned as the result.

  APNS_certificate=`/usr/sbin/system_profiler SPConfigurationProfileDataType | awk '/Topic/{ print $NF }' | sed 's/[";]//g'`

  if [[ "$APNS_certificate" = "" ]]; then
      result="NA"
  else
      result="$APNS_certificate"
  fi

fi

/bin/echo "<result>$result</result>"