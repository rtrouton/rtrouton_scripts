#!/bin/zsh --no-rcs

# This script connects to the Jamf Pro API and reports the account privileges
# assigned to each Jamf Pro local account, indicating whether each privilege is
# directly assigned to the account or inherited via membership in a Jamf Pro
# local group.
#
# Usage: /path/to/Local_Account_Permissions_Report.sh
#
# The script takes the following actions:
#
# 1. Uses the Classic API endpoint /JSSResource/accounts to retrieve a list of
#    all local accounts and local groups, then fetches full privilege detail for
#    each using /JSSResource/accounts/userid/{id} and groupid/{id}.
#
# 2. Creates a report in tab-separated value (.tsv) format containing:
#
#    Account Name
#    Account ID
#    Account Enabled / Disabled
#    Privilege Category
#    Privilege Name
#    Assignment Type
#
#    The Assignment Type column contains either "Permission assigned directly to
#    account" or "Permission assigned via membership in Jamf Pro group:
#    <Group Name>".
#
# 3. Displays the report.
#
# If setting up an API client with limited rights, here are the required API role privileges
# for the API client on the Jamf Pro server:
#
# Read Accounts

report_file="$(mktemp).tsv"
ERROR=0

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

# Privilege category map: This is mapping the names provided by the Classic API
# to the names desired to be used in the TSV file, as the name provided by the API
# does not always match the name used in the Jamf Pro Admin Console. This mapping is 
# defined once here and later used by both the WritePrivilegeRows and 
# WriteDirectPrivilegeRows functions.

privilege_categories=(
     "jss_objects	Jamf Pro Server Objects"
     "jss_settings	Jamf Pro Server Settings"
     "jss_actions	Jamf Pro Server Actions"
     "recon	Recon"
     "casper_admin	Casper Admin"
     "casper_remote	Casper Remote"
     "casper_imaging	Casper Imaging"
)

GetJamfProAPIToken() {

# This function uses the API client ID and client ID secret to get a new bearer token for API authentication.

api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode "client_id=${jamfpro_api_client_id}" --data-urlencode 'grant_type=client_credentials' --data-urlencode "client_secret=${jamfpro_api_client_secret}" | plutil -extract access_token raw -)
}


FetchClassicXML() {

# This function fetches XML from a Classic API accounts endpoint and saves it to a file.
# Usage: FetchClassicXML <userid|groupid|""> <id_or_blank> <output_file>
# Pass an empty string for id_type and id to fetch the top-level accounts list.

     local id_type="$1"
     local record_id="$2"
     local output_file="$3"
     local endpoint="${jamfpro_url}/JSSResource/accounts"

     [[ -n "$id_type" && -n "$record_id" ]] && endpoint="${endpoint}/${id_type}/${record_id}"

     /usr/bin/curl -s -X GET "$endpoint" -H "Authorization: Bearer ${api_token}" -H "Accept: application/xml" -o "$output_file"
}



ExtractIdNameList() {

# This function extracts id/name pairs from repeated child elements of an XML file and
# prints one tab-separated "id<TAB>name" line per element.
#
# Usage: ExtractIdNameList <xpath_parent> <xml_file>
# Example: ExtractIdNameList "//users/user" accounts_list.xml
#          ExtractIdNameList "//groups/group" accounts_list.xml

     local xpath_parent="$1"
     local xml_file="$2"
     local index=1
     local item_id item_name

     while true; do
          item_id=$(/usr/bin/xmllint --xpath "string(${xpath_parent}[${index}]/id)" "$xml_file" 2>/dev/null)
          [[ -z "$item_id" ]] && break
          item_name=$(/usr/bin/xmllint --xpath "string(${xpath_parent}[${index}]/name)" "$xml_file" 2>/dev/null)
          printf '%s\t%s\n' "$item_id" "$item_name"
          index=$(( index + 1 ))
     done
}

ExtractPrivilegesFromXML() {

# This function extracts all privilege names for one category from an XML file, one per line.
# Makes a single xmllint call per category rather than one per privilege.
#
# Usage: ExtractPrivilegesFromXML <category> <xml_file>

     local category="$1"
     local xml_file="$2"
     local raw

     raw=$(/usr/bin/xmllint --xpath \
          "//*[local-name()='privileges']/${category}/privilege" "$xml_file" 2>/dev/null) || return 0

     # Strip <privilege>...</privilege> tags, one name per line.
     printf '%s' "$raw" | /usr/bin/sed 's|<privilege>|\n|g; s|</privilege>||g' | grep -v '^$'
}

