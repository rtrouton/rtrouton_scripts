#!/bin/bash

# Disable the display of the Message of the Day (motd) 
# banner, which is  normally shown when opening a new 
# Terminal window, by adding a .hushlogin file to the
# logged-in user's home folder.

if [[ ! -f $HOME/.hushlogin ]]; then
   /usr/bin/touch "$HOME/.hushlogin"
fi