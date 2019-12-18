#!/bin/bash

clear

# This script disables all polices in a specified category
# Script is adapted from purgeAllPoliciesInCategory.bash by Jeffrey Compton, https://twitter.com/igeekjsc
# https://github.com/igeekjsc/JSSAPIScripts/blob/master/purgeAllPoliciesInCategory.bash

#Authenticate
read -p "Please enter your JSS URL (e.g. https://myJSS.myCompany.com:8443/)   : " jssURL
echo -e "\nPlease enter the name of the category"
echo "containing all policies you wish to disable."
echo -e "\nBE CAREFUL ABOUT SPECIAL CHARACTERS"
echo -e "\nFor instance, you MUST replace any spaces in your category name with \"%20\""
echo "e.g. a policy named \"My Policy\" should be entered as \"My%20Policy\""
echo -e "\nFor more information about special characters in URLs, see"
echo -e "http://www.w3schools.com/tags/ref_urlencode.asp \n"
read -p "Category Name : " jssCategory
read -p "Please enter your JSS user account : " jssUser
read -p "Please enter your JSS user password : " -s jssPassword

echo ""



#Generate raw xml file
echo "Getting unformatted xml for policies in category $jssCategory ..."
curl -k "$jssURL"JSSResource/policies/category/"$jssCategory" -H "Accept: application/xml" --user "$jssUser:$jssPassword" > /private/tmp/jssPolicyList.xml

if (( $? == 0 ))
	then echo "Download successful. Proceeding..."
	else echo "Unable to communicate with JSS.  Aborting..." ; exit 1
fi

#Clean up the xml file
echo "Formatting xml..."
/usr/bin/xmllint -format /private/tmp/jssPolicyList.xml > /private/tmp/jssPolicyListFormatted.xml
if (( $? == 0 ))
	then echo "Parsing Successful. Proceeding..."
	else echo "Unable to parse.  Most likely, there is a problem with your credentials.  Aborting..." ; exit 1
fi

#See if there are any policies in the category
numberOfPoliciesInCategory=`cat /private/tmp/jssPolicyListFormatted.xml | grep "<size>" | head -1 | awk -F '<size>|</size>' '{print $2}'`

if (( $numberOfPoliciesInCategory == 0 ))
	then
		echo "Did not find any policies at all in category $jssCategory"
		echo "Don't forget to adjust category name to accomodate for spaces and special chars."
		echo "Exiting."
		exit 1
elif (( $numberOfPoliciesInCategory > 0 ))
	then
		echo "Found $numberOfPoliciesInCategory policies in $jssCategory"
		echo "Proceeding..."
else
	echo "An unknown error occurred.  Aborting..."
	exit 1
fi

#List policies to disable before proceeding
echo -e "\nThe following policies are about to be disabled on your JSS:\n"
cat /private/tmp/jssPolicyListFormatted.xml | grep "<name>" | awk -F '<name>|</name>' '{print $2}'
echo -e "\nAre you absolutely certain you want to disable these $numberOfPoliciesInCategory policies ?\n"
read -p "Yes or No (y or n) : " confirmationChoice

case $confirmationChoice in
   Y|y|Yes|YES|yes)
     echo "Proceeding" ;;
   *)
     echo "OK.  Aborting now..." ; exit 1 ;;
esac

#Create plain file of policy ID's
echo "Generating a plain txt file of policy ID's..."
cat /private/tmp/jssPolicyListFormatted.xml | grep "<id>" | awk -F'<id>|</id>' '{print $2}' > /private/tmp/policyList

policyList=$(cat /private/tmp/policyList)

for policy in $policyList
	do
		echo "Disabling policy ID $policy ..."
		curl -H "Content-Type: application/xml" -X PUT -d '<policy><general><enabled>false</enabled></general></policy>' "$jssURL"JSSResource/policies/id/$policy --user "$jssUser:$jssPassword"
	done