IsGroupMember() {

# Returns exit code 0 if account_id appears in a group's <members> list.
#
# Usage: IsGroupMember <account_id> <group_xml_file>

     local account_id="$1"
     local xml_file="$2"
     local index=1
     local member_id

     while true; do
          member_id=$(/usr/bin/xmllint --xpath \
               "string(//members/user[${index}]/id)" "$xml_file" 2>/dev/null)
          [[ -z "$member_id" ]] && return 1
          [[ "$member_id" == "$account_id" ]] && return 0
          index=$(( index + 1 ))
     done
}


WritePrivilegeRows() {

# Writes one TSV row per privilege in an XML file, using the given label for
# the Assignment Type column.
#
# Usage: WritePrivilegeRows <name> <id> <status> <assignment_type> <xml_file>

     local acct_name="$1"
     local acct_id="$2"
     local acct_status="$3"
     local assignment_type="$4"
     local xml_file="$5"
     local entry category display_name privilege_name

     for entry in "${privilege_categories[@]}"; do
          category="${entry%%$'\t'*}"
          display_name="${entry#*$'\t'}"
          while IFS= read -r privilege_name; do
               [[ -z "$privilege_name" ]] && continue
               printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$acct_name" "$acct_id" "$acct_status" "$display_name" "$privilege_name" "$assignment_type"
          done <<< "$(ExtractPrivilegesFromXML "$category" "$xml_file")"
     done
}

                              

WriteDirectPrivilegeRows() {

# This function writes TSV rows for privileges in the account XML that are 
# NOT present in any of the account's member groups. Since they are not group-assigned
# privileges, these are directly-assigned privileges.
#
# The Classic API returns the full effective privilege set in the account XML
# (including group-inherited ones), so group privileges must be subtracted to
# isolate what is directly assigned to the account.
#
# Group privileges per category are collected once into a variable before
# iterating account privileges, keeping xmllint calls to
# O(groups × categories) rather than O(privileges × groups × categories).
#
# Usage: WriteDirectPrivilegeRows <name> <id> <status> <groups_dir> <member_group_ids> <acct_xml_file>

     local acct_name="$1"
     local acct_id="$2"
     local acct_status="$3"
     local groups_tmp_dir="$4"
     local member_group_ids="$5"
     local acct_xml_file="$6"
     local entry category display_name
     local privilege_name group_id group_xml_file all_group_privs_for_category

     for entry in "${privilege_categories[@]}"; do
          category="${entry%%$'\t'*}"
          display_name="${entry#*$'\t'}"

          # Collect all group privileges for this category in one pass.
          all_group_privs_for_category=""
          while IFS= read -r group_id; do
               [[ -z "$group_id" ]] && continue
               group_xml_file="${groups_tmp_dir}/${group_id}.xml"
               [[ ! -f "$group_xml_file" ]] && continue
               all_group_privs_for_category="${all_group_privs_for_category}
$(ExtractPrivilegesFromXML "$category" "$group_xml_file")"
          done <<< "$member_group_ids"

          # Emit a Direct row for each account privilege not found in any group.
          while IFS= read -r privilege_name; do
               [[ -z "$privilege_name" ]] && continue
               if ! grep -qxF "$privilege_name" <<< "$all_group_privs_for_category"; then
                    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$acct_name" "$acct_id" "$acct_status" "$display_name" "$privilege_name" "Permission assigned directly to account"
               fi
          done <<< "$(ExtractPrivilegesFromXML "$category" "$acct_xml_file")"
     done
}



CountPrivileges() {

# Counts all privileges across all categories in an XML file.
#
# Usage: CountPrivileges <xml_file>

     local xml_file="$1"
     local total=0
     local category privs

     for category in jss_objects jss_settings jss_actions recon casper_admin casper_remote casper_imaging; do
          privs=$(ExtractPrivilegesFromXML "$category" "$xml_file")
          [[ -n "$privs" ]] && total=$(( total + $(printf '%s\n' "$privs" | grep -c .) ))
     done

     printf '%d' "$total"
}

