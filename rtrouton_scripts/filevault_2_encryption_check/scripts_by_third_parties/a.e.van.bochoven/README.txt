This script was written and contributed by A.E. van Bochoven:

Script runs on both 10.7.x and 10.8.x

Most notable changes from original script:
- The OS check is now at the start of the script, so it bails early
- The OS check should be more robust, catering for OS versions like 10.10 or 11.1
- Script is faster because there's just one call to diskutil cs list
- Some grep changes (-q instead of 1>/dev/null)
- Indentation cleanup
