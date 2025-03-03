#!/bin/zsh --no-rcs

# This Jamf Pro extension attribute detects the email address of the user who is signed into Microsoft Outlook.
#
# If a valid email address is detected, similar output to what is shown below is returned as the result:
#
# firstname.lastname@company.com
#
# In all other cases, the value below is returned:
#
# Email Address Not Detected

# Set default value for Extension Attribute if valid email address not detected.

result="Email Address Not Detected"

# Identify the logged-in user
logged_in_user=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }')

  # If there is a logged-in user, perform the following actions:
  # 
  # * Get the home folder and UID of the logged-in user.
  # * Verify that the ~/Library/Containers/com.microsoft.Outlook/Data/Library/Preferences/com.microsoft.Outlook.plist file exists and is readable for the logged-in user.
  # * Get the email address of the primary user configured in Microsoft Outlook from the com.microsoft.Outlook.plist file.

  if [[ -n "$logged_in_user" ]]; then

   # Get logged-in user's home folder
   userHome=$(/usr/bin/dscl . -read "/Users/$logged_in_user" NFSHomeDirectory | /usr/bin/sed 's/^[^\/]*//g')

   # Identify the UID of the logged-in user
   logged_in_user_uid=$(/usr/bin/id -u "$logged_in_user")

   # Remove the trailing slash from the home directory path if needed.
   userHome=${userHome%%/}
   
   # Verify that ~/Library/Containers/com.microsoft.Outlook/Data/Library/Preferences/com.microsoft.Outlook.plist file exists and is readable for the logged-in user.
   
   outlook_config_file="$userHome/Library/Containers/com.microsoft.Outlook/Data/Library/Preferences/com.microsoft.Outlook.plist"
   
   if [[ -r "$outlook_config_file" ]]; then
   
   email_address_setting_key="clientConfigsLastUpdatedTime"
   
   # Get primary email address for Outlook and verify that it looks like an email address.
   outlook_email_address=$(/bin/launchctl asuser "$logged_in_user_uid" sudo -u "$logged_in_user" /usr/bin/plutil -extract "$email_address_setting_key" raw "$outlook_config_file")
     if [[ "$outlook_email_address" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
      result="$outlook_email_address"
     fi
   fi
fi

echo "<result>$result</result>"
exit 0