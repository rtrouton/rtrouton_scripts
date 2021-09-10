#!/bin/bash

# This Jamf Pro Extension Attribute is designed to calculate and set a 
# numerical identifier for individual Macs based on the Mac's machine UUID.
# This numerical identifier in turn is designed to be used to determine deployment
# groups.
#
# By default, this script is designed to set up and assign Macs to seven
# deployment groups, with the following percentage of Macs assigned to
# each group.
#
# Group		% of Macs		
# -------------------------
# 1			1
# 2			5
# 3			10
# 4			20
# 5			20
# 6			20
# 7			24
#


# Put in the name of your company, school, or institution.
# Must all be one word without spaces
#
# Examples:
#
# MyGreatCompany
# TheNewSchool
# BankofGreaterNewtown
# MikesSurfShop

organizationName="companyname"

# Do not edit variables below this line

deploymentGroupFile="/Library/Preferences/com.${organizationName}.deploymentgroup.plist"
exitCode=0


log() {
	local errorMsg="$1"
	echo "$errorMsg"
	/usr/bin/logger "$errorMsg"
}

deploymentGroupAssignment() {	
	
	deploymentGroup=7
	
	# Get the machine's uuid
	machineUUID=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | /usr/bin/awk '/IOPlatformUUID/ { gsub(/"/,"",$3); print $3; }')
	
	# If the UUID is available, generate a hash of the UUID
	# then use that hash to assign an index number.
	
	if [[ -n "$machineUUID" ]]; then
	
		uuidHash=$(echo "$machineUUID" | /usr/bin/shasum -a 512 | /usr/bin/sed 's/[^0-9]*//g')
		indexNumber=$(echo "${uuidHash:0:12}" | /usr/bin/awk '{ print $1 % 100 }')
	
		if [[ -n "$indexNumber" ]]; then
		
		# Once the index number is assigned, match the index number
		# to a deployment group's numerical identifier.
	
			case "$indexNumber" in
				1) deploymentGroup=1
					;;
				2|3|4|5|6) deploymentGroup=2
					;;
				7|8|9|10|11|12|13|14|15|16) deploymentGroup=3
					;;
				17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36) deploymentGroup=4
					;;
				37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56) deploymentGroup=5
					;;
				57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76) deploymentGroup=6
					;;
				*) deploymentGroup=7
					;;
			esac
		fi
	
	else
		log "ERROR! Unable to get machine's machine UUID"
		exitCode=1
	fi
}

reportExtensionAttributeValue() {
	deploymentGroupAssignmentCheck=$(/usr/bin/defaults read ${deploymentGroupFile} deploymentGroupAssignmentValue)

    # The extension attribute should have a numeric value greater than zero.
    # If the value is blank or a non-number, the following value is reported:
    #
    # 0
    # 
    # The 0 value indicates that there was a problem determining the deployment group.

	if [[ "$deploymentGroupAssignmentCheck" =~ ^[0-9]+$ ]]; then
	    echo "<result>$deploymentGroupAssignmentCheck</result>"
	else
	    echo "<result>0</result>"
	fi
}

# Check to see if there's an existing plist file in /Library/Preferences which has the
# deployment group's numerical identifier assigned as an integer value to the plist file's
# deploymentGroupAssignmentValue key.
#
# If there is not a plist file, or there is not a deploymentGroupAssignmentValue key with a numerical
# value inside the plist file, the extension attribute generates the deployment group's numerical identifier.
# Once the deployment group's numerical identifier is generated, the identifier is stored as an integer value
# to the plist file's deploymentGroupAssignmentValue key.

if [[ -r ${deploymentGroupFile} ]]; then
   reportExtensionAttributeValue 
else
    /usr/bin/defaults delete ${deploymentGroupFile}
    deploymentGroupAssignment
    /usr/bin/defaults write ${deploymentGroupFile} deploymentGroupAssignmentValue -int "$deploymentGroup"
    reportExtensionAttributeValue
fi

exit $exitCode