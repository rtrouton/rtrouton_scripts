#!/bin/bash

# Script for use with Jamf Pro when you want to trigger an update of the management framework, followed by an inventory update.
#
# The LaunchDaemon and accompanying script created by running this script verifies that the Mac can communicate with the Jamf Pro server.
# Once communication is verified, it takes the following actions:
# 
# Checks to see if the /var/log/jamf.log file has been modified in the previous five minutes.
#
# Once it has been verified that the /var/log/jamf.log file has not been modified for at least the last five minutes,
# the script runs the following functions:
# 
# Runs jamf manage to enforce the management framework using the latest available data from the Jamf Pro server
# Runs jamf recon to send an updated inventory to the Jamf Pro server
# Deletes LaunchDaemon file
# Deletes script file
# Unloads LaunchDaemon
#
#
# Note: The "runjamfproinventoryupdate.sh" script which is part of this script has the following variable set:
#
# jamfpro_server_port="443"
#
# This port is correct for all Jamf Cloud-hosted installations of Jamf Pro.
#
# If your Jamf Pro server is not using port 443, please change this port to the correct number.
# For on-premise Jamf Pro installations, this port is most commonly port 8443. If your Jamf Pro
# server is using port 8443, the variable should look like this:
#
# jamfpro_server_port="8443"
#

# If any previous instances of the runjamfproinventoryupdate LaunchDaemon and script exist,
# unload the LaunchDaemon and remove the LaunchDaemon and script files
 
if [[ -n $(/bin/launchctl list | grep "com.github.runjamfproinventoryupdate") ]]; then
   /bin/launchctl bootout system/com.github.runjamfproinventoryupdate
fi
 
# Delete LaunchDaemon and script files files if they exist
/bin/rm -f \
    "/Library/LaunchDaemons/com.github.runjamfproinventoryupdate.plist" \
    "/var/root/runjamfproinventoryupdate.sh"
 
# Create the runjamfproinventoryupdate LaunchDaemon by using cat input redirection
# to write the XML contained below to a new file.
#
# The LaunchDaemon will run at load and every minute thereafter.
 
temp_directory=$(mktemp -d) 

/bin/cat > "$temp_directory/com.github.runjamfproinventoryupdate.plist" << 'JAMF_PRO_INVENTORY_UPDATE_LAUNCHDAEMON'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.github.runjamfproinventoryupdate</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>/var/root/runjamfproinventoryupdate.sh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>60</integer>
</dict>
</plist>
JAMF_PRO_INVENTORY_UPDATE_LAUNCHDAEMON
 
# Create the runjamfproinventoryupdate script by using cat input redirection
# to write the shell script contained below to a new file.
 
/bin/cat > "$temp_directory/runjamfproinventoryupdate.sh" << 'JAMF_PRO_INVENTORY_UPDATE_SCRIPT'
#!/bin/bash
 
jamfpro_server_address=$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)
jamfpro_server_address="${jamfpro_server_address#*//}"
jamfpro_server_address="${jamfpro_server_address%%/}"

jamfpro_server_port="443"

jamf_binary="/usr/local/jamf/bin/jamf"

CheckSiteNetwork (){
 
  #  CheckSiteNetwork function adapted from Facebook's check_corp function script.
  #  check_corp script available on Facebook's IT-CPE Github repo:
  #
  # check_corp:
  #   This script verifies a system is on the corporate network.
  #   Input: CORP_URL= set this to a hostname on your corp network
  #   Optional ($1) contains a parameter that is used for testing.
  #   Output: Returns a check_corp variable that will return "True" if on 
  #   corp network, "False" otherwise.
  #   If a parameter is passed ($1), the check_corp variable will return it
  #   This is useful for testing scripts where you want to force check_corp
  #   to be either "True" or "False"
  # USAGE: 
  #   check_corp        # No parameter passed
  #   check_corp "True"  # Parameter of "True" is passed and returned
  
 
  site_network="False"
  ping=$(host -W .5 $jamfpro_server_address)
 
  # If the ping fails - site_network="False"
  [[ $? -eq 0 ]] && site_network="True"
 
  # Check if we are using a test
  [[ -n "$1" ]] && site_network="$1"
}
 
CheckTomcat (){
 
# Verifies that the JSS's Tomcat service is responding.
 
 
tomcat_chk=$(nc -z -w 5 $jamfpro_server_address $jamfpro_server_port > /dev/null; echo $?)
 
if [ "$tomcat_chk" -eq 0 ]; then
       /usr/bin/logger "Machine can connect to $jamfpro_server_address. Proceeding."
else
       /usr/bin/logger "Machine cannot connect to $jamfpro_server_address. Exiting."
       exit 0
fi
 
}
 
