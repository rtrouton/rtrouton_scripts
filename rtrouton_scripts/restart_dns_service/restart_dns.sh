#!/bin/sh

# Using the serveradmin tool
# to stop the DNS service on
# Mac OS X Server

/usr/sbin/serveradmin stop dns

# Script will then wait five seconds

sleep 5

# Using the serveradmin tool
# to restart the DNS service on
# Mac OS X Server

/usr/sbin/serveradmin start dns
