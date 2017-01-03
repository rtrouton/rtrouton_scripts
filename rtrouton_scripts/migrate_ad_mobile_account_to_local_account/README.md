This script is designed to convert an Active Directory mobile account to a local account using the following process:

1. Detects if the Mac is bound to AD and offers to unbind the Mac from AD if desired.
2. Display a list of the accounts with a UID greater than 1000
3. Once an account is selected, back up the password hash of the account from the **AuthenticationAuthority** attribute
4. Remove the following attributes from the specified account:  
`cached_groups`,
`cached_auth_policy`,
`CopyTimestamp` - This attribute is used by the OS to determine if the account is a mobile account,
`SMBPrimaryGroupSID`,
`OriginalAuthenticationAuthority`,
`OriginalNodeName`,
`AuthenticationAuthority`,
`SMBSID`,
`SMBScriptPath`,
`SMBPasswordLastSet`,
`SMBGroupRID`,
`PrimaryNTDomain`,
`AppleMetaRecordName`,
`MCXSettings`, and
`MCXFlags`


5. Recreate the **AuthenticationAuthority** attribute and restore the password hash of the account from backup
6. Restart the directory services process
7. Check to see if the conversion process succeeded by checking the **OriginalNodeName** attribute for the value `Active Directory`.
8. If the conversion process succeeded, update the permissions on the account's home folder.
9. Add the specified user to the **staff** group on the Mac.
10. Prompt if admin rights should be granted for the specified account

This script is adapted from Patrick Gallagher's MigrateUserHomeToDomainAcct.sh script, with additional inspiration by Lisa Davies's Perl script to migrate AD mobile accounts to local accounts:

[http://lisacherie.com/?p=239](http://lisacherie.com/?p=239)
