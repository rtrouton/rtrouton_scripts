This script is designed to detect all Intel-based apps installed in `/Applications`, `/Library` or `/usr/local` and output list to a logfile stored in `/var/log`.

If any Intel-based applications are found in `/Applications`, `/Library` or `/usr/local`, the path to the Intel-based application is listed in the log:

`/path/to/Intel-based_application_name_here.app`

If no Intel-based applications are found in `/Applications`, `/Library` or `/usr/local`, the following is output to the log:

`No Intel-based applications found in /Applications, /Library or /usr/local.`