FetchAndWriteReport() {
     local accounts_list_xml groups_tmp_dir acct_xml_file
     local account_id account_name account_status enabled_raw
     local group_id group_name group_xml_file member_group_ids
     local total_priv_count g_count direct_count

     printf 'Account Name\tAccount ID\tAccount Enabled\tPrivilege Category\tPrivilege Name\tAssignment Type\n'

     # Fetch the full accounts/groups list from the Classic API.
     
     accounts_list_xml=$(mktemp)
     FetchClassicXML "" "" "$accounts_list_xml"

     # Pre-fetch full group XML into per-group temp files. Done once here so
     # each group is fetched exactly once regardless of how many accounts are
     # processed.
     
     groups_tmp_dir=$(mktemp -d)
     while IFS=$'\t' read -r group_id group_name; do
          [[ -z "$group_id" ]] && continue
          FetchClassicXML "groupid" "$group_id" "${groups_tmp_dir}/${group_id}.xml"
     done <<< "$(ExtractIdNameList "//groups/group" "$accounts_list_xml")"

     # Process each local account.
     
     acct_xml_file=$(mktemp)
     while IFS=$'\t' read -r account_id account_name; do
          [[ -z "$account_id" ]] && continue

          # Renew the token before each account to prevent expiry during the
          # report run when processing accounts with large privilege sets.
          
          GetJamfProAPIToken

          # Fetch this account's full detail XML.
          
          FetchClassicXML "userid" "$account_id" "$acct_xml_file"

          # Read enabled status from the account detail XML.
          
          enabled_raw=$(/usr/bin/xmllint --xpath "string(/account/enabled)" "$acct_xml_file" 2>/dev/null)
          [[ "$enabled_raw" == "Disabled" ]] && account_status="Disabled" || account_status="Enabled"

          # Determine which groups this account belongs to by checking each
          # group's <members> list. The account XML does not include this.
          
          member_group_ids=""
          while IFS=$'\t' read -r group_id group_name; do
               [[ -z "$group_id" ]] && continue
               group_xml_file="${groups_tmp_dir}/${group_id}.xml"
               [[ ! -f "$group_xml_file" ]] && continue
               if IsGroupMember "$account_id" "$group_xml_file"; then
                    member_group_ids="${member_group_ids}${group_id}"$'\n'
               fi
          done <<< "$(ExtractIdNameList "//groups/group" "$accounts_list_xml")"

          # Write group-inherited privilege rows and count them.
          
          total_priv_count=0
          while IFS=$'\t' read -r group_id group_name; do
               [[ -z "$group_id" ]] && continue
               grep -qxF "$group_id" <<< "$member_group_ids" || continue
               group_xml_file="${groups_tmp_dir}/${group_id}.xml"
               [[ ! -f "$group_xml_file" ]] && continue
               WritePrivilegeRows "$account_name" "$account_id" "$account_status" "Permission assigned via membership in Jamf Pro group: ${group_name}" "$group_xml_file"
               g_count=$(CountPrivileges "$group_xml_file")
               total_priv_count=$(( total_priv_count + g_count ))
          done <<< "$(ExtractIdNameList "//groups/group" "$accounts_list_xml")"

          # Write directly-assigned privilege rows.
          
          WriteDirectPrivilegeRows "$account_name" "$account_id" "$account_status" "$groups_tmp_dir" "$member_group_ids" "$acct_xml_file"

          # Update total using account XML privilege count (includes all
          # effective privileges, so take the max to avoid double-counting).
          
          direct_count=$(CountPrivileges "$acct_xml_file")
          [[ "$direct_count" -gt "$total_priv_count" ]] && total_priv_count="$direct_count"

          # Accounts with no privileges get a single blank-privilege row so
          # they still appear in the report.
          
          if [[ "$total_priv_count" -eq 0 ]]; then
               printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$account_name" "$account_id" "$account_status" "" "" ""
          fi

     done <<< "$(ExtractIdNameList "//users/user" "$accounts_list_xml")"

     rm -f "$acct_xml_file" "$accounts_list_xml"
     rm -rf "$groups_tmp_dir"
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

# Create the TSV file and write the account and permission information.

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
