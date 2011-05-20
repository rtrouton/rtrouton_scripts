#!/bin/bash

if ping -c 1 internal.ip.address1 || ping -c 1 internal.ip.address2
then
     sudo dscl /Search -append / CSPSearchPath "/Active Directory/domain.com"
else
     sudo dscl /Search -delete / CSPSearchPath "/Active Directory/domain.com"
fi