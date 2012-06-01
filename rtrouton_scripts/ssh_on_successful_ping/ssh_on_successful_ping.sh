#! /bin/bash

# At the prompt, enter the IP address
# or DNS name of the machine you want
# to connect to.

read -p "Enter IP Address or Domain Name: " ipaddress

# At the prompt, enter the username
# of the account you want to log in
# with.

read -p "Enter Username: " sshusername
echo ""

echo "Connecting to $ipaddress using the $sshusername account."
echo ""

# The machine will be pinged
# once per minute to check 
# for a response. The until
# loop statement ends only
# when the ping returns a
# successful response.

until ping -c 1 $ipaddress
do
        sleep 60;
done

# Once ping returns successfully,
# an SSH connection is attempted
# using the username and IP address
# or DNS name provided earlier.

ssh $sshusername@$ipaddress
