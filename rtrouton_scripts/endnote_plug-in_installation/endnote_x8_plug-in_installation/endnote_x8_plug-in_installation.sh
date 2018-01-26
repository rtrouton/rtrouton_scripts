#!/bin/bash


#################################################################
##         Remove previous Endnote plug-ins from Office 2016   ##
#################################################################

if [[ -e "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word/EndNote CWYW Word 2016.bundle" ]]; then
   /bin/rm -rf "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word/EndNote CWYW Word 2016.bundle"
elif [[ -e "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word/EndNote CWYW Word 16.bundle" ]]; then
   /bin/rm -rf "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word/EndNote CWYW Word 16.bundle"
fi

#################################################################
##         Remove previous Endnote plug-ins from Office 2011   ##
#################################################################

if [[ -e "/Applications/Microsoft Office 2011/Office/Startup/Word/EndNote CWYW Word 2011.bundle" ]]; then
   /bin/rm -rf "/Applications/Microsoft Office 2011/Office/Startup/Word/EndNote CWYW Word 2011.bundle"
fi

#################################################################
##         Remove previous Endnote plug-ins from Office 2008   ##
#################################################################

if [[ -e "/Applications/Microsoft Office 2008/Office/Startup/Word/EndNote CWYW Word 2008.bundle" ]]; then
   /bin/rm -rf "/Applications/Microsoft Office 2008/Office/Startup/Word/EndNote CWYW Word 2008.bundle"
fi

###################################################################################################################
##    This checks for and creates if needed the directories for the Endnote X8 Plug-in for Office 2016           ##
###################################################################################################################

if [[ -e "/Applications/Microsoft Word.app" ]] && [[ ! -e "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word" ]]; then
   /bin/echo "Microsoft Word 2016 detected. Necessary support directories for Endnote X8 Cite While You Write plug-ins for Word 2016 not found."
   /bin/mkdir -p "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word"
   /usr/sbin/chown root:admin "/Library/Application Support/Microsoft" && /bin/chmod 775 "/Library/Application Support/Microsoft"
   /usr/sbin/chown root:admin "/Library/Application Support/Microsoft/Office365" && /bin/chmod 775 "/Library/Application Support/Microsoft/Office365"
   /usr/sbin/chown root:admin "/Library/Application Support/Microsoft/Office365/User Content.localized" && /bin/chmod 775 "/Library/Application Support/Microsoft/Office365/User Content.localized"
   /usr/sbin/chown root:admin "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized" && /bin/chmod 775 "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized"
   /usr/sbin/chown root:admin "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word" && /bin/chmod 775 "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word"
   /bin/echo "Creating necessary support directories for Endnote X8 Cite While You Write plug-ins for Word 2016."
fi

###########################################################################################################################
##    This checks for if the version of Office 2016 is 15.x or 16.x, as Endnote has different Word Plug-ins for each     ##
###########################################################################################################################

if [[ -e "/Applications/Microsoft Word.app" ]]; then
   WordVersion=$(/usr/bin/defaults read "/Applications/Microsoft Word.app/Contents/Info" CFBundleShortVersionString | awk -F. '{print $1}')
fi

########################################################################
##    This re-copies the Endnote X8 Plug-in for Office 2016          ##
########################################################################

if [[ -e "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word/" ]]; then
   if [[ "$WordVersion" = 15 ]] && [[ -e "/Applications/EndNote X8/Cite While You Write/EndNote CWYW Word 2016.bundle" ]]; then
       /usr/bin/ditto "/Applications/EndNote X8/Cite While You Write/EndNote CWYW Word 2016.bundle"  "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word/EndNote CWYW Word 2016.bundle"
   elif [[ "$WordVersion" = 16 ]] && [[ -e "/Applications/EndNote X8/Cite While You Write/EndNote CWYW Word 16.bundle" ]]; then
       /usr/bin/ditto "/Applications/EndNote X8/Cite While You Write/EndNote CWYW Word 16.bundle"  "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word/EndNote CWYW Word 16.bundle"
   fi
   /usr/sbin/chown -R root:admin "/Library/Application Support/Microsoft/Office365/User Content.localized/Startup.localized/Word"
   /bin/echo "Copying Endnote X8 Cite While You Write plug-ins for Word 2016."
fi

########################################################################
##    This re-copies the Endnote X8 Plug-in for Office 2011           ##
########################################################################

if [[ -e "/Applications/Microsoft Office 2011/Office/Startup/Word" ]]; then
   /usr/bin/ditto "/Applications/EndNote X8/Cite While You Write/EndNote CWYW Word 2011.bundle"  "/Applications/Microsoft Office 2011/Office/Startup/Word/EndNote CWYW Word 2011.bundle"
   /usr/sbin/chown -R root:admin "/Applications/Microsoft Office 2011/Office/Startup/Word"
   /bin/echo "Copying Endnote X8 Cite While You Write plug-ins for Word 2011."
fi


########################################################################
##    This re-copies the Endnote X8 Plug-in for Office 2008           ##
########################################################################

if [[ -e "/Applications/Microsoft Office 2008/Office/Startup/Word" ]]; then
   /usr/bin/ditto "/Applications/EndNote X8/Cite While You Write/EndNote CWYW Word 2008.bundle"  "/Applications/Microsoft Office 2008/Office/Startup/Word/EndNote CWYW Word 2008.bundle"
   /usr/sbin/chown -R root:admin "/Applications/Microsoft Office 2008/Office/Startup/Word"
   /bin/echo "Copying Endnote X8 Cite While You Write plug-ins for Word 2008."
fi