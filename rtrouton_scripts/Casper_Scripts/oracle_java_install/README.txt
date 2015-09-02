This script checks the OS of the machine running it and triggers the
following policies based on the reported version of OS X.

For Macs running 10.7.x - 10.10.x:

Trigger the policy which installs the Oracle Java JRE. These Macs will
have Apple's Java 6 installed and will only need the Oracle Java browser
plug-in

For Macs running 10.11.x and later:

Trigger the policy which installs the Oracle Java JDK. These Macs will
not have Apple's Java 6 installed and will need both the Oracle Java
browser plug-in and Oracle's system-level Java installed.