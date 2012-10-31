#!/bin/bash

# Christoph von Gabler-Sahm (christoph.gabler-sahm@computacenter.com)
# Version 1.0

# checks installed version of Java Applet Plugin
# returns values like "Not installed", "JavaInstallOnDemand: 14.5.0", "JavaJDK16: 14.5.0" or "Java 7 Update 09"

PLUGINPATH="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"

# Plugin version
S_VERSION=$( /usr/bin/defaults read "${PLUGINPATH}/Contents/Info" CFBundleShortVersionString 2>/dev/null )

# JavaInstallOnDemand or empty
S_PROJECT=$( /usr/bin/defaults read "${PLUGINPATH}/Contents/version" ProjectName 2>/dev/null )

if [[ -e "${PLUGINPATH}" ]]; then
    if [[ "${S_PROJECT}" == "" ]]; then
        EA_RESULT="${S_VERSION}"
    else
        EA_RESULT="${S_PROJECT}: ${S_VERSION}"
    fi
else
    EA_RESULT="Not installed"
fi

echo "<result>${EA_RESULT}</result>"
