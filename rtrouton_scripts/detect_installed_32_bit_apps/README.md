This script is designed to Detect all 32-bit apps installed in `/Applications`, `/Library` or `/usr/local` and output list to logfile stored in /var/log.

If any 32-bit applications are found in `/Applications`, `/Library` or `/usr/local`, the path to the 32-bit application is listed in the log:

`/path/to/32bit_application_name_here.app`

If no 32-bit applications are found in `/Applications`, `/Library` or `/usr/local`, the following is output to the log:

`No 32-bit applications found in /Applications, /Library or /usr/local.`