#!/bin/sh
#AGENTX Script to correct Crashplan Java paths to Apple Java 1.6 after Java 1.7 upgrade as not compatible
#v1 22/10/2012

#Unload Crashplan
launchctl unload /Library/LaunchDaemons/com.crashplan.engine.plist

#change the java path in plist, pretty sure it is ProgramArguments 0 on all my systems ;-)
/usr/libexec/PlistBuddy -c "Set  :ProgramArguments:0  /System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Commands/java" /Library/LaunchDaemons/com.crashplan.engine.plist

#Reload Crashplan
launchctl load /Library/LaunchDaemons/com.crashplan.engine.plist
exit

