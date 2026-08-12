#!/bin/zsh --no-rcs

# This script connects to the Jamf Pro API and reports the privileges
# assigned to each Jamf Pro API Role, along with which API Clients, if
# any, are assigned that role.
#
# Usage: /path/to/Generate_Jamf_Pro_API_Role_Privileges_Report.sh
#
# The script takes the following actions:
#
# 1. Uses the Jamf Pro API to retrieve a list of all API Roles and the privileges
#    assigned to each role.
#
# 2. Uses the Jamf Pro API to retrieve a list of all API Clients, whether each is
#    enabled or disabled, and which API Role(s) are assigned to
#    each API Client.
#
# 3. Creates a report in tab-separated value (.tsv) format containing:
#
#    Role Name
#    Role ID
#    Privilege Name
#    Assigned API Clients
#
#    The "Assigned API Clients" column lists every enabled or disabled API
#    Client assigned to that role, identified by Client ID (the UUID shown
#    in the Jamf Pro console and used to request an access token), in the
#    format "Client ID (Enabled)" or "Client ID (Disabled)", separated by
#    semicolons. If no API Client is currently assigned to a role, this
#    column will read "(No API Client assigned)".
#
#    If an API Client has been created but no Client ID/secret pair has been
#    generated for it yet, the client's display name is shown instead, with
#    a note, e.g. "Static Group Amendment Client (No Client ID generated)
#    (Enabled)".
#
# 4. Displays the report.
#
# If setting up an API client with limited rights, here are the required API
# role privileges for the API client on the Jamf Pro server:
#
# Read API Roles
# Read API Integrations

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
    read -s "?Please enter the API client secret for the $jamfpro_api_client_id API client ID: " jamfpro_api_client_secret
fi

echo ""

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

GetJamfProAPIToken() {
    # This function uses the API client ID and client ID secret to get a new bearer token for API authentication.
    api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode "client_id=${jamfpro_api_client_id}" --data-urlencode 'grant_type=client_credentials' --data-urlencode "client_secret=${jamfpro_api_client_secret}" | plutil -extract access_token raw -)
}

FetchAllPages() {
    # This function pages through a Jamf Pro API list endpoint, appending the
    # "results" array from each page's JSON response into a single NDJSON
    # output file (one JSON object per line, via `jq -c '.results[]'`).
    #
    # Usage: FetchAllPages <endpoint_path> <sort_field> <output_ndjson_file>
    # Example: FetchAllPages "/api/v1/api-roles" "id" roles.ndjson

    local endpoint_path="$1"
    local sort_field="$2"
    local output_file="$3"
    local page=0
    local page_size=100
    local page_json total_count results_count running_count

    : > "$output_file"
    running_count=0

    while true; do
        page_json=$(/usr/bin/curl -s -X GET "${jamfpro_url}${endpoint_path}?page=${page}&page-size=${page_size}&sort=${sort_field}:asc" -H "Authorization: Bearer ${api_token}" -H "Accept: application/json")

        total_count=$(printf '%s' "$page_json" | jq -r '.totalCount // 0')
        results_count=$(printf '%s' "$page_json" | jq -r '.results | length')

        [[ "$results_count" -eq 0 ]] && break

        printf '%s' "$page_json" | jq -c '.results[]' >> "$output_file"

        running_count=$(( running_count + results_count ))
        page=$(( page + 1 ))

        [[ "$running_count" -ge "$total_count" ]] && break
    done
}

