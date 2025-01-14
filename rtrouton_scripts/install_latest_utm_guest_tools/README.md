This script will download and install the latest version of UTM Guest Tools.

How the script works:

1. Downloads the latest UTM Guest Tools installer package from GitHub to a temp directory.
2. Verifies the download was successful.
3. Verifies the installer package is signed by the correct folks: `Turing Software LLC`
4. If download and code signature checks both succeed, installs the latest UTM Guest Tools using the downloaded installer package.