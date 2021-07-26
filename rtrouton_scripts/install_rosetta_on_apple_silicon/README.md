This script will download and install Rosetta 2 for Apple Silicon Macs.

How the script works:

1. Checks to see if the following conditions have been met:
	* OS version is macOS 11 or later.
	* If the Mac does not have an Intel processor
	* If the `oahd` process for Rosetta is not running.
3. 	If the conditions are met, the script does the following:
 	* Performs a non-interactive install of Rosetta 2 using the `softwareupdate` tool.
 	* Reports on if the installation was successful or not. 