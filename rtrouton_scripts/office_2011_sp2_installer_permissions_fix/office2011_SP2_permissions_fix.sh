#!/bin/sh

if [ -d /Applications/Microsoft\ Office\ 2011 ]; then
   /usr/sbin/chown root:admin /Applications/Microsoft\ Office\ 2011
   /bin/chmod 775 /Applications/Microsoft\ Office\ 2011
   /usr/bin/find /Applications/Microsoft\ Office\ 2011 ! -group admin -exec chown root:admin {} \;
   /usr/bin/find /Applications/Microsoft\ Office\ 2011 ! -perm 775 -exec chmod 775 {} \;
fi
