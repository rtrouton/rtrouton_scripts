#!/bin/bash
 
# If any previous instances of the runcasperinventory LaunchDaemon and script exist,
# unload the LaunchDaemon and remove the LaunchDaemon and script files
 
if [[ -f "/Library/LaunchDaemons/com.github.runcasperinventory.plist" ]]; then
   /bin/launchctl unload "/Library/LaunchDaemons/com.github.runcasperinventory.plist"
   /bin/rm "/Library/LaunchDaemons/com.github.runcasperinventory.plist"
fi
 
if [[ -f "/var/root/runcasperinventory.sh" ]]; then
   /bin/rm "/var/root/runcasperinventory.sh"
fi
 
# Create the runcasperinventory LaunchDaemon by using cat input redirection
# to write the XML contained below to a new file.
#
# The LaunchDaemon will run at load and every ten minutes thereafter.
 
/bin/cat > "/tmp/com.github.runcasperinventory.plist" << 'CASPER_POST_OS_UPGRADE_LAUNCHDAEMON'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.github.runcasperinventory</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>/var/root/runcasperinventory.sh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>600</integer>
</dict>
</plist>
CASPER_POST_OS_UPGRADE_LAUNCHDAEMON
 
# Create the runcasperinventory script by using cat input redirection
# to write the shell script contained below to a new file.
#
# You will need to change the "jss_server_address" variable in the
# script below. Please put the complete fully qualified domain name 
# address of your Casper server.
#
# You may need to change the "jss_server_port" variable in the
# script below. Please put the port number of your Casper server
# if it is different than 8443.
 
/bin/cat > "/tmp/runcasperinventory.sh" << 'CASPER_POST_OS_UPGRADE_SCRIPT'
#!/bin/bash
 
#
# User-editable variables
#
 
# For the jss_server_address variable, put the complete 
# fully qualified domain name address of your Casper server
 
jss_server_address="casper.server.address.here"
 
# For the jss_server_address variable, put the port number 
# of your Casper server. This is usually 8443; change as
# appropriate.
 
jss_server_port="8443"

CheckBinary (){

# Identify location of jamf binary.

jamf_binary=`/usr/bin/which jamf`

 if [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ ! -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/sbin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ ! -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 fi
}
 
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
  ping=`host -W .5 $jss_server_address`
 
  # If the ping fails - site_network="False"
  [[ $? -eq 0 ]] && site_network="True"
 
  # Check if we are using a test
  [[ -n "$1" ]] && site_network="$1"
}
 
CheckTomcat (){
 
# Verifies that the JSS's Tomcat service is responding via its assigned port.
 
 
tomcat_chk=`nc -z -w 5 $jss_server_address $jss_server_port > /dev/null; echo $?`
 
if [ "$tomcat_chk" -eq 0 ]; then
       /usr/bin/logger "Machine can connect to $jss_server_address over port $jss_server_port. Proceeding."
else
       /usr/bin/logger "Machine cannot connect to $jss_server_address over port $jss_server_port. Exiting."
       exit 0
fi
 
}
 
CheckLogAge (){
 
# Verifies that the /var/log/jamf.log hasn't been written to for at least five minutes.
# This should help ensure that jamf manage can run and not have to wait for a policy to
# finish running.
 
jamf_log="/var/log/jamf.log"
current_time=`date +%s`
last_modified=`stat -f %m "$jamf_log"`
 
if [[ $(($current_time-$last_modified)) -gt 300 ]]; then 
     /usr/bin/logger "Log has not been modified in the past five minutes. Proceeding." 
else 
     /usr/bin/logger "Log has been modified in the past five minutes. Exiting."
     exit 0
fi
 
}
 
UpdateManagementAndInventory (){
 
# Verifies that the Mac can communicate with the Casper server.
# Once communication is verified, it takes the following actions:
#
# 1. Runs jamf manage to enforce Casper management 
# 2. Runs a recon to send an updated inventory to the JSS to report
#    that the OS upgrade has happened.
#
 
CheckBinary
 
jss_comm_chk=`$jamf_binary checkJSSConnection > /dev/null; echo $?`
 
if [[ "$jss_comm_chk" -gt 0 ]]; then
       /usr/bin/logger "Machine cannot connect to the JSS. Exiting."
       exit 0
elif [[ "$jss_comm_chk" -eq 0 ]]; then
       /usr/bin/logger "Machine can connect to the JSS. Enforcing management and updating inventory."
       $jamf_binary manage -verbose
       $jamf_binary recon
fi
}
 
SelfDestruct (){
 
# Removes script and associated LaunchDaemon
 
if [[ -f "/Library/LaunchDaemons/com.github.runcasperinventory.plist" ]]; then
   /bin/rm "/Library/LaunchDaemons/com.github.runcasperinventory.plist"
fi
rm -rf $0
}
 
CheckSiteNetwork
 
if [[ "$site_network" == "False" ]]; then
    /usr/bin/logger "Unable to verify access to site network. Exiting."
fi 
 
 
if [[ "$site_network" == "True" ]]; then
    /usr/bin/logger "Access to site network verified"
    CheckTomcat
    CheckLogAge
    CheckBinary
    UpdateManagementAndInventory
    SelfDestruct
fi
exit 0
CASPER_POST_OS_UPGRADE_SCRIPT
 
# Once the LaunchDaemon file has been created, fix the permissions
# so that the file is owned by root:wheel and set to not be executable
# After the permissions have been updated, move the LaunchDaemon into 
# place in /Library/LaunchDaemons.
 
/usr/sbin/chown root:wheel "/tmp/com.github.runcasperinventory.plist"
/bin/chmod 755 "/tmp/com.github.runcasperinventory.plist"
/bin/chmod a-x "/tmp/com.github.runcasperinventory.plist"
/bin/mv "/tmp/com.github.runcasperinventory.plist" "/Library/LaunchDaemons/com.github.runcasperinventory.plist"
 
# Once the script file has been created, fix the permissions
# so that the file is owned by root:wheel and set to be executable
# After the permissions have been updated, move the script into the
# place that it will be executed from.
 
/usr/sbin/chown root:wheel "/tmp/runcasperinventory.sh"
/bin/chmod 755 "/tmp/runcasperinventory.sh"
/bin/chmod a+x "/tmp/runcasperinventory.sh"
/bin/mv "/tmp/runcasperinventory.sh" "/var/root/runcasperinventory.sh"
 
# After the LaunchDaemon and script are in place with proper permissions,
# load the LaunchDaemon to begin the script's execution.

if [[ -f "/Library/LaunchDaemons/com.github.runcasperinventory.plist" ]]; then 
   /bin/launchctl load -w "/Library/LaunchDaemons/com.github.runcasperinventory.plist" 
fi 

exit 0