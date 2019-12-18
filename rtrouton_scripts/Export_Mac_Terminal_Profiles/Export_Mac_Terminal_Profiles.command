#!/bin/bash

exported_theme_file=$(mktemp)
exported_temp_directory=$(mktemp -d -t terminal-theme-XXXXXXXXXX)
import_plist_file="$HOME/Library/Preferences/com.apple.Terminal.plist"
export_plist_file="$exported_temp_directory/com.apple.Terminal.plist"

IFS= read -r -p "Enter name of the Terminal profile to export from your Terminal settings: " terminal_profile_name

echo "Do you want to set the exported Terminal profile as being a default Terminal profile?"
select yn in "Yes" "No"; do
    	case $yn in
        	Yes) /usr/bin/defaults write "$export_plist_file" "Default Window Settings" -string "${terminal_profile_name}"; /usr/bin/defaults write "$export_plist_file" "Startup Window Settings" -string "${terminal_profile_name}"; echo "Exported Terminal profile is set as a default Terminal profile."; break;;
        	No ) echo "Exported Terminal profile will not be set as a default Terminal profile."; break;;
    	esac
done

/usr/bin/plutil -extract Window\ Settings."${terminal_profile_name}" xml1 -o - "$import_plist_file" > "$exported_theme_file"

import_theme=$(<"$exported_theme_file")

/usr/bin/defaults write "$export_plist_file" "Window Settings" -dict

/usr/bin/plutil -replace Window\ Settings."${terminal_profile_name}" -xml "$import_theme" "$export_plist_file"
/usr/bin/plutil -convert xml1 "$export_plist_file"

echo "Exported com.apple.Terminal.plist is available at the following location: $export_plist_file"
open "$exported_temp_directory"