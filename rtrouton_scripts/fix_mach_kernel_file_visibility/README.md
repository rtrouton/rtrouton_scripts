This script checks to see if the **/mach_kernel** file is visible or hidden. The **/mach_kernel** file should not be visible when viewed from the Finder, so the script will use **/usr/bin/chflags** to set the **/mach_kernel** file to be hidden.

Original script by Tim Sutton:

[http://macops.ca/security-updates-leaving-mach_kernel-visible/](http://macops.ca/security-updates-leaving-mach_kernel-visible/)


For information on how to hide the **/mach_kernel** file, please see this Apple KBase article:

[https://support.apple.com/HT203829](https://support.apple.com/HT203829)