This script is designed to check and report the status of encrypted Apple File System (APFS) drives.

It first checks to see if a Mac is running 10.13.x or higher. If the Mac is question is running 10.13.x or higher, the script reports if it is using encryption on an APFS drive  and gives the encryption or decryption status.

If encrypted, the following message is displayed: `FileVault is On.`

If encrypting, the following message is displayed: `Encryption in progress:` 
How much has been encrypted of of the total amount of space is also displayed.

If decrypting, the following message is displayed: `Decryption in progress:` How much has been decrypted of of the total amount of space is also displayed

If not encrypted, the following message is displayed:  `FileVault is Off.`

If run on a drive which is not using APFS, the following message is displayed: `Unable to display encryption status for filesystems other than APFS.`
