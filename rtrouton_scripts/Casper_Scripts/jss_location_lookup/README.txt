This scripts works with the jamf binary on Casper-managed Macs to auto-populate the JSS Location inventory from Active Directory. It runs on a AD-bound Mac and uses dscl to search for certain AD user account attributes and sends them to the JSS via recon.

Note: Depending on your Active Directory structure, you may not have every value listed or it may not be used as specified.

Credit to Ben Toms for sharing the original version of this script:
http://list.jamfsoftware.com/mailman/htdig/casper/2011-December/016859.html