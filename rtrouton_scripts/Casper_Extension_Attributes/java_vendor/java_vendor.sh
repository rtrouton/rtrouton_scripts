#!/bin/bash

javaVendor=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Info CFBundleIdentifier`

if [ "$javaVendor" = "com.oracle.java.JavaAppletPlugin" ]; then
        result=Oracle
elif [ "$javaVendor" = "com.apple.java.JavaAppletPlugin" ]; then
        result=Apple
elif [ "$javaVendor" = "" ]; then
        result="No Java Plug-In Available"
fi

echo "<result>$result</result>"


