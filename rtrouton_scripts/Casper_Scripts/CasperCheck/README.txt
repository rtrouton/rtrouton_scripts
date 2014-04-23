For folks using JAMF Software's Casper solution, sometimes the Casper agent installed on individual Macs stops working properly. They stop checking in with the Casper server, or check in but can't run policies anymore. To help address this issue, CasperCheck provides an automated way to check and repair Casper agents that are not working properly. As designed, this solution will do the following:

A. Check to see if a Casper-managed Mac's network connection is live
B. If the network is working, check to see if the machine is on a network where the Mac's Casper JSS is accessible.
C. If both of the conditions above are true, check to see if the Casper agent on the machine can contact the JSS and run a policy.
D. If the Casper agent on the machine cannot run a policy, the appropriate functions run and repair the Casper agent on the machine.

As written currently, CasperCheck has several components that work together:

1. A Casper policy that runs when called by a manual trigger.

2. A zipped Casper QuickAdd installer package, available for download from a web server.

3. A LaunchDaemon, which triggers the CasperCheck script to run

4. The CasperCheck script


Here's how the various parts are set up:

Casper policy
-------------

The Casper policy check which is written into the script needs to be set up as follows:

Name: Casper Online
Scope: All Computers
Trigger: Manual triggered by "iscasperup" (no quotes)
Frequency: Ongoing
Plan: Run Script iscasperonline.sh

#!/bin/sh
 
 echo "up"
 
 exit 0

When run, the policy will return "Script result: up" among other output. The CasperCheck script verifies if it's received the "Script result: up" output and will use that as the indicator that policies can be successfully run by the Casper agent.


Zipped QuickAdd installer posted to web server
----------------------------------------------

For the QuickAdd installer, I generated a QuickAdd installer using Casper Recon. This is because QuickAdds made by Recon include an unlimited enrollment invitation, which means that the same package can be used to enroll multiple machines with the JSS in question. Once the QuickAdd package was created by Recon, I then used OS X's built-in compression app to generate a zip archive of the QuickAdd installer. The zipped QuickAdd can be posted to any web server.


LaunchDaemon
------------

As currently written, CasperCheck is set to run on startup and then once every week. To facilitate this, it's using a LaunchDaemon similar to the one below.

The LaunchDaemon will run on the following command on startup. After startup, the script will then run every seven days:

sh /Library/Scripts/HHMI/caspercheck.sh

<?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
 	<key>Label</key>
 	<string>com.company.caspercheck</string>
 	<key>ProgramArguments</key>
 	<array>
 		<string>sh</string>
 		<string>/Library/Scripts/caspercheck.sh</string>
 	</array>
 	<key>RunAtLoad</key>
 	<true/>
 	<key>StartInterval</key>
 	<integer>604800</integer>
 </dict>
 </plist>


CasperCheck script
-------------------

The current version of the CasperCheck script is available from the following location:

https://github.com/rtrouton/rtrouton_scripts/tree/master/rtrouton_scripts/Casper_Scripts/CasperCheck/script


The CasperCheck script includes functions to do the following:

1. Check to verify that the Mac has a network connection that does not use a loopback address (like 127.0.0.1 or 0.0.0.0)

2. Verify that it can resolve the JSS's server address and that the appropriate network port is accepting connections.

3. As needed, download and store new QuickAdd installers from the web server where the zipped QuickAdds are posted to.

4. Check to see if the JAMF binary is present. If not, reinstall using the QuickAdd installer stored on the Mac.

5. If the JAMF binary is present, verify that it has the proper permissions and automatically fix any permissions that are incorrect.

6. Check to see if the Mac can communicate with the JSS server using the "jamf checkJSSConnection" command. If not, reinstall using the QuickAdd installer stored on the Mac.

7. Check to see if the Mac can run a specified policy using a manual trigger. If not, reinstall using the QuickAdd installer stored on the Mac.

Assuming that the Casper Online policy has been set up described above on the JSS, the variables below need to be set up on the CasperCheck script to set the following variables before using it in your environment:

fileURL - For the fileURL variable, put the complete address of the zipped Casper QuickAdd installer package.
jss_server_address - put the complete fully qualified domain name address of your Casper server.
jss_server_port - put the appropriate port number for your Casper server. This is usually 8443 or 443; change as appropriate.
log_location - put the preferred location of the log file for this script. If you don't have a preference, using the default setting of /var/log/caspercheck.log should be fine.
NOTE: Use caution when editing the functions or variables below the User-editable variables section of the script.

CasperCheck in operation
------------------------

There's a number of checks built into the CasperCheck script. Here's how the script works in operation:

1. The script will run a check to see if it has a network address that is not a loopback address (like 127.0.0.1 or 0.0.0.0). If needed, the script will wait up to 60 minutes for a network connection to become available which doesn't use a loopback address.

Note: The network connection check will occur every 5 seconds until the 60 minute limit is reached. If no network connection is found within 60 minutes, the script will exit at that point.

2. Once a network connection is established that passes the initial connection check, the script then pauses for two minutes to allow WiFi connections and DNS to come online and begin working.

3. A check is then run to ensure that the Mac is on the correct network by verifying that it can resolve the fully qualified domain name of the Casper server. If the verification check fails, the script will exit at that point.

4. Once the "correct network" check is passed, a check is then run to verify that the JSS's Tomcat service is responding via its port number.

5. Once the Tomcat service check is passed, a check is then run to verify that the latest available QuickAdd installer has been downloaded to the Mac. If not, a new QuickAdd installer is downloaded as a .zip file from the web server which hosts the zipped QuickAdd.

Once downloaded, the zip file is then checked to see if it is a valid zip archive. If the zip file check fails, the script will exit at that point.

If all of the above checks described above are passed, the CasperCheck script has verified the following:

A. It's got a network connection
B. It can actually see the Casper server
C. The Tomcat web service used by the JSS for communication between the server and the Casper agent on the Mac is up and running.
D. The current version of the QuickAdd installer is stored on the Mac

At this point, the script will proceed with verifying whether the Casper agent on the Mac is working properly.

5. A check is run to ensure that the JAMF binary used by the Casper agent is present. If not, the CasperCheck script will reinstall the Casper agent using the QuickAdd installer stored on the Mac.

6. If the JAMF binary is present, the CasperCheck script runs commands to verify that it has the proper permissions and automatically fix any permissions that are incorrect.

7. A check is run using the "jamf checkJSSConnection" command to make sure that the Casper agent can communicate with the JSS service. This check should usually succeed, but may fail in the following circumstances:

A. The Casper agent on the machine was originally talking to the JSS at a different DNS address - In the event that the Casper server has moved to a different DNS address from the one that the Casper agent is expecting, this check will fail.
B. The Casper agent is present but so broken that it cannot contact the JSS service using the checkJSSConnection function.

If the check fails, the CasperCheck script will reinstall the Casper agent using the QuickAdd installer stored on the Mac.

8. The final check verifies if the Mac can run the specified policy. If the check fails, the CasperCheck script will reinstall the Casper agent using the QuickAdd installer stored on the Mac.


For more details, visit the post linked below:

http://derflounder.wordpress.com/2014/04/23/caspercheck-an-auto-repair-process-for-casper-agents/

