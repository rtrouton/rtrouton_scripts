#!/bin/sh

LDAPServerCheck=`/usr/bin/dscl localhost -list /LDAPv3`

if [ "$LDAPServerCheck" = "" ]; then
        result="Not Bound to LDAP"
elif [ "$LDAPServerCheck" != "" ]; then
        result=$LDAPServerCheck
fi

echo "<result>$result</result>"