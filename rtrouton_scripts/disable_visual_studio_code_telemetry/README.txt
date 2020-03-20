This script is designed to do the following:

Disable Microsoft's Visual Studio Code's telemetry

Here's how it works:

1. Checked to make sure the Mac in question was logged-in
2. Verified that the logged-in user was not the root user.
3. Verified that jq was installed at a location defined in the script and set as executable.
4. Checked for the existence of the settings.json file in /Users/username_here/Library/Application Support/Code/User.

If /Users/username_here/Library/Application Support/Code/User/settings.json is present, the script does the following:

A. Reads out the contents of the existing settings.json file.
B. Adds the following setting to the copied contents:

"telemetry.enableTelemetry": false

C. Overwrites the existing settings.json file with the copied contents, which added the new telemetry setting.
D. Changes the ownership of the /Users/username_here/Library/Application Support/Code/User/settings.json file to that of the logged-in user.


If /Users/username_here/Library/Application Support/Code/User/settings.json is not present, the script does the following:

A. Creates the settings.json file.
B. Adds the following setting to the newly-created file:

"telemetry.enableTelemetry": false

C. Changes the ownership of the /Users/username_here/Library/Application Support/Code/User/settings.json file to that of the logged-in user.

5. Verifies that the telemetry.enableTelemetry setting is present and set to "false".