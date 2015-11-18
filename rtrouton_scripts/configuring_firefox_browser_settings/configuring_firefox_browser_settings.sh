#!/bin/bash

# Identify the logged-in user

loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

if [[ $loggedInUser == "Guest" ]]; then
  
  # Identify the location of an existing Firefox browser profile's prefs.js file

  firefox_prefs="`/bin/echo $HOME/Library/Application\ Support/Firefox/Profiles/*.default*/prefs.js`"
  
  # Specify the desired homepage setting for Firefox

  firefox_homepage="http://homepage.address.here"

  # If an existing Firefox browser profile's prefs.js file is located, the following settings are applied:
  #
  # * Homepage is set to whatever is set in the $firefox_homepage variable
  # * Firefox's update mechanism is set to be disabled
  # * Firefox's default browser check is disabled

  if [[ -f "${firefox_prefs}" ]]; then
	 echo "user_pref(\"browser.shell.checkDefaultBrowser\", false);" >> "$HOME/Library/Application Support/Firefox/Profiles"/*.default*/prefs.js
	 echo "user_pref(\"app.update.enabled\", false);" >> "$HOME/Library/Application Support/Firefox/Profiles"/*.default*/prefs.js
	 echo "user_pref(\"app.update.auto\", false);" >> "$HOME/Library/Application Support/Firefox/Profiles"/*.default*/prefs.js
	 echo "user_pref(\"browser.startup.homepage\", \"$firefox_homepage\");" >> "$HOME/Library/Application Support/Firefox/Profiles"/*.default*/prefs.js
  fi

fi