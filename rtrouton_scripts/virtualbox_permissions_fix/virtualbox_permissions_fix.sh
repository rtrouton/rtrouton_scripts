#!/bin/sh

/usr/bin/find /path/to/VMs/ ! -user user -exec chown -R user:group {} \;
/usr/bin/find /path/to/VMs/ ! -perm 775 -exec chmod -R ug+rwx {} \;