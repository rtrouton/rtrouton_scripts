#!/bin/bash

# This script uses the Jamf Pro Classic API to detect which
# Self Service policies do not have descriptions and displays
# a list of the relevant policies.

# Set default exit code
exitCode=0

# If you choose to hardcode API information into the script, set one or more of the following values:
#
# The username for an account on the Jamf Pro server with sufficient API privileges
# The password for the account
# The Jamf Pro URL

# Set the Jamf Pro URL here if you want it hardcoded.
jamfpro_url=""	    

# Set the username here if you want it hardcoded.
jamfpro_user=""

# Set the password here if you want it hardcoded.
jamfpro_password=""	

# Read the appropriate values from ~/Library/Preferences/com.github.jamfpro-info.plist
# if the file is available. To create the file, run the following commands:
#
# defaults write $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_url https://jamf.pro.server.here
# defaults write $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_user API_account_username_goes_here
# defaults write $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_password API_account_password_goes_here
#

if [[ -f "$HOME/Library/Preferences/com.github.jamfpro-info.plist" ]]; then

     if [[ -z "$jamfpro_url" ]]; then
          jamfpro_url=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_url)
     fi

     if [[ -z "$jamfpro_user" ]]; then
          jamfpro_user=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_user)
     fi

     if [[ -z "$jamfpro_password" ]]; then
          jamfpro_password=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_password)
     fi

fi

# If the Jamf Pro URL, the account username or the account password aren't available
# otherwise, you will be prompted to enter the requested URL or account credentials.

if [[ -z "$jamfpro_url" ]]; then
     read -p "Please enter your Jamf Pro server URL : " jamfpro_url
fi

if [[ -z "$jamfpro_user" ]]; then
     read -p "Please enter your Jamf Pro user account : " jamfpro_user
fi

if [[ -z "$jamfpro_password" ]]; then
     read -p "Please enter the password for the $jamfpro_user account: " -s jamfpro_password
fi

echo

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

# The following function downloads individual Jamf Pro policy as XML data
# then mines the policy data for the relevant information.

CheckSelfServicePolicyCheckDescriptions(){

	local PolicyId="$1"

	if [[ -n "$PolicyId" ]]; then
		local DownloadedXMLData=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies/id/$PolicyId")
		local PolicyName=$( echo "$DownloadedXMLData" | xmllint --xpath '/policy/general/name/text()' - 2>/dev/null)
		local SelfServicePolicyCheck=$(echo "$DownloadedXMLData" | xmllint --xpath '/policy/self_service/use_for_self_service/text()' - 2>/dev/null)
		local SelfServiceDescription=$(echo "$DownloadedXMLData" | xmllint --xpath '/policy/self_service/self_service_description/text()' - 2>/dev/null)

		# If a policy is detected as being a Self Service policy with an
		# empty description, the policy name is saved to a temp file.

		if [[ "$SelfServicePolicyCheck" = "true" ]] && [[ -z "$SelfServiceDescription" ]]; then
			echo "The following Self Service policy has a blank description: $PolicyName" >> "$PolicyCountFile"
		fi
	fi
}

# Download all Jamf Pro policy ID numbers

PolicyIDList=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies" | xpath "//id" 2>/dev/null)
PolicyIDs=$(echo "$PolicyIDList" | grep -Eo "[0-9]+")
PoliciesCount=$(echo "$PolicyIDs" | grep -c ^)

echo "Checking $PoliciesCount policies for Self Service policies with blank descriptions ..."
echo

# Download latest version of all computer policies using their ID numbers. 
# For performance reasons, we parallelize the execution.
MaximumConcurrentJobs=10
ActiveJobs=0
ProcessedJobs=0

# Create temp file for background processes' output
PolicyCountFile=$(mktemp)
touch "$PolicyCountFile"

for anID in ${PolicyIDs}; do

   # Run API calls in parallel
   ((ActiveJobs=ActiveJobs%MaximumConcurrentJobs)); ((ActiveJobs++==0)) && wait
   CheckSelfServicePolicyCheckDescriptions $anID &
   
    ProcessedJobs=$(( $ProcessedJobs + 1 ))
    PercentComplete=$(echo "(100/${PoliciesCount})*${ProcessedJobs}" | bc -l | awk '{print int($1+0.5)}')
    ProgressDone=$(echo "$PercentComplete/2" | bc -l | awk '{print int($1+0.5)}')
    ProgressLeft=$(( 50 - $ProgressDone ))
    DonePattern=$(printf "%${ProgressDone}s")
    LeftPattern=$(printf "%${ProgressLeft}s")

    printf "\rProcessing: [${DonePattern// /#}${LeftPattern// /-}] ${PercentComplete}%%"
done

PolicyCountNumber=$(grep -c ^ "$PolicyCountFile")
echo
echo
echo "$PolicyCountNumber Self Service policies detected with blank descriptions"
cat "$PolicyCountFile"

echo
echo "Policy check completed."

# Remove temp file

rm "$PolicyCountFile"

exit $exitCode
