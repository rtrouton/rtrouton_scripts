#!/bin/zsh --no-rcs
#
# This script connects to the Jamf Pro API on a Jamf Pro server and creates a new Jamf Pro API Role
# which is then granted every available API privilege.
#
# The reason for this script is that Jamf Pro enforces a privilege-escalation guard: an API Client
# cannot be used to create a role that grants privileges the client does not already hold itself. 
# If you're trying to set up an API Role which is assigned all API Role privileges, this usually 
# means having to manually create the API Role and then manually assign all API Role privileges.
#
# This script sidesteps that problem by using an Jamf Pro user account which has been assigned
# the Administrator privileges set. The same privilege-holding rule still applies, but a Jamf Pro
# user account with the Administrator privileges set assigned to it has been granted all available 
# API role privileges. This enables an Jamf Pro account to be set up, assigned the Administrator 
# permission set and subsequently be able to grant all available API Role privileges.
#
# Pre-requisites:
#  
# * Jamf Pro user account with the Administrator privileges set assigned to it
# * jq command line tool
#
# Usage:
# /path/to/create_jamf_pro_api_role_with_all_available_privileges.sh

# If you choose to hardcode account information into the script, set one or
# more of the following values:
#
# The Jamf Pro URL
# The username for a Jamf Pro user account with the Administrator privileges set assigned to it
# The password for that account

# Set the Jamf Pro URL here if you want it hardcoded.
jamfpro_url=""

# Set the Jamf Pro user account's username here if you want it hardcoded.
jamfpro_user=""

# Set the Jamf Pro user account's password here if you want it hardcoded.
jamfpro_password=""

# If you do not want to hardcode account information into the script, you
# can also store these values in a
# ~/Library/Preferences/com.github.jamfpro-info.plist file.
#
# To store the Jamf Pro URL in the plist file:
# defaults write com.github.jamfpro-info jamfpro_url https://jamf.pro.server.goes.here:port_number_goes_here
#
# To store the account username in the plist file:
# defaults write com.github.jamfpro-info jamfpro_user account_username_goes_here
#
# To store the account password in the plist file:
# defaults write com.github.jamfpro-info jamfpro_password account_password_goes_here
#
# If the com.github.jamfpro-info.plist file is available, the script will
# read in the relevant information from the plist file.

jamfpro_plist="$HOME/Library/Preferences/com.github.jamfpro-info.plist"

if [[ -r "$jamfpro_plist" ]]; then
    if [[ -z "$jamfpro_url" ]]; then
        jamfpro_url=$(defaults read "${jamfpro_plist%.*}" jamfpro_url 2>/dev/null)
    fi
    if [[ -z "$jamfpro_user" ]]; then
        jamfpro_user=$(defaults read "${jamfpro_plist%.*}" jamfpro_user 2>/dev/null)
    fi
    if [[ -z "$jamfpro_password" ]]; then
        jamfpro_password=$(defaults read "${jamfpro_plist%.*}" jamfpro_password 2>/dev/null)
    fi
fi

# If the Jamf Pro URL, the account username or the account password aren't
# available otherwise, you will be prompted to enter the requested URL or
# account credentials.

if [[ -z "$jamfpro_url" ]]; then
    read "?Please enter your Jamf Pro server URL : " jamfpro_url
fi

if [[ -z "$jamfpro_user" ]]; then
    read "?Please enter your Jamf Pro user account : " jamfpro_user
fi

if [[ -z "$jamfpro_password" ]]; then
    read -s "?Please enter the password for the $jamfpro_user account: " jamfpro_password
fi
echo ""

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

# This function enables an error message to be printed and stops the script
# with an exit code of 1.

stop_on_error() {
    print -u2 -- "ERROR: $1"
    exit 1
}

# This function splits a "body\nHTTP_CODE" string (as produced by curl -w '\n%{http_code}')
# into two global variables: REPLY_BODY and REPLY_CODE

split_curl_response() {
    local combined="$1"
    REPLY_CODE="${combined##*$'\n'}"
    REPLY_BODY="${combined%$'\n'*}"
}

# This function uses Basic Authentication to get a new bearer token for API
# authentication, using the Jamf Pro user account's username and password.

GetJamfProAPIToken() {
    api_token=$(/usr/bin/curl -X POST --silent -u "${jamfpro_user}:${jamfpro_password}" "${jamfpro_url}/api/v1/auth/token" | plutil -extract token raw -)
}

# This function checks whether the current bearer token is still valid by calling an
# endpoint that requires a valid token, capturing only the resulting HTTP status code.

APITokenValidCheck() {
    api_authentication_check=$(/usr/bin/curl --write-out %{http_code} --silent --output /dev/null "${jamfpro_url}/api/v1/auth" --request GET --header "Authorization: Bearer ${api_token}")
}

# This function renews the current bearer token if it's still valid, or
# requests a brand new one via Basic Authentication if it has expired.

CheckAndRenewAPIToken() {
    APITokenValidCheck
    if [[ "$api_authentication_check" == "200" ]]; then
        api_token=$(/usr/bin/curl "${jamfpro_url}/api/v1/auth/keep-alive" --silent --request POST --header "Authorization: Bearer ${api_token}" | plutil -extract token raw -)
    else
        GetJamfProAPIToken
    fi
}

