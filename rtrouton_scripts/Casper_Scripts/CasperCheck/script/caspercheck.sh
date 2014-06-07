#!/bin/bash

#
# User-editable variables
#

# For the fileURL variable, put the complete address 
# of the zipped Casper QuickAdd installer package
 
fileURL="http://server_name_here.domain.com/quickadd_name_goes_here.zip"
 
# For the jss_server_address variable, put the complete 
# fully qualified domain name address of your Casper server
 
jss_server_address="server_name_here.domain.com"
 
# For the jss_server_address variable, put the port number 
# of your Casper server. This is usually 8443; change as
# appropriate.
 
jss_server_port="8443"

# For the log_location variable, put the preferred 
# location of the log file for this script. If you 
# don't have a preference, using the default setting
# should be fine.

log_location="/var/log/caspercheck.log"

#
# The variables below this line should not need to be edited.
# Use caution if doing so. 
#

quickadd_dir="/var/root/quickadd"
quickadd_zip="/tmp/quickadd.zip"
quickadd_installer="$quickadd_dir/casper.pkg"
quickadd_timestamp="$quickadd_dir/quickadd_timestamp"

#
# Begin function section
# =======================
#

# Function to provide custom curl options
myCurl () { /usr/bin/curl -k --retry 3 --silent --show-error "$@"; }

# Function to provide logging of the script's actions to
# the log file defined by the log_location variable

ScriptLogging(){

    DATE=`date +%Y-%m-%d\ %H:%M:%S`
    LOG="$log_location"
    
    echo "$DATE" " $1" >> $LOG
}

