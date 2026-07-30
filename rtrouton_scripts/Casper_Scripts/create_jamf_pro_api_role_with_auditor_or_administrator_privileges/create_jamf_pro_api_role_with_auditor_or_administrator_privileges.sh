#!/bin/zsh --no-rcs
#
# This script creates a new Jamf Pro API Role and populates its privileges to approximate
# either the "Administrator" or "Auditor" account privilege sets available for Jamf Pro
# user accounts. Jamf Pro API Roles do not have comparable privilege sets and require each
# API privilege to be individually assigned to an API role. 
# 
# This script approximates the two privilege sets as follows:
#
# * Administrator: every privilege in the API Role privilege catalog.
# * Auditor: every privilege whose name starts with "Read" in the API Role privilege catalog.
#                     
# IMPORTANT NOTE: 
#
# Jamf Pro will reject the role-creation request with HTTP 403 / INVALID_PRIVILEGE unless
# the API Client running this script ALSO already holds every privilege it is trying to assign
# to the new role. This is a privilege-escalation guard: an API Client can't be used to grant
# a role more access than the API Client itself already has. 
#
# In practice, this means the API Client used to run this script needs an existing API Role that 
# already carries every privilege in whichever set (either all privileges, or all "Read" privileges)
# that you plan to create with it.
#
# Pre-requisites:
#
# * Jamf Pro API Client with sufficient privileges set assigned to it
# * jq command line tool
#
# Usage:
# /path/to/create_jamf_pro_api_role_with_auditor_or_administrator_privileges.sh

# If you choose to hardcode API information into the script, set one or more
# of the following values:
#
# The Jamf Pro URL
# An API client ID on the Jamf Pro server with sufficient API privileges
# The API client secret for the API client ID

# Set the Jamf Pro URL here if you want it hardcoded.
jamfpro_url=""

# Set the Jamf Pro API Client ID here if you want it hardcoded.
jamfpro_api_client_id=""

# Set the Jamf Pro API Client Secret here if you want it hardcoded.
jamfpro_api_client_secret=""

# If you do not want to hardcode API information into the script, you can
# also store these values in a ~/Library/Preferences/com.github.jamfpro-info.plist
# file.
#
# To store the Jamf Pro URL in the plist file:
# defaults write com.github.jamfpro-info jamfpro_url https://jamf.pro.server.goes.here:port_number_goes_here
#
# To store the Jamf Pro API Client ID in the plist file:
# defaults write com.github.jamfpro-info jamfpro_api_client_id api_client_id_information_goes_here
#
# To store the Jamf Pro API Client Secret in the plist file:
# defaults write com.github.jamfpro-info jamfpro_api_client_secret api_client_secret_information_goes_here
#
# If the com.github.jamfpro-info.plist file is available, the script will
# read in the relevant information from the plist file.

jamfpro_plist="$HOME/Library/Preferences/com.github.jamfpro-info.plist"

if [[ -r "$jamfpro_plist" ]]; then
    if [[ -z "$jamfpro_url" ]]; then
        jamfpro_url=$(defaults read "${jamfpro_plist%.*}" jamfpro_url 2>/dev/null)
    fi
    if [[ -z "$jamfpro_api_client_id" ]]; then
        jamfpro_api_client_id=$(defaults read "${jamfpro_plist%.*}" jamfpro_api_client_id 2>/dev/null)
    fi
    if [[ -z "$jamfpro_api_client_secret" ]]; then
        jamfpro_api_client_secret=$(defaults read "${jamfpro_plist%.*}" jamfpro_api_client_secret 2>/dev/null)
    fi
fi

# If the Jamf Pro URL, the API Client ID or the API Client Secret aren't
# available otherwise, you will be prompted to enter the requested URL or
# API client credentials.

if [[ -z "$jamfpro_url" ]]; then
    read "?Please enter your Jamf Pro server URL : " jamfpro_url
fi

