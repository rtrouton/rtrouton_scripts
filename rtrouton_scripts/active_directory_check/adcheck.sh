#!/bin/bash

if ping -c 1 internal.ip.address1 || ping -c 1 internal.ip.address2
then
     dscl /Search -append / CSPSearchPath "/Active Directory/domain.com"
else
     dscl /Search -delete / CSPSearchPath "/Active Directory/domain.com"
fi
