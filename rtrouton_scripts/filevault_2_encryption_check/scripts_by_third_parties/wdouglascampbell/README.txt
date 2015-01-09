This script was written and contributed by wdouglascampbell (https://github.com/wdouglascampbell):

Script runs on both 10.7.x and higher

Most notable changes from original script:
- The OS check has been updated to support Darwin versions via the uname command 
- Adds future-proofing in the event the OS version no longer starts with 10.x.x in the the future.
- Does not use temp files
- Fixes an issue with handling multiple encrypted volumes by returning only the encryption status of the boot volume.
