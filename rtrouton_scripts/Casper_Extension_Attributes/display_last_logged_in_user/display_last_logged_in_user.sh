#!/bin/zsh

# Get the last user who logged in at the OS login window
# The "last" command will tag those logins as "console"

last_logged_in=$(/usr/bin/last | awk '/console/ {print $1}' | tail -1)

# If the "last_logged_in" variable is returning an empty value,
# then the "result" variable will return "NA" for Not Applicable.
#
# Otherwise, the "result" variable should return the username of 
# the account which last logged into the OS login window.

if [[ -z "$last_logged_in" ]]; then
    result="NA"
else
    result="$last_logged_in"
fi

echo "<result>$result</result>"