This script sets whether you want to send diagnostic info from Yosemite and later back to Apple and/or third party app developers by setting the appropriate values in **/Library/Application Support/CrashReporter/DiagnosticMessagesHistory.plist**.

If you want to send diagnostic and usage data to Apple, set the following value in the script for the **SUBMIT_DIAGNOSTIC_DATA_TO_APPLE** value:

`SUBMIT_DIAGNOSTIC_DATA_TO_APPLE=TRUE`

If you want to send crash data to third party app developers, set the following value in the script for the **SUBMIT_DIAGNOSTIC_DATA_TO_APP_DEVELOPERS** value:

`SUBMIT_DIAGNOSTIC_DATA_TO_APP_DEVELOPERS=TRUE`

By default, the values in this script are set to send no diagnostic data, either to Apple or to third party app developers:

`SUBMIT_DIAGNOSTIC_DATA_TO_APPLE=FALSE` 

`SUBMIT_DIAGNOSTIC_DATA_TO_APP_DEVELOPERS=FALSE`

To change this in your own script, comment out the **FALSE** lines and uncomment the **TRUE** lines as appropriate.
  
**Installer package**

I've built a payload-free installer package which is available for download from the **payload-free** directory. This installer package runs the script using the following values:

`SUBMIT_DIAGNOSTIC_DATA_TO_APPLE=FALSE` 

`SUBMIT_DIAGNOSTIC_DATA_TO_APP_DEVELOPERS=FALSE`

These settings will set the Mac in question to send no diagnostic data, either to Apple or to third party app developers.