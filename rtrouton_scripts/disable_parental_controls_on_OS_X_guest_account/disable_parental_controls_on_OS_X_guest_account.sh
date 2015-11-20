#!/bin/bash

# By default, OS X's Guest account will have Parental Controls
# management applied to it, even if Parental Controls is not 
# configured. The command below will disable the Parental Controls
# management for the Guest account.

/usr/bin/dscl . -mcxdelete /Users/Guest