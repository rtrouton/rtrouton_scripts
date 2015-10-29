#!/bin/bash

# This script is designed to automate the setup of OS X Server 5.0.3 and later
# by authorizing and using the 'server' tool within /Applications/Server.app to
# run the initial setup and configuration of OS X Server's services.

# Script will check for the existence of the 'server' setup tool. If the 'server' setup tool
# is not located where the script expects it to be, the script will exit.

if [[ ! -e "/Applications/Server.app/Contents/ServerRoot/usr/sbin/server" ]]; then
  echo "/Applications/Server.app/Contents/ServerRoot/usr/sbin/server is not available. Script will exit."
  exit 0
fi

# If the 'server' setup tool is located, script will proceed and run
# the initial setup and configuration of OS X Server's services. 

if [[ -e "/Applications/Server.app/Contents/ServerRoot/usr/sbin/server" ]]; then

  serverdotapp_username=serverdotappuser
  serverdotapp_password=$(openssl rand -base64 32)
  serverdotapp_user_name="Server App User"
  serverdotapp_user_hint="No hint for you!"
  serverdotapp_user_shell=/usr/bin/false
  serverdotapp_user_group=20
  serverdotapp_user_image="/Library/User Pictures/Fun/Chalk.tif"

  create_temp_user() {
  
    # Generate UID for user by identifying the numerically highest UID
    # currently in use on this machine then setting the "userUID" value
    # to be one number higher.
    
    maxUID=$(/usr/bin/dscl . list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)
    userUID=$((maxUID+1))
  
	/usr/bin/dscl . create /Users/${serverdotapp_username}
	/usr/bin/dscl . passwd /Users/${serverdotapp_username} ${serverdotapp_password}
	/usr/bin/dscl . create /Users/${serverdotapp_username} UserShell ${serverdotapp_user_shell}
	/usr/bin/dscl . create /Users/${serverdotapp_username} UniqueID "$userUID"
	/usr/bin/dscl . create /Users/${serverdotapp_username} PrimaryGroupID ${serverdotapp_user_group}
	/usr/bin/dscl . create /Users/${serverdotapp_username} RealName "${serverdotapp_user_name}"
	/usr/bin/dscl . create /Users/${serverdotapp_username} Picture "${serverdotapp_user_image}"
	/usr/bin/dscl . create /Users/${serverdotapp_username} Hint "${serverdotapp_user_hint}"
  }

  promote_temp_user_to_admin() {
	/usr/sbin/dseditgroup -o edit -a $serverdotapp_username -t user admin
  }

  delete_temp_user() {
	/usr/bin/dscl . delete /Users/${serverdotapp_username}
  }

  # Create temporary user to authorize Server setup
  # and give admin rights to that temporary user
  
  create_temp_user
  promote_temp_user_to_admin
  
  # Export temporary user's username and password as environment values.
  # This export will allow these values to be used by the expect section
  
  export serverdotapp_setupadmin="$serverdotapp_username"
  export serverdotapp_setupadmin_password="$serverdotapp_password"

  # Accept the Server.app license and set up the server tools

/usr/bin/expect<<EOF
set timeout 300
spawn /Applications/Server.app/Contents/ServerRoot/usr/sbin/server setup
puts "$serverdotapp_setupadmin"
puts "$serverdotapp_setupadmin_password"

expect "Press Return to view the software license agreement." { send \r }
expect "Do you agree to the terms of the software license agreement? (y/N)" { send "y\r" }
expect "User name:" { send "$serverdotapp_setupadmin\r" }
expect "Password:" { send "$serverdotapp_setupadmin_password\r" }
expect "%"
EOF

  # Delete temporary user
  delete_temp_user

fi