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
   echo "A location to store downloaded bookmarks has not been specified."
   echo "Downloaded bookmarks will be stored in $SelfServiceBookmarkBackupDirectory."
fi

self_service_bookmark_file="$HOME/Library/Application Support/com.jamfsoftware.selfservice.mac/CocoaAppCD.storedata"

if [[ -r "$self_service_bookmark_file" ]]; then
    tmp_dir="/private/tmp/bookmark-workdir-$(date +%y%m%d%H%M%S)"
    mkdir -p "$tmp_dir"
    
    # For the next command, add a trailing slash for
    # the the tmp_dir variable if it's not there.
    
    length=${#tmp_dir}
    last_char=${tmp_dir:length-1:1}
    [[ $last_char != "/" ]] && tmp_dir="$tmp_dir/";
    
    sed -n '/SSBOOKMARK/,/object/p' "$self_service_bookmark_file" | awk -v a=$tmp_dir '/SSBOOKMARK/{filename=a""++i".xml"}; {print >filename}' -
    
    #remove trailing slash if needed from the bookmark and tmp directories
    
    SelfServiceBookmarkBackupDirectory=${SelfServiceBookmarkBackupDirectory%%/}
    tmp_dir=${tmp_dir%%/}
    
    for file in "$tmp_dir"/*
    do
    
      # Add XML declaration to first line if not already present in the file.
      # This will allow xmllint to format the XML in human-readable format.
    
      if [[ -z $(cat $file | grep "<?xml version="1.0" encoding="UTF-8"?>") ]]; then
         echo -e "<?xml version="\""1.0"\"" encoding="\""UTF-8"\""?>\n$(cat $file)" > $file
      fi
    
      bookmark_name=$(cat $file | awk -F '[<>]' '/"name"/{print $3}')
      xmllint --format "$file" > "$file"_formatted.xml
      mv "$file"_formatted.xml "$SelfServiceBookmarkBackupDirectory/$bookmark_name".xml
      if [[ $? -eq 0 ]]; then
         echo "$bookmark_name.xml processed and stored in $SelfServiceBookmarkBackupDirectory."
      else
         echo "ERROR! Problem occurred when processing $self_service_bookmark_file file!"
         error=1
      fi
      
    done
    
    rm -rf "$tmp_dir"
else
    echo "Cannot read $self_service_bookmark_file"
fi

exit $error
