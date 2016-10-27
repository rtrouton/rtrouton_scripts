#!/bin/bash

if [[ -e "/Library/Application Support/Dell/KACE/bin/AMPTools" ]]; then

   # Uninstalls KBox 6.x and later agents
   
   "/Library/Application Support/Dell/KACE/bin/AMPTools" uninstall
   
   if [[ -e "/Library/Application Support/Dell" ]]; then
	  /bin/rm -rf "/Library/Application Support/Dell"
   fi  
   
elif [[ ! -e "/Library/Application Support/Dell/KACE/bin/AMPTools" ]]; then

   # Removes the 5.3 - 6.x KBox agents

   "/Library/StartupItems/AMPAgentBootup/AMPAgentBootup" stop
   "/Library/Application Support/Dell/KACE/bin/AMPctl" stop 2>&1
   "/Library/Application Support/Dell/KACE/bin/kagentctl" stop 2>&1
   /bin/rm -rf "/Library/Application Support/Dell"
   /bin/rm -rf /Library/StartupItems/AMPAgentBootup
   /bin/rm -rf /Library/Receipts/AMPAgent.pkg
   /bin/rm -rf /var/db/receipts/com.kace.ampagent.bom
   /bin/rm -rf /var/db/receipts/com.kace.ampagent.plist
   /bin/rm -rf /Library/LaunchAgents/com.kace.AdminAlert.plist
   /bin/rm -rf /Library/LaunchDaemons/com.kace.ampagent.plist

   # Removes the 5.1 KBox agent

   /Library/StartupItems/KBOXAgent/KBOXAgent stop
   /Library/KBOXAgent/Home/bin/kagentctl stop 2>&1
   /Library/KBOXAgent/Home/bin/SMMPctl stop 2>&1
   /bin/rm -rf /Library/KBOXAgent
   /bin/rm -rf /Library/StartupItems/KBOXAgent
   /bin/rm -rf "/Library/Receipts/KBOX Agent.pkg"
   /bin/rm -rf /var/kace
   /bin/rm -rf /var/db/receipts/com.kace.kboxagent.bom
   /bin/rm -rf /var/db/receipts/com.kace.kboxagent.plist
   /bin/rm -rf /Library/LaunchDaemons/kace.smmpagent.bootup.plist
fi

exit 0