#!/bin/sh

# This script stops and starts the NTP service
# on a Mac running 10.5.x and higher. The stop
# and start forces a check-in with the network
# time server that the Mac is using, so this 
# helps prevent the Mac's clock from drifting
# ahead or behind the actual time.

/bin/launchctl stop org.ntp.ntpd
/bin/launchctl start org.ntp.ntpd

exit 0