if [[ -z "$jamfpro_api_client_id" ]]; then
    read "?Please enter your Jamf Pro API client ID : " jamfpro_api_client_id
fi

if [[ -z "$jamfpro_api_client_secret" ]]; then
    read -s "?Please enter the API client secret for the $jamfpro_api_client_id API ID client: " jamfpro_api_client_secret
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

# This function uses the API client ID and client ID secret to get a new
# bearer token for API authentication.

GetJamfProAPIToken() {
    api_token=$(/usr/bin/curl -s -X POST "${jamfpro_url}/api/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode client_id=${jamfpro_api_client_id} --data-urlencode 'grant_type=client_credentials' --data-urlencode client_secret=${jamfpro_api_client_secret} | plutil -extract access_token raw -)
}

# This function invalidates the current bearer token so it can't be reused.

InvalidateJamfProAPIToken() {
    /usr/bin/curl -s -X POST "${jamfpro_url}/api/v1/auth/invalidate-token" --header "Authorization: Bearer ${api_token}"
}

# The jq command line tool is required in this script but is only installed by default on macOS Sequoia and later.
# If jq is not installed, the script stops and displays an error.

command -v jq >/dev/null 2>&1 || stop_on_error "jq command line tool is not installed. It is installed by default on macOS Sequoia and later. If you are using an earlier version of macOS, it is available from https://jqlang.org/download/ ."

print "Retrieving the list of available API Role privileges ..."

GetJamfProAPIToken
priv_response=$(/usr/bin/curl -s -w $'\n%{http_code}' --request GET "${jamfpro_url}/api/v1/api-role-privileges" --header "Authorization: Bearer ${api_token}" --header "Accept: application/json")

split_curl_response "$priv_response"

# If not able to retrieve the list of available API Role privileges, the script stops and displays an error.

if [[ "$REPLY_CODE" != "200" ]]; then
    stop_on_error "Failed to retrieve API Role privileges. Please try again with an API Client which includes the following privilege: 'Read API Roles'. Response from Jamf Pro server: ${REPLY_BODY}"
fi

# Extract the "privileges" array. jq -r outputs one decoded string per line, so no further unescaping is needed.

typeset -a all_privileges
all_privileges=("${(@f)$(print -r -- "$REPLY_BODY" | jq -r '.privileges[]' 2>/dev/null)}")

(( ${#all_privileges[@]} == 0 )) && stop_on_error "No privileges were returned by the Jamf Pro API."

print "Found ${#all_privileges[@]} total API Role privileges on this server."

# Prompt for the name of the new API role being created.

while true; do
    read "?Name for the new API Role: " new_role_name
    [[ -n "$new_role_name" ]] && break
    print "The API Role name cannot be blank."
done

# Select which privilege set you want the new API role to be assigned:
#
# Administrator: API role will be assigned all available API privileges.
# Auditor: API role will be assigned all privileges whose name starts with "Read ".
# 
# NOTE:
#
# API privileges starting with "View " (e.g. "View Disk Encryption Recovery Key")
# are intentionally excluded from being assigned to the Auditor API Role, even though they
# are also read-only in nature. This is because the View permissions may provide access
# to information not available to Jamf Pro user accounts which have been assigned the 
# Auditor account privileges set. If "View" privileges are needed for this API Role, 
# you will need to add them following the creation of the new API role by this script.

role_type=""
while true; do
    print ""
    print "Which privilege set should the new API Role approximate?"
    print "  1) Administrator - all API Role privileges"
    print "  2) Auditor       - all 'Read' API Role privileges"
    read "?Enter 1 or 2: " privilege_choice
    case "$privilege_choice" in
        1) role_type="Administrator"; break ;;
        2) role_type="Auditor"; break ;;
        *) print "Please enter 1 or 2." ;;
    esac
done

# Build the privilege list for the chosen role type

typeset -a selected_privileges

if [[ "$role_type" == "Administrator" ]]; then
    selected_privileges=("${all_privileges[@]}")
elif [[ "$role_type" == "Auditor" ]]; then
    for p in "${all_privileges[@]}"; do
        if [[ "$p" == "Read "* ]]; then
            selected_privileges+=("$p")
        fi
    done
else
    stop_on_error "Unrecognized privilege set '${role_type}'; expected 'Administrator' or 'Auditor'."
fi

(( ${#selected_privileges[@]} == 0 )) && stop_on_error "No privileges matched the '${role_type}' selection; nothing to create."

print "Selected ${#selected_privileges[@]} privileges for the '${role_type}' role."

# Create a JSON block which contains a properly formatted list of all API role privileges.

request_body=$(jq -n --arg name "$new_role_name" --args '{displayName: $name, privileges: $ARGS.positional}' "${selected_privileges[@]}")

InvalidateJamfProAPIToken
GetJamfProAPIToken

# Verify the API Client running this script already holds every privilege
# being granted to the new role - for Auditor, that's every "Read "
# privilege plus "Create API Roles" and "Update API Roles" specifically;
# for Administrator, that's every privilege in the catalog.

print "Verifying the API Client holds the privileges required to create a '${role_type}' role ..."

InvalidateJamfProAPIToken
GetJamfProAPIToken

auth_response=$(/usr/bin/curl -s -w $'\n%{http_code}' --request GET "${jamfpro_url}/api/v1/auth" --header "Authorization: Bearer ${api_token}" --header "Accept: application/json")

split_curl_response "$auth_response"

if [[ "$REPLY_CODE" != "200" ]]; then
    stop_on_error "Failed to read the API Client's authorization details. Response from Jamf Pro server: ${REPLY_BODY}"
fi

typeset -a client_strings
client_strings=("${(@f)$(print -r -- "$REPLY_BODY" | jq -r '[.. | strings] | .[]' 2>/dev/null)}")

typeset -A client_strings_set
for s in "${client_strings[@]}"; do
    client_strings_set[$s]=1
done

typeset -aU required_client_privileges
if [[ "$role_type" == "Auditor" ]]; then
    required_client_privileges=("${selected_privileges[@]}" "Create API Roles" "Update API Roles")
else
    required_client_privileges=("${selected_privileges[@]}")
fi

typeset -a missing_client_privileges
for p in "${required_client_privileges[@]}"; do
    [[ -z "${client_strings_set[$p]}" ]] && missing_client_privileges+=("$p")
done

if (( ${#missing_client_privileges[@]} > 0 )); then
    print -u2 -- "The API Client '${jamfpro_api_client_id}' is missing ${#missing_client_privileges[@]} of the ${#required_client_privileges[@]} privileges required to create a '${role_type}' role:"
    printf '  - %s\n' "${missing_client_privileges[@]}" >&2
    stop_on_error "Assign an API Role to the API Client that includes all of the privileges listed above, then try again."
fi

print "API Client holds the required privileges. Proceeding ..."

# Create the new API role and assign it all relevant API role privileges.

print "Creating API Role '${new_role_name}' ..."

InvalidateJamfProAPIToken
GetJamfProAPIToken

create_response=$(/usr/bin/curl -s -w $'\n%{http_code}' --request POST "${jamfpro_url}/api/v1/api-roles" --header "Authorization: Bearer ${api_token}" --header "Content-Type: application/json" --header "Accept: application/json" --data "$request_body")

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

InvalidateJamfProAPIToken

# Display report of successful API Role creation.

print ""
print "API Role created successfully:"
print "  ID:              ${new_role_id}"
print "  Display Name:    ${new_role_display_name}"
print "  Privilege set:   ${role_type} (${#selected_privileges[@]} privileges assigned)"
print ""
print "Note: 'Administrator'/'Auditor' are an appromiximation of the Jamf Pro account privilege sets with the same names."
print "API Roles have no built-in privilege sets of their own."