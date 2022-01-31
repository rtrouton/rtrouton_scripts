#!/bin/bash

# Installing the Xcode command line tools on 10.7.x or higher

ignoreBeta="true"	# Setting to true will ignore beta. However, setting to false does not guarantee a beta is available.

# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

cmd_line_tools_temp_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"

# Installing the latest Xcode command line tools on 10.9.x or higher

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 9 ) || ( ${osvers_major} -ge 11 && ${osvers_minor} -ge 0 ) ]]; then

	# Create the placeholder file which is checked by the softwareupdate tool 
	# before allowing the installation of the Xcode command line tools.
	
	/usr/bin/touch "$cmd_line_tools_temp_file"
	
	# Identify the correct update in the Software Update feed with "Command Line Tools" in the name for the OS version in question.

	if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 15 ) || ( ${osvers_major} -ge 11 && ${osvers_minor} -ge 0 ) ]]; then
	   cmd_line_tools=$(/usr/sbin/softwareupdate -l | /usr/bin/awk '/\*\ Label: Command Line Tools/ { $1=$1;print }' | /usr/bin/sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | /usr/bin/cut -c 9-)	
	elif [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -gt 9 ) ]] && [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 15 ) ]]; then
	   cmd_line_tools=$(/usr/sbin/softwareupdate -l | /usr/bin/awk '/\*\ Command Line Tools/ { $1=$1;print }' | /usr/bin/grep "$osvers_minor" | /usr/bin/sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | /usr/bin/cut -c 2-)
	elif [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 9 ) ]]; then
	   cmd_line_tools=$(/usr/sbin/softwareupdate -l | /usr/bin/awk '/\*\ Command Line Tools/ { $1=$1;print }' | /usr/bin/grep "Mavericks" | /usr/bin/sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | /usr/bin/cut -c 2-)
	fi
	
	# Check to see if the softwareupdate tool has returned more than one Xcode
	# command line tool installation option. If it has, use the last one listed
	# as that should be the latest Xcode command line tool installer.
	
	if (( $(/usr/bin/grep -c . <<<"$cmd_line_tools") > 1 )); then
		cmd_line_tools_output="$cmd_line_tools"

		if [[ "$ignoreBeta" == "true" ]]; then
			cmd_line_tools=$(printf "%s\n" "$cmd_line_tools_output" | /usr/bin/grep -iv beta | /usr/bin/tail -1)
		else
			cmd_line_tools=$(printf "%s\n" "$cmd_line_tools_output" | /usr/bin/tail -1)
		fi
	fi
	
	#Install the command line tools
	
	/usr/sbin/softwareupdate -i "$cmd_line_tools" --verbose
	
	# Remove the temp file
	
	if [[ -f "$cmd_line_tools_temp_file" ]]; then
	  /bin/rm "$cmd_line_tools_temp_file"
	fi
fi

# Installing the latest Xcode command line tools on 10.7.x and 10.8.x

# on 10.7/10.8, instead of using the software update feed, the command line tools are downloaded
# instead from public download URLs, which can be found in the dvtdownloadableindex:
# https://devimages.apple.com.edgekey.net/downloads/xcode/simulators/index-3905972D-B609-49CE-8D06-51ADC78E07BC.dvtdownloadableindex

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 7 ) || ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 8 ) ]]; then

	if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 7 ) ]]; then	
	    DMGURL=http://devimages.apple.com/downloads/xcode/command_line_tools_for_xcode_os_x_lion_april_2013.dmg
	fi
	
	if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 8 ) ]]; then
	     DMGURL=http://devimages.apple.com/downloads/xcode/command_line_tools_for_osx_mountain_lion_april_2014.dmg
	fi

		TOOLS=cltools.dmg
		/usr/bin/curl "$DMGURL" -o "$TOOLS"
		TMPMOUNT=`/usr/bin/mktemp -d /tmp/clitools.XXXX`
		/usr/bin/hdiutil attach "$TOOLS" -mountpoint "$TMPMOUNT" -nobrowse
		# The "-allowUntrusted" flag has been added to the installer
		# command to accomodate for now-expired certificates used
		# to sign the downloaded command line tools.
		/usr/sbin/installer -allowUntrusted -pkg "$(/usr/bin/find $TMPMOUNT -name '*.mpkg')" -target /
		/usr/bin/hdiutil detach "$TMPMOUNT"
		/bin/rm -rf "$TMPMOUNT"
		/bin/rm "$TOOLS"
fi

exit 0
