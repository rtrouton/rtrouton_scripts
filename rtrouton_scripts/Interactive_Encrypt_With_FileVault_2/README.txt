This script sets up FileVault 2 encryption using the Cauliflower Vest csfde tool. The script will ask some questions, then using that information to initialize the encryption and enable the user account specified.

csfde
_____

The script is expecting the csfde tool to be installed in /usr/local/bin. Install the csfde tool there before running the script.


Recovery Key
------------


If you are not using a managed keychain, the script will output a machine-generated recovery key that is individual to this specific Mac.

VERY IMPORTANT: The machine-generated recovery key is not saved anywhere outside the machine. Make a record of it or you will have no recovery key to help unlock your Mac's encryption if there's a problem.

If you are using a managed recovery key, the script will report that fact and not output a  machine-generated recovery key


The script will request a restart and then report "[Process Completed]" once it has completed initializing the FileVault 2 encryption process and reported on the recovery key. It is safe at that point to close that Terminal window and reboot your Mac.

