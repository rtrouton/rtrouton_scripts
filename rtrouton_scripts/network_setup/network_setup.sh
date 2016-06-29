#!/bin/sh

SearchDomains="searchdomain1.com searchdomain2.com searchdomain3.com"

# Install DNS servers and DNS search domains

/usr/sbin/networksetup -setdnsservers "Built-in Ethernet" dns.ip1.here dns.ip2.here
/usr/sbin/networksetup -setsearchdomains "Built-in Ethernet" $SearchDomains
/usr/sbin/networksetup -setdnsservers "Ethernet" dns.ip1.here dns.ip2.here
/usr/sbin/networksetup -setsearchdomains "Ethernet" $SearchDomains
/usr/sbin/networksetup -setdnsservers "Ethernet 1" dns.ip1.here dns.ip2.here
/usr/sbin/networksetup -setsearchdomains "Ethernet 1" $SearchDomains
/usr/sbin/networksetup -setdnsservers "Ethernet 2" dns.ip1.here dns.ip2.here
/usr/sbin/networksetup -setsearchdomains "Ethernet 2" $SearchDomains
/usr/sbin/networksetup -setdnsservers "Airport" dns.ip1.here dns.ip2.here
/usr/sbin/networksetup -setsearchdomains "Airport" $SearchDomains


# Remove setup LaunchDaemon item

rm -rf /Library/LaunchDaemons/com.company.networksetup.plist

# Make script self-destruct

rm -rf $0