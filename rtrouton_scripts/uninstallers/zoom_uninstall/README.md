This script is designed to uninstall the Zoom videoconferencing client
and its associated components.

The script runs the following actions:

1. Checks to see if anyone is logged in. If someone is logged in, the **Zoom** app and **ZoomOpener** processes are stopped for the logged-in user.
2. If running, unload the Zoom audio kernel extension.
3. If present, delete the Zoom audio kernel extension.
4. Remove the Zoom application and other components from both the system level and also from the individual home folders.
5. Forget the existing installer package receipts.