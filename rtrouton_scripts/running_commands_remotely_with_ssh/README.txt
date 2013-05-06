This script allows remote commands to be run via SSH. The script will ask for the following variables:

IP address or DNS name
Username
Command being run

The script will then verify that the correct information has been entered, then ask if the command needs to be run with root privileges. Once the remote command has run, the SSH connection will close and the script will exit.