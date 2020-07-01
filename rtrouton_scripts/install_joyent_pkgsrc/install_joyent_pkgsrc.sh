#!/bin/bash

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

# Function to provide custom curl options
myCurl () { /usr/bin/curl -k --retry 3 --silent --show-error "$@"; }

# For the SixtyFourBitURL variable, put the complete address of the 64-bit pkgsrc bootstrap kit.
# This variable's URL may change periodically. Check the following website for the latest address:
# http://pkgsrc.joyent.com/install-on-osx/

SixtyFourBitURL="https://pkgsrc.joyent.com/packages/Darwin/bootstrap/bootstrap-2015Q2-x86_64.tar.gz"

# For the ThirtyTwoBitURL variable, put the complete address of the 32-bit pkgsrc bootstrap kit.
# This variable's URL may change periodically. Check the following website for the latest address:
# http://pkgsrc.joyent.com/install-on-osx/

ThirtyTwoBitURL="https://pkgsrc.joyent.com/packages/Darwin/bootstrap/bootstrap-2015Q2-i386.tar.gz"

# Specify name and location of the downloaded pkgsrc bootstrap kit

bootstrap_kit="/tmp/pkgsrc.tar.gz"

# Checks to see if the OS on the Mac is 10.x.x. If it is not, the 
# following message is displayed without quotes:
#
# "macOS 11 and later not supported."

if [[ ${osvers_major} -ne 10 ]]; then
  echo "macOS 11 and later not supported."
  exit 0
fi

# Checks to see if the OS on the Mac is earlier than Mac OS X 10.6.0.
# If it is, the following message is displayed without quotes:
#
# "pkgsrc is not available for this version of Mac OS X"

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 6 ]]; then
  echo "pkgsrc is not available for this version of Mac OS X"
  exit 0
fi

# Checks to see if the OS on the Mac is 10.8.x or earlier. 
# If it is, the 32-bit pkgsrc bootstrap kit is downloaded.

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 9 ]]; then
  myCurl --output "$bootstrap_kit" "$ThirtyTwoBitURL"
fi

# Checks to see if the OS on the Mac is 10.9.x or later. 
# If it is, the 64-bit pkgsrc bootstrap kit is downloaded.

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 9 ]]; then
  myCurl --output "$bootstrap_kit" "$SixtyFourBitURL"
fi

# Install pkgsrc bootstrap kit to /opt/pkg

if [[ -f "$bootstrap_kit" ]]; then
  /usr/bin/tar -zxpf "$bootstrap_kit" -C /
else
  echo "$bootstrap_kit not found."
fi

# Fetch the latest package repository information for pkgsrc

if [[ -d "/opt/pkg" ]]; then
  /opt/pkg/bin/pkgin -y update
fi

# Clean up by removing the downloaded pkgsrc bootstrap kit

if [[ -e "$bootstrap_kit" ]]; then
  rm -rf "$bootstrap_kit"
fi

exit 0