# This function invalidates the current bearer token so it can't be reused
# after this script exits.

InvalidateToken() {
    APITokenValidCheck
    if [[ "$api_authentication_check" == "200" ]]; then
        /usr/bin/curl "${jamfpro_url}/api/v1/auth/invalidate-token" --silent --output /dev/null --header "Authorization: Bearer ${api_token}" -X POST
        api_token=""
    fi
}

# The jq command line tool is required in this script but is only installed by default on macOS Sequoia and later.
# If jq is not installed, the script stops and displays an error.

command -v jq >/dev/null 2>&1 || stop_on_error "jq command line tool is not installed. It is installed by default on macOS Sequoia and later. If you are using an earlier version of macOS, it is available from https://jqlang.org/download/ ."

# Get initial API token

GetJamfProAPIToken

# Use the API to get the full list of permissions which can be assigned to an API role.

print "Retrieving the list of available API Role privileges ..."

CheckAndRenewAPIToken

priv_response=$(curl -s -w $'\n%{http_code}' --request GET "${jamfpro_url}/api/v1/api-role-privileges" --header "Authorization: Bearer ${api_token}" --header "Accept: application/json")

split_curl_response "$priv_response"

# If not able to retrieve the list of available API Role privileges, the script stops and displays an error.

if [[ "$REPLY_CODE" != "200" ]]; then
    stop_on_error "Failed to retrieve API Role privileges. Please try again using a Jamf Pro account which has been assigned the Administrator privileges set. Response from Jamf Pro server: ${REPLY_BODY}"
fi

# Extract the "privileges" array.

typeset -a all_privileges
all_privileges=("${(@f)$(print -r -- "$REPLY_BODY" | jq -r '.privileges[]' 2>/dev/null)}")

(( ${#all_privileges[@]} == 0 )) && stop_on_error "No privileges were returned by the Jamf Pro API."

print "Found ${#all_privileges[@]} total API Role privileges on this server."

# Verify the Jamf Pro account being used is assigned all API role privileges.

print "Verifying the '${jamfpro_user}' account holds every privilege in the catalog ..."

CheckAndRenewAPIToken

auth_response=$(curl -s -w $'\n%{http_code}' --request GET "${jamfpro_url}/api/v1/auth" --header "Authorization: Bearer ${api_token}" --header "Accept: application/json")

split_curl_response "$auth_response"

if [[ "$REPLY_CODE" != "200" ]]; then
    stop_on_error "Failed to read the account's authorization details. Response: ${REPLY_BODY}"
fi

typeset -a account_strings
account_strings=("${(@f)$(print -r -- "$REPLY_BODY" | jq -r '[.. | strings] | .[]' 2>/dev/null)}")

typeset -A account_strings_set
for s in "${account_strings[@]}"; do
    account_strings_set[$s]=1
done

typeset -a missing_privileges
for p in "${all_privileges[@]}"; do
    [[ -z "${account_strings_set[$p]}" ]] && missing_privileges+=("$p")
done

if (( ${#missing_privileges[@]} > 0 )); then
    stop_on_error "The account '${jamfpro_user}' is missing ${#missing_privileges[@]} of the ${#all_privileges[@]} privileges in the API Role catalog which means the Administrator privileges set is not assigned to the account. Please try again using a Jamf Pro account which has been assigned the Administrator privileges set."
fi

print "Account holds every privilege in the catalog. Proceeding ..."

# Prompt for the name of the new API role being created with all API role privileges.

while true; do
    read "?Name for the new all-privileges API Role: " new_role_name
    [[ -n "$new_role_name" ]] && break
    print "The API Role name cannot be blank."
done

# Create a JSON block which contains a properly formatted list of all API role privileges.

request_body=$(jq -n --arg name "$new_role_name" --args '{displayName: $name, privileges: $ARGS.positional}' "${all_privileges[@]}")

print "Creating API Role '${new_role_name}' with all ${#all_privileges[@]} privileges ..."

CheckAndRenewAPIToken

# Create the new API role and assign it all API role privileges.

create_response=$(curl -s -w $'\n%{http_code}' --request POST "${jamfpro_url}/api/v1/api-roles" --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json" --header "Accept: application/json" --data "$request_body")

split_curl_response "$create_response"

# Check to see if the API call to create the new role was successful. The success response from Jamf Pro should be HTTP 200 or HTTP 201. 
#
# HTTP 200 is the documented success response for this endpoint.
# HTTP 201 is the conventional HTTP status for a successful resource-creation request.

if [[ "$REPLY_CODE" != "200" && "$REPLY_CODE" != "201" ]]; then
    stop_on_error "Failed to create the '${new_role_name}' API Role. Response: ${REPLY_BODY}"
fi

new_role_id=$(print -r -- "$REPLY_BODY" | jq -r '.id // empty' 2>/dev/null)
new_role_display_name=$(print -r -- "$REPLY_BODY" | jq -r '.displayName // empty' 2>/dev/null)

# Invalidate the current bearer token to make sure it can't be used again.

InvalidateToken

# Display report of successful API Role creation.

print ""
print "API Role created successfully:"
print "  ID:              ${new_role_id}"
print "  Display Name:    ${new_role_display_name}"
print "  Privileges:      ${#all_privileges[@]} (every privilege in the API Role catalog)"
print ""