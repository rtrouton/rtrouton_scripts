#!/bin/zsh --no-rcs

# This script connects to the Jamf Pro API and reports which API clients are assigned
# to which API client roles.
#
# Usage: /path/to/API_Client_Role_Reporting.sh
#
# The script takes the following actions:
#
# 1. Uses the Jamf Pro API to download the relevant information regarding which API roles are assigned to which API clients.
#
# 2. Create a report in tab-separated value (.tsv) format which contains the following information about API clients and their
#    associated API roles.
#
#    Client Name 
#    Client ID
#    Enabled / Disabled
#    Assigned Role
#
#  3. Displays the information in the report.
#
# If setting up an API client with limited rights, here are the required API role privileges
# for the API client on the Jamf Pro server:
#
# Read API Integrations
# Read API Roles

report_file="$(mktemp).tsv"
ERROR=0

# Check for the jq command line tool to be installed. It must be installed for this script to work.
# The jq command line tool is installed by default on macOS Sequoia and later. 

which jq &>/dev/null

if [[ $? -ne 0 ]]; then
   echo "ERROR: jq command line tool is not installed. Please install the jq command line tool."
   echo "Downloads available from https://jqlang.org/download/ ."
   ERROR=1
   exit "$ERROR"
fi

# Get location of installed jq command line tool.

jqTool=$(which jq)

# If you choose to hardcode API information into the script, set one or more of
# the following values:
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

# If you do not want to hardcode API information into the script, you can also
# store these values in a ~/Library/Preferences/com.github.jamfpro-info.plist
# file.
#
# To create the file and set the values, run the following commands and
# substitute your own values where appropriate:
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
# If the com.github.jamfpro-info.plist file is available, the script will read
# in the relevant information from the plist file.

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

GetJamfProAPIToken() {

# This function uses the API client ID and client ID secret to get a new bearer token for API authentication.

api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode client_id=${jamfpro_api_client_id} --data-urlencode 'grant_type=client_credentials' --data-urlencode client_secret=${jamfpro_api_client_secret} | plutil -extract access_token raw -)
}


# This function gets all pages from the api-integrations Jamf Pro API endpoint and writes a report in TSV format.
#
# Even though you shouldn't be able to create an API Client without an assigned API Role, API clients without 
# assigned roles are reported with the Assigned Role entry left blank.

FetchAndWriteReport() {
     local page=0
     local page_size=100
     local item_count

     printf 'Client Name\tClient ID\tEnabled\tAssigned Role\n'

     while true; do
          local response
          response=$(/usr/bin/curl -s -X GET "${jamfpro_url}/api/v1/api-integrations?page=${page}&page-size=${page_size}" -H "Authorization: Bearer ${api_token}" -H "Accept: application/json")

          # For each client ID, create a row and include the assigned API Client Role.
          # Client IDs with no roles create a row with an empty Assigned Role field.
          
          "$jqTool" -r '.results[] | . as $client | if (.authorizationScopes | length) > 0 then .authorizationScopes[] | [$client.displayName, $client.clientId, ($client.enabled | tostring), .] | @tsv else [$client.displayName, $client.clientId, ($client.enabled | tostring), ""] | @tsv end' <<< "$response"

          # Stop when a partial page is returned
          item_count=$("$jqTool" '.results | length' <<< "$response")
          if (( item_count < page_size )); then break; fi
          (( page++ ))
     done
}

progress_indicator() {
  spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
  while :
  do
    for i in $(seq 0 7)
    do
      echo -n "${spinner:$i:1}"
      echo -en "\010"
      /bin/sleep 0.10
    done
  done
}

echo "Report being generated. File location will appear below once ready."

progress_indicator &
SPIN_PID=$!
trap "kill -9 $SPIN_PID 2>/dev/null" $(seq 0 15)

GetJamfProAPIToken

if [[ -z "$api_token" ]]; then
     kill -9 "$SPIN_PID" 2>/dev/null
     echo "Error: Failed to obtain API token. Check your API client credentials and Jamf Pro URL." >&2
     ERROR=1
     exit "$ERROR"
fi

FetchAndWriteReport > "$report_file"

kill -9 "$SPIN_PID" 2>/dev/null

if [[ ! -f "$report_file" ]]; then
     echo "Error: Report file was not created." >&2
     ERROR=1
     exit "$ERROR"
fi

echo ""
echo "Report available here: $report_file"
echo ""

# Display the report file's contents formatted as aligned columns.
/usr/bin/column -t -s $'\t' "$report_file"

exit "$ERROR"