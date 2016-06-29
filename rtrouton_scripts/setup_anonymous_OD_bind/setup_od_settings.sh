#!/bin/sh

####################################################################
# Delay the login window to give the new DS settings time to apply #
####################################################################

defaults write /Library/Preferences/com.apple.loginwindow StartupDelay -int 120

#######################################
## Wait for network services to be up #
#######################################

sleep 60

#################################################
##  	Remove old OD settings   	       ##
#################################################

rm -rf /Library/Preferences/DirectoryService
killall DirectoryService

#################################################
##  Add the OD settings for OD Server Name     ##
#################################################

dsconfigldap -v -s -a od.server.name 
dscl -q localhost -create /Search SearchPolicy dsAttrTypeStandard:CSPSearchPath
dscl -q localhost -merge /Search CSPSearchPath /LDAPv3/od.server.name
killall DirectoryService

################################ 
# Remove the loginwindow delay #
################################

defaults delete /Library/Preferences/com.apple.loginwindow StartupDelay


# Remove setup LaunchDaemon item

rm -rf /Library/LaunchDaemons/com.company.setup_od_settings.plist 

# Make script self-destruct

rm -rf $0
