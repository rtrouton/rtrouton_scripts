Sets a Mac's computer name to the machine's hardware serial number. 

* If the Jamf agent is installed, the script uses the Jamf agent to set the computer name to the machine's hardware serial number.
* If the Jamf agent is not installed, the `scutil` command line tool is used.