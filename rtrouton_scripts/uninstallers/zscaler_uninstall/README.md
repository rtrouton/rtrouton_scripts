This script is designed to uninstall the Zscaler app and its associated components.

The script runs the following actions:

1. Verifies if the Zscaler software is installed.
2. Verifies if the Zscaler-provided uninstall script is available.

If the  Zscaler-provided uninstall script is available:

1. Runs the Zscaler-provided uninstall script
2. Removes any installer package receipts (this assumes that Zscaler was packaged for delivery using AutoPkg or other means.)

If the  Zscaler-provided uninstall script is not available:

1. Unloads the Zscaler LaunchAgent.
2. Removes the Zscaler LaunchAgent.
3. Unloads the Zscaler LaunchDaemons.
4. Removes the Zscaler LaunchDaemons.
5. Removes the Zscaler software.
6. Removes Zscaler components from user folders.
7. Removes any installer package receipts (this assumes that Zscaler was packaged for delivery using AutoPkg or other means.)