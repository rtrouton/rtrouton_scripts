This script is used to run all Jamf Pro policies in a specified policy category. It does the following:

1. Runs the following command to get the policy IDs:
`/usr/bin/curl -ksf -u api_username_goes_here:api_password_goes_here -H "Accept: application/xml" https://server.name.here/JSSResource/policies/category/Policy_Category_Goes_Here | xpath "policies/policy/id" | sed 's/\<id>//g' | tr '</id>' '\n' | sed '/^s*$/d'`

2. Adds all of the specified policy IDs into a bash array.

3. Runs each policy in the order they were added to the bash array, which will be the same order provided by the API.

It uses the following Jamf Pro parameters to pass information to the script:

* `$4` - API username
* `$5` - API password
* `$6` - Jamf Pro policy category