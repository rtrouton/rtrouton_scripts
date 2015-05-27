#!/bin/bash
 
# For the SearchDomains variable, change the search domains
# to be the ones you need, separated by spaces. For example,
# if you needed to set verizon.com and comcast.com as DNS
# search domains, SearchDomains would be set like this:
#
# SearchDomains="verizon.com comcast.com"
#
 
SearchDomains="demo.com int.demo.com ext.demo.com other.com"


# Have the Mac scan for and register 
# any new network hardware that has 
# not already registered.

/usr/sbin/networksetup -detectnewhardware

# Save current IFS state

OLDIFS=$IFS

# Change IFS to
# create newline

IFS=$'\n'

# read all Ethernet interface names into an array

ethernet_interface=($(networksetup -listallnetworkservices | awk '/Ethernet/'))

# restore IFS to previous state

IFS=$OLDIFS

# Get length of the array

tLen=${#ethernet_interface[@]}

# Loops through the list of Ethernet network interfaces
# available on this Mac and sets the specified DNS search
# domains on each Ethernet network interface.

for (( i=0; i<${tLen}; i++ ));
  do
     /bin/echo "`date +%Y-%m-%d\ %H:%M:%S`  Setting "${ethernet_interface[$i]}" on this Mac."
     /usr/sbin/networksetup -setsearchdomains "${ethernet_interface[$i]}" $SearchDomains >/dev/null 2>&1

  done

exit 0