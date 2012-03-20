This script is adapted from Patrick Gallagher's MigrateUserHomeToDomainAcct.sh script. Original script available from here:

http://blog.macadmincorner.com/migrate-local-user-to-domain-account/

The main thing you should need to edit is the "Verify NetID", as that does a lookup for an LDAP user account. To fix it, you'll need to change the "lookupAccount" value to an account on your LDAP server (preferably, an account that nobody should be deleting anytime soon) and do some minor text editing. You may also want to add "| grep -v your_local_admin_account_shortname |" to the listUsers value, as that will prevent your local admin account from showing up as one that can be migrated.

One issue to note is that, when you launch the script, it'll show you a list of shortnames that can be migrated. If you're migrating multiple accounts, be aware that the script does not refresh the list between migration runs and so the old shortname will still show up in that list until the script is quit and relaunched.