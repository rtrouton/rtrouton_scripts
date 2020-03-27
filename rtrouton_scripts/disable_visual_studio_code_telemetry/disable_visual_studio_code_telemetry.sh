#!/bin/bash

# This script disables telemetry in Microsoft's Visual Studio Code.

exitCode=0

# This script uses jq, which is a tool for working with JSON files.
# It is not natively available as part of macOS, so it needs to be
# installed separately.
#
# Pre-built jq binaries for macOS are available via the link below:
#
# https://stedolan.github.io/jq/download/

jq="/path/to/jq_binary"

# get the currently logged-in user and go ahead if not root
CURRENT_USER=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

if [[ -n "$CURRENT_USER" && "$CURRENT_USER" != "root" ]]; then

  USER_HOME=$(/usr/bin/dscl . -read "/Users/$CURRENT_USER" NFSHomeDirectory | /usr/bin/sed 's/^[^\/]*//g')

  # If jq is executable, proceed with script.
  # Otherwise halt and log an error.

  if [[ -x "$jq" ]]; then

    # If an existing settings.json file exists for Visual Studio Code,
    # update it with the desired telemetry setting.

    if [[ -f "$USER_HOME/Library/Application Support/Code/User/settings.json" ]]; then
      vscode_settings="$USER_HOME/Library/Application Support/Code/User/settings.json"
      updated_vscode_settings=$("$jq" '."telemetry.enableTelemetry" = false' <"$vscode_settings")
      echo "${updated_vscode_settings}" >"$vscode_settings"
      /usr/sbin/chown -R "$CURRENT_USER" "$vscode_settings"
    else

      # If an existing settings.json file does not yet exist for Visual Studio Code,
      # create the settings file with the desired telemetry setting.

      if [[ ! -d "$USER_HOME/Library/Application Support/Code/User" ]]; then
        sudo -u "$CURRENT_USER" /bin/mkdir -p "$USER_HOME/Library/Application Support/Code/User"
      fi
      vscode_settings="$USER_HOME/Library/Application Support/Code/User/settings.json"
      /bin/cat > "$vscode_settings" << 'VSCODE_TELEMETRY_DISABLED'
{
  "telemetry.enableTelemetry": false
}
VSCODE_TELEMETRY_DISABLED
      /usr/sbin/chown -R "$CURRENT_USER" "$vscode_settings"
    fi
  else
    echo "jq not executable!"
    exitCode=1
  fi

  # Verify that the desired setting is in place

  vscode_settings="$USER_HOME/Library/Application Support/Code/User/settings.json"
  if [[ $("$jq" '."telemetry.enableTelemetry"' "$vscode_settings") = "false" ]]; then
    echo "Telemetry disabled."
  else
    echo "Unable to verify that telemetry is disabled!"
    exitCode=1
  fi
fi

exit "$exitCode"
