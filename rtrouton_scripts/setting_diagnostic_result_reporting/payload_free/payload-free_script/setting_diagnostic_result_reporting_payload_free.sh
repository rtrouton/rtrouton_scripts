#!/bin/bash

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
sw_vers=$(sw_vers -productVersion)

# Set whether you want to send diagnostic info back to
# Apple and/or third party app developers. If you want
# to send diagonostic data to Apple, set the following 
# value for the SUBMIT_DIAGNOSTIC_DATA_TO_APPLE value:
#
# SUBMIT_DIAGNOSTIC_DATA_TO_APPLE=TRUE
# 
# If you want to send data to third party app developers,
# set the following value for the
# SUBMIT_DIAGNOSTIC_DATA_TO_APP_DEVELOPERS value:
#
# SUBMIT_DIAGNOSTIC_DATA_TO_APP_DEVELOPERS=TRUE
# 
# By default, the values in this script are set to 
# send no diagnostic data: 

SUBMIT_DIAGNOSTIC_DATA_TO_APPLE=FALSE
SUBMIT_DIAGNOSTIC_DATA_TO_APP_DEVELOPERS=FALSE

# To change this in your own script, comment out the FALSE
# lines and uncomment the TRUE lines as appropriate.

# Set the appropriate number value for AutoSubmitVersion
# and ThirdPartyDataSubmitVersion by the OS version. For
# 10.10.x, the value will be 4. For 10.11.x, the value will
# be 5.

if [[ ${osvers} -eq 10 ]]; then
  VERSIONNUMBER=4
elif [[ ${osvers} -ge 11 ]]; then
  VERSIONNUMBER=5
fi


# Checks first to see if the Mac is running 10.10.0 or higher. 
# If so, the desired diagnostic submission settings are applied.

if [[ ${osvers} -ge 10 ]]; then

  CRASHREPORTER_SUPPORT="$3/Library/Application Support/CrashReporter"
 
  if [ ! -d "${CRASHREPORTER_SUPPORT}" ]; then
    mkdir "${CRASHREPORTER_SUPPORT}"
    chmod 775 "${CRASHREPORTER_SUPPORT}"
    chown root:admin "${CRASHREPORTER_SUPPORT}"
  fi

 /usr/bin/defaults write "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory AutoSubmit -boolean ${SUBMIT_DIAGNOSTIC_DATA_TO_APPLE}
 /usr/bin/defaults write "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory AutoSubmitVersion -int ${VERSIONNUMBER}
 /usr/bin/defaults write "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory ThirdPartyDataSubmit -boolean ${SUBMIT_DIAGNOSTIC_DATA_TO_APP_DEVELOPERS}
 /usr/bin/defaults write "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory ThirdPartyDataSubmitVersion -int ${VERSIONNUMBER}
 /bin/chmod a+r "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory.plist
 /usr/sbin/chown root:admin "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory.plist
fi

exit 0