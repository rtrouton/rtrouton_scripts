#!/bin/bash

# This script is designed to install a Jamf Infrastructure Manager (JIM)
# on the following OSs:
#
# CentOS 7.x
# Red Hat Enterprise Linux 7.x
#
# Following installation, the JIM is enrolled with a specified Jamf Pro 
# server, using credentials provided in the script.

# Set Jamf Pro URL, username and password for the JIM enrollment process

jamfProURL="https://jamf.pro.server.here:8443"
jamfProUsername="jamf_pro_account_username_goes_here"
jamfProPassword="jamf_pro_account_password_goes_here"

# Set the Jamf Infrastructure Manager hostname for the JIM enrollment process
# This should be the external hostname which the Jamf Pro server will be 
# connecting to the JIM through. For example, if you have a load balancer sitting
# in front of the JIM, the load balancer is going to be the JIM's hostname.
#
# Note: The hostname of the machine must resolve both for the machine 
# hosting the JIM and for the remote Jamf Pro server, so there can’t be 
# mismatches like having the JIM server itself think its hostname is 
# blahblah.int.company.com and the remote Jamf Pro server think the JIM's
# hostname is blehbleh.ext.company.com.
# 
# If necessary, set an entry into the /etc/hosts file on your 
# JIM server similar to what's shown below so that your JIM server's
# IP address maps to the hostname you're using for the JIM's hostname.
#
# ip.address.goes.here    blehbleh.ext.company.com

jimHostname="jim_hostname_goes_here"

# If the JIM hostname, Jamf Pro URL, the account username or the account password aren't available
# otherwise, you will be prompted to enter the requested hostname, URL or account credentials.

if [[ -z "$jamfProURL" ]]; then
     read -p "Please enter your Jamf Pro server URL : " jamfProURL
fi

if [[ -z "$jimHostname" ]]; then
     read -p "Please enter the hostname of your Jamf Infrastructure Manager: " jimHostname
fi

if [[ -z "$jamfProUsername" ]]; then
     read -p "Please enter your Jamf Pro user account : " jamfProUsername
fi

if [[ -z "$jamfProPassword" ]]; then
     read -p "Please enter the password for the $jamfProUsername account: " -s jamfProPassword
fi

echo ""

# Set directory to store the JIM software installer

jamfinfrastructuremanager_installer_directory="/path/to/installer_directory"

function checkJava()	{

	# Check to see if Java is installed. If
	# Java isn't installed, install OpenJDK 8.x 

	java -version &> /dev/null
	if [[ $? -eq 0 ]]; then
		echo "Java is installed."
		echo "$(java -version)"
	else
		echo "Java not installed. Installing OpenJDK 8.x."
		/usr/bin/yum -y install java-1.8.0-openjdk
		echo ""
		echo "Installed Java:"
		echo "$(java -version)"
	fi
}

# Check to see if Java is already installed and install OpenJDK 8.x
# if Java is not installed.

checkJava

# Locate the Jamf Infrastructure Manager installer .rpm file.
# To assist with this, make sure the JIM installer .rpm file 
# has "jamf-im" (no quotes) as part of the rpm's filename.

if [[ -e "$(/usr/bin/find $jamfinfrastructuremanager_installer_directory -maxdepth 3 \( -iname \*jamf-im*\.rpm \))" ]]; then
      installer_path="$(/usr/bin/find $jamfinfrastructuremanager_installer_directory -maxdepth 3 \( -iname \*jamf-im*\.rpm \))"
fi

# Install Jamf Infrastructure Manager

if [[ ! -z "$installer_path" ]]; then
    echo "Jamf Infrastructure Manager installer .rpm file located at $installer_path. Installing."
    rpm -i "$installer_path"
    if [[ $? -ne 0 ]]; then
        echo "Jamf Infrastructure Manager installation failed."
        exit 1
    else
        echo "Jamf Infrastructure Manager installation succeeded."
    fi
fi

# Verify that the /etc/jamf-im/ directory exists. If the directory exists, 
# the JIM software is installed and can be enrolled.

if [[ -d "/etc/jamf-im" ]]; then

    echo "Jamf Infrastructure Manager installation verified. Enrolling with the following Jamf Pro server: $jamfProURL"

    # Enroll Jamf Infrastructure Manager into Jamf Pro

    jamf-im enroll --hostname ${jimHostname} --jss-url ${jamfProURL} --password ${jamfProPassword} --username ${jamfProUsername}

    if [[ $? -ne 0 ]]; then
        echo "Enrollment failed. Please recheck settings and retry enrollment."
        exit 1
    else
        echo "Enrollment succeeded."
    fi

fi