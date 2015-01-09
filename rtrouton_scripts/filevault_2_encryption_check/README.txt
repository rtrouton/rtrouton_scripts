This script checks to see if a Mac is running 10.7 or higher. If the Mac in question is running 10.7 or higher, the script reports on whether or not the Mac's boot volume is encrypted with Apple's FileVault 2 encryption and gives the encryption or decryption status.

I've also posted a Casper-specific version of the script, for use as an Extension Attribute. It's available from the following location:

https://github.com/rtrouton/rtrouton_scripts/tree/master/rtrouton_scripts/Casper_Extension_Attributes

There have been other folks who have built their own scripts based on mine, and were kind enough to share back the results. All of those folks are in the "scripts_by_third_parties" directory.

Output produced by this script:

This script is designed to check the FileVault 2 encryption status of Macs running Mac OS X 10.7.x and higher. It first checks to make sure the version of Mac OS X begins with "10". If it is not, the following message is displayed without quotes:

"Unknown Version Of Mac OS X"

Next, it checks to see if the OS on the Mac is 10.7 or higher. If it is not, the following message is displayed without quotes:

"FileVault 2 Encryption Not Available For This Version Of Mac OS X"

If the Mac is running 10.7 or higher, but the boot volume is not a CoreStorage volume, the following message is displayed without quotes:

"FileVault 2 Encryption Not Enabled"


If the Mac is running 10.7 or higher and the boot volume is a CoreStorage volume, the script checks to see if the machine is encrypted, encrypting, or decrypting.

If not encrypted, the following message is displayed without quotes:

"FileVault 2 Encryption Not Enabled"

If encrypted, the following message is displayed without quotes:

"FileVault 2 Encryption Complete"

If encrypting, the following message is displayed without quotes:

"FileVault 2 Encryption Proceeding." 

How much has been encrypted of of the total amount of space is also displayed. 
If the amount of encryption is for some reason not known, the following message
is displayed without quotes: 

"FileVault 2 Encryption Status Unknown. Please check."

If decrypting, the following message is displayed without quotes:

"FileVault 2 Decryption Proceeding" 

How much has been decrypted of of the total amount of space is also displayed

If fully decrypted, the following message is displayed without quotes:

"FileVault 2 Decryption Complete"