BuildClientAssignmentMap() {
    # This function reads the API Clients NDJSON file and, for every API Role
    # named in a client's authorizationScopes, appends a formatted client
    # entry ("Client ID (Enabled)" or "Client ID (Disabled)") to an
    # associative array keyed by role display name. Multiple clients
    # assigned to the same role are separated with "; ".
    #
    # Note: This uses each API Client's Client ID (the UUID shown in the
    # Jamf Pro console and used to request an access token), not its display
    # name.
    #
    # In the event that an API Client returns a null or empty Client ID, 
    # this function falls back to the client's display name with a note, 
    # similar to what's shown below:
    #
    # "Static Group Amendment Client (No Client ID generated) (Enabled)".

    local clients_file="$1"
    local client_json client_id client_name client_identifier client_enabled client_status role_name

    while IFS= read -r client_json; do
        [[ -z "$client_json" ]] && continue

        client_id=$(printf '%s' "$client_json" | jq -r '.clientId // empty')
        client_enabled=$(printf '%s' "$client_json" | jq -r '.enabled')
        [[ "$client_enabled" == "true" ]] && client_status="Enabled" || client_status="Disabled"

        if [[ -n "$client_id" ]]; then
            client_identifier="$client_id"
        else
            client_name=$(printf '%s' "$client_json" | jq -r '.displayName')
            client_identifier="${client_name} (No Client ID generated)"
        fi

        while IFS= read -r role_name; do
            [[ -z "$role_name" ]] && continue

            if [[ -n "${role_client_map[$role_name]}" ]]; then
                role_client_map[$role_name]="${role_client_map[$role_name]}; ${client_identifier} (${client_status})"
            else
                role_client_map[$role_name]="${client_identifier} (${client_status})"
            fi
        done < <(printf '%s' "$client_json" | jq -r '.authorizationScopes[]?')
    done < "$clients_file"
}

FetchAndWriteReport() {
    local roles_file clients_file role_json role_id role_name privilege_name assigned_clients

    typeset -gA role_client_map

    printf 'Role Name\tRole ID\tPrivilege Name\tAssigned API Clients\n'

    roles_file=$(mktemp)
    clients_file=$(mktemp)

    # Fetch the full list of API Roles and API Clients from the Jamf Pro API.
    FetchAllPages "/api/v1/api-roles" "id" "$roles_file"
    FetchAllPages "/api/v1/api-integrations" "id" "$clients_file"

    # Build the role -> assigned clients lookup before iterating roles.
    BuildClientAssignmentMap "$clients_file"

    while IFS= read -r role_json; do
        [[ -z "$role_json" ]] && continue

        role_id=$(printf '%s' "$role_json" | jq -r '.id')
        role_name=$(printf '%s' "$role_json" | jq -r '.displayName')

        if [[ -n "${role_client_map[$role_name]}" ]]; then
            assigned_clients="${role_client_map[$role_name]}"
        else
            assigned_clients="(No API Client assigned)"
        fi

        # Roles with no privileges assigned still get a row so they appear
        # in the report.
        if [[ "$(printf '%s' "$role_json" | jq -r '.privileges | length')" -eq 0 ]]; then
            printf '%s\t%s\t%s\t%s\n' "$role_name" "$role_id" "" "$assigned_clients"
            continue
        fi

        while IFS= read -r privilege_name; do
            [[ -z "$privilege_name" ]] && continue
            printf '%s\t%s\t%s\t%s\n' "$role_name" "$role_id" "$privilege_name" "$assigned_clients"
        done < <(printf '%s' "$role_json" | jq -r '.privileges[]')
    done < "$roles_file"

    rm -f "$roles_file" "$clients_file"
}

progress_indicator() {
    local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    while :; do
        for i in $(seq 0 9); do
            echo -n "${spinner:$i:1}"
            echo -en "\010"
            /bin/sleep 0.10
        done
    done
}

echo "Report being generated. File location will appear below once ready."
progress_indicator &
SPIN_PID=$!
trap "kill -9 $SPIN_PID 2>/dev/null; rm -f \"$report_file\"" EXIT INT TERM HUP

# Get initial bearer token for API authentication
GetJamfProAPIToken

if [[ -z "$api_token" ]]; then
    kill -9 "$SPIN_PID" 2>/dev/null
    echo "Error: Failed to obtain API token. Check your API client credentials and Jamf Pro URL." >&2
    ERROR=1
    exit "$ERROR"
fi

# Create the TSV file and write the API Role and API Client information.
FetchAndWriteReport > "$report_file"

kill -9 "$SPIN_PID" 2>/dev/null

# Report written successfully — clear the exit trap so the report file
# is not deleted on normal exit.
trap - EXIT INT TERM HUP

# If the TSV file doesn't exist, set an error condition and exit.
if [[ ! -f "$report_file" ]]; then
    echo "Error: Report file was not created." >&2
    ERROR=1
    exit "$ERROR"
fi

# Display contents of report.
/usr/bin/column -t -s $'\t' "$report_file"

# Display location of the report.
echo ""
echo "Report available here: $report_file"
echo ""

exit "$ERROR"