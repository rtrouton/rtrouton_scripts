#!/bin/zsh --no-rcs

# Set exit status

exitStatus=0

# Determine OS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

# Checks to see if the Mac is running macOS 15 or higher.
# If so, the script next tries to identify the logged-in user.
# If the Mac is not running macOS 15 or later, exit with an error.

if [[ ( ${osvers_major} -ge 15 ) ]]; then

# Identify the logged-in user
logged_in_user=$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }')

  # If there is a logged-in user, perform the following actions:
  # 
  # * Get the home folder and UID of the logged-in user.
  # * Set the Apple Intelligence pop-up window setting to be disabled.
  #
  # If there is no logged-in user identified, exit with an error.

  if [[ -n "$logged_in_user" ]]; then

   # Get logged-in user's home folder
   userHome=$(/usr/bin/dscl . -read "/Users/$logged_in_user" NFSHomeDirectory | /usr/bin/sed 's/^[^\/]*//g')

   # Identify the UID of the logged-in user
   logged_in_user_uid=$(/usr/bin/id -u "$logged_in_user")

   # Remove the trailing slash from the home directory path if needed.
   userHome=${userHome%%/}
   
   # Set the Apple Intelligence pop-up window setting to be disabled.
   /bin/launchctl asuser "$logged_in_user_uid" sudo -u "$logged_in_user" /usr/bin/defaults write "$userHome/Library/Preferences/com.apple.SetupAssistant" DidSeeIntelligence -bool true

  else
   echo "ERROR: No logged-in user identified."
   echo "ERROR: Apple Intelligence pop-up window setting not changed."
   exitStatus=1
  fi
else
  echo "ERROR: Mac is not running macOS 15 or later."
  exitStatus=1
fi

exit "$exitStatus"