#!/bin/bash

# Installing the Xcode command line tools on 10.7.x or higher

osx_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')
cmd_line_tools_temp_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"

# Installing the latest Xcode command line tools on 10.9.x or higher

if [[ "$osx_vers" -ge 9 ]]; then

	# Create the placeholder file which is checked by the softwareupdate tool 
	# before allowing the installation of the Xcode command line tools.
	
	touch "$cmd_line_tools_temp_file"
	
	# Find the first listed update in the Software Update feed with "Command Line Tools" in the name
	
	cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | head -n 1 | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)
	
	#Install the command line tools
	
	softwareupdate -i "$cmd_line_tools" --verbose
	
	# Remove the temp file
	
	if [[ -f "$cmd_line_tools_temp_file" ]]; then
	  rm "$cmd_line_tools_temp_file"
	fi
fi

# Installing the latest Xcode command line tools on 10.7.x and 10.8.x

# on 10.7/10.8, instead of using the software update feed, the command line tools are downloaded
# instead from public download URLs, which can be found in the dvtdownloadableindex:
# https://devimages.apple.com.edgekey.net/downloads/xcode/simulators/index-3905972D-B609-49CE-8D06-51ADC78E07BC.dvtdownloadableindex

if [[ "$osx_vers" -eq 7 ]] || [[ "$osx_vers" -eq 8 ]]; then

	if [[ "$osx_vers" -eq 7 ]]; then
	    DMGURL=http://devimages.apple.com/downloads/xcode/command_line_tools_for_xcode_os_x_lion_april_2013.dmg
	fi
	
	if [[ "$osx_vers" -eq 8 ]]; then
	     DMGURL=http://devimages.apple.com/downloads/xcode/command_line_tools_for_osx_mountain_lion_april_2014.dmg
	fi

		TOOLS=cltools.dmg
		curl "$DMGURL" -o "$TOOLS"
		TMPMOUNT=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
		hdiutil attach "$TOOLS" -mountpoint "$TMPMOUNT" -nobrowse
		# The "-allowUntrusted" flag has been added to the installer
		# command to accomodate for now-expired certificates used
		# to sign the downloaded command line tools.
		installer -allowUntrusted -pkg "$(find $TMPMOUNT -name '*.mpkg')" -target /
		hdiutil detach "$TMPMOUNT"
		rm -rf "$TMPMOUNT"
		rm "$TOOLS"
fi

exit 0
