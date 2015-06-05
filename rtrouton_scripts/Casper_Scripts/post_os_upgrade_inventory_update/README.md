Payload-free package script for use with Casper when you want to trigger **jamf manage** followed by an inventory update. The use case it was written for was to help Macs who have had a Casper-initiated OS upgrade report back on the upgrade's status. 

As a post-upgrade action, the launchdaemon and accompanying script created by running this script verifies that the Mac can communicate with the Casper server. Once communication is verified, it takes the following actions:

1. Runs **jamf manage** to enforce Casper management 
2. Runs a recon to send an updated inventory to the JSS to report
   that the OS upgrade has happened.
