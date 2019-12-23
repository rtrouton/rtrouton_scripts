#!/bin/bash

exported_theme_file=$(mktemp)
exported_temp_directory=$(mktemp -d -t terminal-theme-XXXXXXXXXX)
import_plist_file="$HOME/Library/Preferences/com.apple.Terminal.plist"
export_plist_file="$exported_temp_directory/com.apple.Terminal.plist"
uuid_1=$(uuidgen)
uuid_2=$(uuidgen)
uuid_3=$(uuidgen)

IFS= read -r -p "Enter name of the Terminal profile to export from your Terminal settings: " terminal_profile_name
IFS= read -r -p "What is the name of your company, school or institution? [optional]: " payload_organization

echo "Do you want to set the exported Terminal profile as being a default Terminal profile?"
select yn in "Yes" "No"; do
    	case $yn in
        	Yes) /usr/bin/defaults write "$export_plist_file" "Default Window Settings" -string "${terminal_profile_name}"; /usr/bin/defaults write "$export_plist_file" "Startup Window Settings" -string "${terminal_profile_name}"; default_profile=1; echo "Exported Terminal profile is set as a default Terminal profile."; break;;
        	No ) echo "Exported Terminal profile will not be set as a default Terminal profile."; break;;
    	esac
done

if [[ -z "$default_profile" ]]; then
    description="This configuration profile installs the ${terminal_profile_name} Terminal profile."
else
    description="This configuration profile installs the ${terminal_profile_name} Terminal profile and sets it as the default Terminal profile."
fi

/usr/bin/plutil -extract Window\ Settings."${terminal_profile_name}" xml1 -o - "$import_plist_file" > "$exported_theme_file"

import_theme=$(<"$exported_theme_file")

/usr/bin/defaults write "$export_plist_file" "Window Settings" -dict

/usr/bin/plutil -replace Window\ Settings."${terminal_profile_name}" -xml "$import_theme" "$export_plist_file"
/usr/bin/plutil -convert xml1 "$export_plist_file"

edited_input_data=$(cat "$export_plist_file" | sed '1,4d;$d' | sed '$d' | tidy -xml -iq)

configuration_profile_buildfile=$(mktemp)
 
/bin/cat > "$configuration_profile_buildfile" << TERMINAL_PROFILE_CONFIGURATION_PROFILE
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadContent</key>
	<array>
		<dict>
			<key>PayloadContent</key>
			<dict>
				<key>com.apple.Terminal</key>
				<dict>
					<key>Forced</key>
					<array>
						<dict>
							<key>mcx_preference_settings</key>
							<dict>
							$edited_input_data
							</dict>
						</dict>
					</array>
				</dict>
			</dict>
			<key>PayloadEnabled</key>
			<true/>
			<key>PayloadIdentifier</key>
			<string>$uuid_1.terminal.profile.settings.$uuid_2</string>
			<key>PayloadType</key>
			<string>com.apple.ManagedClient.preferences</string>
			<key>PayloadUUID</key>
			<string>$uuid_2</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
		</dict>
	</array>
	<key>PayloadDescription</key>
	<string>${description}</string>
	<key>PayloadDisplayName</key>
	<string>Sets ${terminal_profile_name} Terminal profile</string>
	<key>PayloadIdentifier</key>
	<string>${terminal_profile_name}.$uuid_3.terminal.profile.settings.</string>
	<key>PayloadOrganization</key>
	<string>${payload_organization}</string>
	<key>PayloadRemovalDisallowed</key>
	<false/>
	<key>PayloadScope</key>
	<string>System</string>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>$uuid_1</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
</dict>
</plist>
TERMINAL_PROFILE_CONFIGURATION_PROFILE

#cat "$configuration_profile_buildfile" | tidy -xml -iq > "$exported_temp_directory"/"${terminal_profile_name} Terminal Settings.mobileconfig"
cat "$configuration_profile_buildfile" | xmllint --format - > "$exported_temp_directory"/"${terminal_profile_name} Terminal Settings.mobileconfig"
echo "Exported ${terminal_profile_name} Terminal Settings.mobileconfig file is available at the following location: $exported_temp_directory"
open "$exported_temp_directory"
