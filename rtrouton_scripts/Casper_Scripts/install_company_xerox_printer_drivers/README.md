Script for use with Casper's Self Service when deploying Xerox printers. The Script checks **/Library/Printers/Xerox/PDEs/XeroxFeatures.plugin/Contents/Info.plist** for the **CFBundleShortVersionString** key value. 

If the value returned is less than the version of the current drivers, the print drivers are installed by a Casper policy before the requested printer is set up. 

If the installed drivers are the same version or higher as the print drivers available on the Casper server, this information is logged and the Xerox print drivers are not installed.

Blog post that uses this script is available here:

[http://derflounder.wordpress.com/2014/02/10/deploying-xerox-print-drivers-on-a-per-os-basis-via-caspers-self-service/](http://derflounder.wordpress.com/2014/02/10/deploying-xerox-print-drivers-on-a-per-os-basis-via-caspers-self-service/)
