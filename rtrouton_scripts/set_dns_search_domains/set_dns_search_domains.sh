#!/bin/bash
 
# For the SearchDomains variable, change the search domains
# to be the ones you need, separated by spaces. For example,
# if you needed to set verizon.com and comcast.com as DNS
# search domains, SearchDomains would be set like this:
#
# SearchDomains="verizon.com comcast.com"
#

if [[ ${4} == "" ]]; then
    SearchDomains="demo.com int.demo.com ext.demo.com other.com"
else
    SearchDomains="${4} ${5} ${6} ${7} ${8} ${9}"
fi
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

interfaces=($(networksetup -listallnetworkservices | awk '/Ethernet/ || /Wi-Fi/'))

# restore IFS to previous state

IFS=$OLDIFS

# Get length of the array

tLen=${#interfaces[@]}

# Loops through the list of Ethernet network interfaces
# available on this Mac and sets the specified DNS search
# domains on each Ethernet network interface.

for (( i=0; i<${tLen}; i++ ));
  do
     /bin/echo "`date +%Y-%m-%d\ %H:%M:%S`  Setting "${interfaces[$i]}" on this Mac to '${SearchDomains}'."
     /usr/sbin/networksetup -setsearchdomains "${interfaces[$i]}" ${SearchDomains} >/dev/null 2>&1

  done

exit 0
