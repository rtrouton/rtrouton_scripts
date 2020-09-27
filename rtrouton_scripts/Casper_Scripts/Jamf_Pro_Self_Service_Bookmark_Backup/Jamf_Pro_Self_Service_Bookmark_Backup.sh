#!/bin/bash

# This script is designed to do the following:
# 
# 1. If necessary, create a directory for storing backup copies of Jamf Pro Self Service bookmark files.
# 2. Make copies of the Self Service bookmark files.
# 3. Name the copied files using the title of the Self Service bookmark.
# 4. Store the copied bookmarks in the specified directory.
#

# If you choose to specify a directory to save the Self Service bookmarks into,
# please enter the complete directory path into the SelfServiceBookmarkBackupDirectory
# variable below.

SelfServiceBookmarkBackupDirectory=""

# If the SelfServiceBookmarkBackupDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

error=0

if [[ -z "$SelfServiceBookmarkBackupDirectory" ]]; then
   SelfServiceBookmarkBackupDirectory=$(mktemp -d)
   echo "A location to store copied bookmarks has not been specified."
   echo "Copied bookmarks will be stored in $SelfServiceBookmarkBackupDirectory."
fi

self_service_bookmarks="/Library/Application Support/JAMF/Self Service/Managed Plug-ins"

for bookmark in "$self_service_bookmarks"/*.plist
do
  echo "Processing "$bookmark" file..."
  bookmark_name=$(/usr/bin/defaults read "$bookmark" title)
  cat "$bookmark" > "$SelfServiceBookmarkBackupDirectory/${bookmark_name}.plist"
  if [[ $? -eq 0 ]]; then
     echo "$bookmark_name.plist processed and stored in $SelfServiceBookmarkBackupDirectory."
  else
     echo "ERROR! Problem occurred when processing $self_service_bookmarks/$bookmark file!"
     error=1
  fi
done

exit $error