CheckForNetwork(){

# Determine if the network is up by looking for any non-loopback network interfaces.

    local test
    
    if [[ -z "${NETWORKUP:=}" ]]; then
        test=$(ifconfig -a inet 2>/dev/null | sed -n -e '/127.0.0.1/d' -e '/0.0.0.0/d' -e '/inet/p' | wc -l)
        if [[ "${test}" -gt 0 ]]; then
            NETWORKUP="-YES-"
        else
            NETWORKUP="-NO-"
        fi
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

#
# The update_quickadd function checks the timestamp of the fileURL variable and compares it against a locally
# cached timestamp. If the hosted file's timestamp is newer, then the Casper 
# QuickAdd installer gets downloaded and extracted into the target directory.
#
# This function uses the myCurl function defined at the top of the script.
#

update_quickadd () {

    # Get modification date of fileURL
    
    modDate=$(myCurl --head $fileURL 2>/dev/null | awk -F': ' '/Last-Modified/{print $2}')

    # Downloading Casper agent installer
    
    ScriptLogging "Downloading Casper agent installer from server."
    
    myCurl --output "$quickadd_zip" $fileURL
    
    # Check to make sure download occurred
    
    if [[ ! -f "$quickadd_zip" ]]; then
        ScriptLogging "$quickadd_zip not found. Exiting CasperCheck."
        ScriptLogging "======== CasperCheck Finished ========"
        exit 0
    fi
    
    # Verify that the downloaded zip file is a valid zip archive.

    zipfile_chk=`/usr/bin/unzip -tq $quickadd_zip > /dev/null; echo $?`

    if [ "$zipfile_chk" -eq 0 ]; then
       ScriptLogging "Downloaded zip file appears to be a valid zip archive. Proceeding."
    else
       ScriptLogging "Downloaded zip file appears to be corrupted. Exiting CasperCheck."
       ScriptLogging "======== CasperCheck Finished ========"
       rm "$quickadd_zip"
       exit 0
    fi
    
    # Create the destination directory if needed
    
    if [[ ! -d "$quickadd_dir" ]]; then
        mkdir "$quickadd_dir"
    fi
    
    # If needed, remove existing files from the destination directory
    
    if [[ -d "$quickadd_dir" ]]; then
        /bin/rm -rf "$quickadd_dir"/*
    fi
    
    # Unzip the Casper agent install into the destination directory
    # and remove the __MACOSX directory, which is created as part of
    # the uncompression process from the destination directory.
    
    /usr/bin/unzip "$quickadd_zip" -d "$quickadd_dir";/bin/rm -rf "$quickadd_dir"/__MACOSX
    
    # Rename newly-downloaded installer to be casper.pkg
    
    mv "$(/usr/bin/find $quickadd_dir -maxdepth 1 \( -iname \*\.pkg -o -iname \*\.mpkg \))" "$quickadd_installer"
    
    # Remove downloaded zip file
    if [[ -f "$quickadd_zip" ]]; then
        /bin/rm -rf "$quickadd_zip"
    fi
    
    # Add the quickadd_timestamp file to the destination directory. 
    # This file is used to help verify if the current Casper agent 
    # installer is already cached on the machine.
    
    if [[ ! -f "$quickadd_timestamp" ]]; then
        echo $modDate > "$quickadd_timestamp"
    fi   
    
    
}

CheckTomcat (){
 
# Verifies that the JSS's Tomcat service is responding via its assigned port.


tomcat_chk=`nc -z -w 5 $jss_server_address $jss_server_port > /dev/null; echo $?`

if [ "$tomcat_chk" -eq 0 ]; then
       ScriptLogging "Machine can connect to $jss_server_address over port $jss_server_port. Proceeding."
else
       ScriptLogging "Machine cannot connect to $jss_server_address over port $jss_server_port. Exiting CasperCheck."
       ScriptLogging "======== CasperCheck Finished ========"
       exit 0
fi

}

CheckInstaller (){
 
# Compare timestamps and update the Casper agent
# installer if needed.

    modDate=$(myCurl --head $fileURL 2>/dev/null | awk -F': ' '/Last-Modified/{print $2}')

if [[ -f "$quickadd_timestamp" ]]; then
    cachedDate=$(cat "$quickadd_timestamp")
    
    
    if [[ "$cachedDate" == "$modDate" ]]; then
        ScriptLogging "Current Casper installer already cached."
    else
        update_quickadd
    fi
else
    update_quickadd
fi

}

InstallCasper () {

 # Check for the cached Casper QuickAdd installer and run it
 # to fix problems with Casper being able to communicate with
 # the Casper server
 
 if [[ ! -e "$quickadd_installer" ]] ; then
    ScriptLogging "Casper installer is missing. Downloading."
    /bin/rm -rf "$quickadd_timestamp"
    update_quickadd
 fi
 
  if [[ -e "$quickadd_installer" ]] ; then
    ScriptLogging "Casper installer is present. Installing."
    /usr/sbin/installer -dumplog -verbose -pkg "$quickadd_installer" -target /
    ScriptLogging "Casper agent has been installed."
 fi
 

}

CheckCasper () {

  #  CheckCasper function adapted from Facebook's jamf_verify.sh script.
  #  jamf_verify script available on Facebook's IT-CPE Github repo:
  #  Link: https://github.com/facebook/IT-CPE



  # Checking for the jamf binary
  if [[ ! -f "/usr/sbin/jamf" ]]; then
    ScriptLogging "Casper's jamf binary is missing. It needs to be reinstalled."
    InstallCasper
  fi

  # Verifying Permissions
  /usr/bin/chflags noschg /usr/sbin/jamf
  /usr/bin/chflags nouchg /usr/sbin/jamf
  /usr/sbin/chown root:wheel /usr/sbin/jamf
  /bin/chmod 755 /usr/sbin/jamf
  
  # Verifies that the JSS is responding to a communication query 
  # by the Casper agent. If the communication check returns a result
  # of anything greater than zero, the communication check has failed.
  # If the communication check fails, reinstall the Casper agent using
  # the cached installer.


  jss_comm_chk=`/usr/sbin/jamf checkJSSConnection > /dev/null; echo $?`

  if [[ "$jss_comm_chk" -eq 0 ]]; then
       ScriptLogging "Machine can connect to the JSS on $jss_server_address."
  elif [[ "$jss_comm_chk" -gt 0 ]]; then
       ScriptLogging "Machine cannot connect to the JSS on $jss_server_address."
       ScriptLogging "Reinstalling Casper agent to fix problem of Casper not being able to communicate with the JSS."
       InstallCasper
  fi

  # Checking if machine can run a manual trigger
  # This section will need to be edited if the policy
  # being triggered has different options than the policy
  # described below:
  #
  # Trigger: iscasperup
  # Plan: Run Script iscasperonline.sh
  # 
  # The iscasperonline.sh script contains the following:
  #
  # | #!/bin/sh
  # |
  # | echo "up"
  # |
  # | exit 0
  #

  
  jamf_policy_chk=`/usr/sbin/jamf policy -trigger iscasperup | grep "Script result: up"`

  # If the machine can run the specified policy, exit the script.

  if [[ -n "$jamf_policy_chk" ]]; then
    ScriptLogging "Casper enabled and able to run policies"

  # If the machine cannot run the specified policy, 
  # reinstall the Casper agent using the cached installer.

  elif [[ ! -n "$jamf_policy_chk" ]]; then
    ScriptLogging "Reinstalling Casper agent to fix problem of Casper not being able to run policies"
    InstallCasper
  fi


}

#
# End function section
# ====================
#

# The functions and variables defined above are used
# by the section below to check if the network connection
# is live, if the machine is on a network where
# the Casper JSS is accessible, and if the Casper agent on the
# machine can contact the JSS and run a policy.
#
# If the Casper agent on the machine cannot run a policy, the appropriate
# functions run and repair the Casper agent on the machine.
#

ScriptLogging "======== Starting CasperCheck ========"

# Wait up to 60 minutes for a network connection to become 
# available which doesn't use a loopback address. This 
# condition which may occur if this script is run by a 
# LaunchDaemon at boot time.
#
# The network connection check will occur every 5 seconds
# until the 60 minute limit is reached.


ScriptLogging "Checking for active network connection."
CheckForNetwork
i=1
while [[ "${NETWORKUP}" != "-YES-" ]] && [[ $i -ne 720 ]]
do
    sleep 5
    NETWORKUP=
    CheckForNetwork
    echo $i
    i=$(( $i + 1 ))
done

# If no network connection is found within 60 minutes,
# the script will exit.

if [[ "${NETWORKUP}" != "-YES-" ]]; then
   ScriptLogging "Network connection appears to be offline. Exiting CasperCheck."
fi
   

if [[ "${NETWORKUP}" == "-YES-" ]]; then
   ScriptLogging "Network connection appears to be live."
  
  # Sleeping for 120 seconds to give WiFi time to come online.
  ScriptLogging "Pausing for two minutes to give WiFi and DNS time to come online."
  sleep 120
  CheckSiteNetwork

  if [[ "$site_network" == "False" ]]; then
    ScriptLogging "Unable to verify access to site network. Exiting CasperCheck."
  fi 


  if [[ "$site_network" == "True" ]]; then
    ScriptLogging "Access to site network verified"
    CheckTomcat
    CheckInstaller
    CheckCasper
  fi

fi

ScriptLogging "======== CasperCheck Finished ========"

exit 0
