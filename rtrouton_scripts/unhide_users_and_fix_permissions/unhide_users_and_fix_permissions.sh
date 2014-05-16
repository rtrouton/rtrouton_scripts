#!/bin/bash

# Detects if /Users is present
# If /Users is present, the 
# chflags command will unhide it

if [[ -d "/Users" ]]; then
   chflags nohidden "/Users"
fi

# Detects if /Users/Shared is present
# If /Users/Shared is present, the
# chflags command will unhide it

if [[ -d "/Users/Shared" ]]; then
   chflags nohidden "/Users/Shared"
fi

# Runs a permissions repair to fix     
# the world-writable permission on 
# /Users

diskutil repairPermissions "/"

exit 0