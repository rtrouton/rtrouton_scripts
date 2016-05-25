This script is designed to force-unbind a Mac running 10.5.x or higher from an Active Directory domain. The username and password in the script are not designed to be actual accounts, but they are needed to allow dsconfigad to perform a forced unbind. 

When forcing an unbind, dsconfigad will check to see if a username and password are specified in the command. It does not appear to check with the Active Directory domain to see if the account actually exists.

The script includes a check to see if the Mac was bound using a DeployStudio-generated Active Directory configuration profile and remove the profile if one is found.

This script must be run with root privileges. It is also available as a payload-free package. 
