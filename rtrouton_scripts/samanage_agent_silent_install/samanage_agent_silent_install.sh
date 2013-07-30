#!/bin/sh

# Uninstall current SAManage agent

/Applications/Samanage\ Agent.app/Contents/Resources/uninstaller.sh


# Change working directory to /tmp

/usr/bin/cd /tmp

# Download SAManage Mac agent software

/usr/bin/curl -O http://cdn.samanage.com/download/Mac+Agent/SAManage-Agent-for-Mac.dmg

# Mount the SAManage-Agent-for-Mac.dmg disk image in /Volumes

/usr/bin/hdiutil attach SAManage-Agent-for-Mac.dmg -nobrowse -noverify -noautoopen

# Use echo to create a /tmp/samanage file and add the account name to it

################################################################################ 
# 
# Replace <ACCT_NAME> with your SAManage account name below 
# 
echo "<ACCT_NAME>" > /tmp/samanage 
# 
################################################################################

# Install the SAManage Mac agent

/usr/sbin/installer -dumplog -verbose -pkg /Volumes/Samanage-Mac-Agent-*/Samanage-Mac-Agent-*.pkg -target "/"


# Clean-up
 
# Unmount the SAManage-Agent-for-Mac.dmg disk image from /Volumes

/usr/bin/hdiutil eject -force /Volumes/Samanage-Mac-Agent-*

# Remove /tmp/samanage

/bin/rm /tmp/samanage

# Remove the SAManage-Agent-for-Mac.dmg disk image from /tmp

/bin/rm -rf /tmp/SAManage-Agent-for-Mac.dmg

