#!/bin/sh
 
# Removes the 5.3 KBox agent

sudo /Library/StartupItems/AMPAgentBootup/AMPAgentBootup stop
sudo /Library/Application Support/Dell/KACE/bin/AMPctl stop 2>&1
sudo /Library/Application Support/Dell/KACE/bin/kagentctl stop 2>&1
sudo rm -rf /Library/Application\ Support/Dell
sudo rm -rf /Library/StartupItems/AMPAgentBootup
sudo rm -rf /Library/Receipts/AMPAgent.pkg
sudo rm -rf /var/db/receipts/com.kace.ampagent.bom
sudo rm -rf /var/db/receipts/com.kace.ampagent.plist
sudo rm -rf /Library/LaunchAgents/com.kace.AdminAlert.plist
sudo rm -rf /Library/LaunchDaemons/com.kace.ampagent.plist

# Removes the 5.1 KBox agent

sudo /Library/StartupItems/KBOXAgent/KBOXAgent stop
sudo /Library/KBOXAgent/Home/bin/kagentctl stop 2>&1
sudo /Library/KBOXAgent/Home/bin/SMMPctl stop 2>&1
sudo rm -rf /Library/KBOXAgent
sudo rm -rf /Library/StartupItems/KBOXAgent
sudo rm -rf /Library/Receipts/KBOX\ Agent.pkg
sudo rm -rf /var/kace
sudo rm -rf /var/db/receipts/com.kace.kboxagent.bom
sudo rm -rf /var/db/receipts/com.kace.kboxagent.plist
sudo rm -rf /Library/LaunchDaemons/kace.smmpagent.bootup.plist