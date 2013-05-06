#!/bin/bash

# At the prompt, enter the IP address
# or DNS name of the machine you want
# to connect to.

echo -n "Enter IP Address or Domain Name: "
read ipaddress

# At the prompt, enter the username
# of the account you want to log in
# with.

echo -n "Enter Username: "
read username

# At the prompt, enter the command that
# you want to run on the remote machine.

echo -n "Enter the command you want to run on the remote machine: "
read command

echo ""
echo ""

# Error checking to verify that the correct
# information has been entered. If incorrect
# info has been entered, selecting No will
# exit the script.

echo "Is the information below correct?"
echo ""
echo "Remote machine: $ipaddress"
echo "Username: $username"
echo "Command: $command"
echo ""
echo "If it is correct, select Yes"
echo ""
select yn in "Yes" "No"; do
    	case $yn in
        	Yes) echo "OK, the script will continue."; break;;
        	No ) echo "To avoid errors, the script will need to be restarted. Exiting the script."; exit 0;;
    	esac
done
echo ""
echo ""

# Check to see if the command needs to be
# run with root privileges. If root privileges
# are needed, the SSH connection will force 
# pseudo-tty allocation, which allows the command
# to be run via sudo

echo "Does this command need to run with root privileges? Once you select Yes or No, the command will run on the remote machine."
echo "Note: You will be prompted if authentication is required. If running the command as root, you may be prompted twice."
echo ""
select yn in "Yes" "No"; do
    	case $yn in
        	Yes) echo ""; ssh -t $username@$ipaddress "sudo $command"; break;;
        	No ) echo ""; ssh $username@$ipaddress "$command"; break;;
    	esac
done

#Exiting the script
echo ""
echo ""
echo "Finished running the remote command"
exit 0
