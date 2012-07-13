#!/bin/sh

#Primary Time server for Company Macs
                                                                  
TimeServer1=timeserver1.company.com

#Secondary Time server for Company Macs

TimeServer2=timeserver2.company.com

#Tertiary Time Server for Company Macs, used outside of Company network

TimeServer3=time.apple.com

# Time zone for Company Macs

TimeZone=America/New_York

# Configure network time server and region

# Set the time zone
/usr/sbin/systemsetup -settimezone $TimeZone

# Set the primary network server with systemsetup -setnetworktimeserver
# Using this command will clear /etc/ntp.conf of existing entries and
# add the primary time server as the first line.

/usr/sbin/systemsetup -setnetworktimeserver $TimeServer1

# Add the secondary time server as the second line in /etc/ntp.conf
echo "server $TimeServer2" >> /etc/ntp.conf

# Add the tertiary time server as the third line in /etc/ntp.conf
echo "server $TimeServer3" >> /etc/ntp.conf

# Enables the Mac to set its clock using the network time server(s)
/usr/sbin/systemsetup -setusingnetworktime on
