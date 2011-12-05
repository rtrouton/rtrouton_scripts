#!/bin/sh

# Gets the name of the logged-in user
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

# Checks the UID of the logged-in user 
accountType=`dscl . -read /Users/$loggedInUser | grep UniqueID | cut -c 11-`

# If the UID is greater than 1000, the logged-in user
# is using a account provided by a directory service
# like Active Directory. If the user account is being
# hosted by a directory service, the directory service
# is polled for the user's information

if (( "$accountType" > 1000 )); then
	userFirstname=`dscl . -read /Users/$loggedInUser | grep FirstName: | cut -c 11-`
	userLastname=`dscl . -read /Users/$loggedInUser | grep LastName: | cut -c 11-`
	userEmail=`dscl . -read  /Users/$loggedInUser | grep EMailAddress: | cut -c 15-`
	userPosition=`dscl . -read /Users/$loggedInUser | awk '/^JobTitle:/,/^JPEGPhoto:/' | head -2 | tail -1  | cut -c 2-`
	userPhone=`dscl . -read /Users/$loggedInUser | grep PhoneNumber: | cut -c 14-`
	userDepartment=`dscl . -read /Users/$loggedInUser | grep "Department:" | cut -c 12-`
        	if [[ -z $userDepartment ]]; then
                	userDepartment=`dscl . -read /Users/$loggedInUser | awk '/^Department:/,/^EMailAddress:/' | head -2 | tail -1  | cut -c 2-`
        	fi
	userRoom=`dscl . -read /Users/$loggedInUser | grep Building: | cut -c 11-`
	echo "Submitting information for network account $loggedInUser..."
	jamf recon -endUsername "$loggedInUser" -realname "$userFirstname $userLastname" -email "$userEmail" -position "$userPosition" -phone "$userPhone" -department "$userDepartment" -room "$userRoom"

# If the UID is less than 1000, the logged-in user
# is using a local account. Since no additional
# information is likely to be available, the only
# information reported to the JSS is the username
# and that it is a local account.

else
	echo "Submitting information for local account $loggedInUser..."
	userPosition="Local Account"
	jamf recon -endUsername "$loggedInUser" -position "$userPosition"
fi