CheckLogAge (){
 
# Verifies that the /var/log/jamf.log hasn't been written to for at least five minutes.
# This should help ensure that both an inventory update and check-in can run and not 
# have to wait for a policy to finish running.
 
jamf_log="/var/log/jamf.log"
current_time=$(date +%s)
last_modified=$(stat -f %m "$jamf_log")
 
if [[ $(($current_time-$last_modified)) -gt 300 ]]; then 
     /usr/bin/logger "Log has not been modified in the past five minutes. Proceeding." 
else 
     /usr/bin/logger "Log has been modified in the past five minutes. Exiting."
     exit 0
fi
 
}
 
UpdateManagementAndInventory (){
 
# Verifies that the Mac can communicate with the Jamf Pro server.
# Once communication is verified, it takes the following actions:
#
# 1. Runs jamf manage to enforce the Jamf Pro management framework
# 2. Runs jamf recon to send an updated inventory to the Jamf Pro server
#
 
jss_comm_chk=$($jamf_binary checkJSSConnection > /dev/null; echo $?)
 
if [[ "$jss_comm_chk" -gt 0 ]]; then
       /usr/bin/logger "Machine cannot connect to the JSS. Exiting."
       exit 0
elif [[ "$jss_comm_chk" -eq 0 ]]; then
       /usr/bin/logger "Machine can connect to the JSS. Updating management framework and updating inventory."
       $jamf_binary manage
       $jamf_binary recon
fi
}
 
SelfDestruct (){
 
# Removes script and associated LaunchDaemon

if [[ -f "/Library/LaunchDaemons/com.github.runjamfproinventoryupdate.plist" ]]; then
   /bin/rm "/Library/LaunchDaemons/com.github.runjamfproinventoryupdate.plist"
fi

rm -rf $0

if [[ -n $(/bin/launchctl list | grep "com.github.runjamfproinventoryupdate") ]]; then
   /bin/launchctl bootout system/com.github.runjamfproinventoryupdate
fi
}
 
CheckSiteNetwork
 
if [[ "$site_network" == "False" ]]; then
    /usr/bin/logger "Unable to verify access to site network. Exiting."
fi 
 
 
if [[ "$site_network" == "True" ]]; then
    /usr/bin/logger "Access to site network verified"
    CheckTomcat
    CheckLogAge
    UpdateManagementAndInventory
    SelfDestruct
fi
exit 0
JAMF_PRO_INVENTORY_UPDATE_SCRIPT
 
# Once the LaunchDaemon file has been created, fix the permissions
# so that the file is owned by root:wheel and set to not be executable
# After the permissions have been updated, move the LaunchDaemon into 
# place in /Library/LaunchDaemons.
 
/usr/sbin/chown root:wheel "${temp_directory}/com.github.runjamfproinventoryupdate.plist"
/bin/chmod 644 "${temp_directory}/com.github.runjamfproinventoryupdate.plist"
/bin/chmod a-x "${temp_directory}/com.github.runjamfproinventoryupdate.plist"
/bin/mv "${temp_directory}/com.github.runjamfproinventoryupdate.plist" "/Library/LaunchDaemons/com.github.runjamfproinventoryupdate.plist"
 
# Once the script file has been created, fix the permissions
# so that the file is owned by root:wheel and set to be executable
# After the permissions have been updated, move the script into the
# place that it will be executed from.
 
/usr/sbin/chown root:wheel "$temp_directory/runjamfproinventoryupdate.sh"
/bin/chmod 755 "$temp_directory/runjamfproinventoryupdate.sh"
/bin/chmod a+x "$temp_directory/runjamfproinventoryupdate.sh"
/bin/mv "$temp_directory/runjamfproinventoryupdate.sh" "/var/root/runjamfproinventoryupdate.sh"
 
# After the LaunchDaemon and script are in place with proper permissions,
# load the LaunchDaemon to begin the script's execution.

if [[ -f "/Library/LaunchDaemons/com.github.runjamfproinventoryupdate.plist" ]] && [[ -x "/var/root/runjamfproinventoryupdate.sh" ]]; then 
   /bin/launchctl bootstrap system "/Library/LaunchDaemons/com.github.runjamfproinventoryupdate.plist" 
fi

# Remove temp directory

/bin/rm -rf "$temp_directory"

exit 0