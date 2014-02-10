Script for use with Casper's Self Service when deploying Canon printers. Script checks **/Library/Printers/Canon/CUPSPS2/Utilities/Canon CUPS PS Printer Utility.app/Contents/Info.plist** for the **CFBundleVersion** key value. 

If the value returned is less than the version of the current drivers, the print drivers are installed by a Casper policy before the requested printer is set up. 

If the installed drivers are the same version or higher as the print drivers available on the Casper server, this information is logged and the Canon print drivers are not installed.

Blog post that uses this script is available here:

[http://derflounder.wordpress.com/2014/02/06/deploying-canon-print-drivers-with-printer-setups-via-caspers-self-service/](http://derflounder.wordpress.com/2014/02/06/deploying-canon-print-drivers-with-printer-setups-via-caspers-self-service/)