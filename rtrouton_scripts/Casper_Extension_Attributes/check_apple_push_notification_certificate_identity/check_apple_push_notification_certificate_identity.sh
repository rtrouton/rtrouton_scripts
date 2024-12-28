#!/bin/bash
 
# Checks the Apple Push Notification Service certificate identifier. If
# an Apple Push Notification Service certificate identifier is not returned, 
# the following message is displayed without quotes:
#
# "NA"
#
# NA stands for Not Applicable.
#
# Otherwise the Apple Push Notification Service certificate identifier
# is returned as the result.

APNS_certificate=`/usr/sbin/system_profiler SPConfigurationProfileDataType | awk '/com.apple.mgmt/{ print $NF }' | sed 's/[";]//g'`

if [[ "$APNS_certificate" = "" ]]; then
      result="NA"
else
      result="$APNS_certificate"
fi

/bin/echo "<result>$result</result>"