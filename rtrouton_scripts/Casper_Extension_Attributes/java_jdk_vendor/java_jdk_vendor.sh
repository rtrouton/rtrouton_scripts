#!/bin/bash

# This extension attribute verifies if a Java JDK is installed. 
# Once the presence of an installed JDK has been 
# verified by checking java_home, the JDK is checked
# for the vendor information. The EA will return one of
# the following values:
#
# None
# AdoptOpenJDK
# Amazon
# Apple
# Azul
# OpenJDK
# Oracle
# SAP
# Unknown
# 
#
# None = No Java JDK is installed.
# AdoptOpenJDK = AdoptOpenJDK is the Java JDK vendor.
# Amazon = Amazon is the Java JDK vendor.
# Apple = Apple is the Java JDK vendor.
# Azul = Azul is the Java JDK vendor.
# OpenJDK = OpenJDK is the Java JDK vendor.
# Oracle = Oracle is the Java JDK vendor.
# SAP = SAP is the Java JDK vendor.
# Unknown = There is a Java JDK installed, but it is not from one of the listed vendors.
   
jdk_installed=$(/usr/libexec/java_home 2>/dev/null)
result=None

if [[ -n "$jdk_installed" ]]; then

   # If an installed JDK is detected, check to see if it's from a known vendor.

   javaJDKVendor=$(defaults read "${jdk_installed%/*}/Info" CFBundleIdentifier | grep -Eo "adoptopenjdk|amazon|apple|azul|openjdk|oracle|sap" | head -1)
   
   if [[ "$javaJDKVendor" = "adoptopenjdk" ]]; then
        result="AdoptOpenJDK"
   elif [[ "$javaJDKVendor" = "amazon" ]]; then
        result="Amazon"
   elif [[ "$javaJDKVendor" = "apple" ]]; then
        result="Apple"
   elif [[ "$javaJDKVendor" = "azul" ]]; then
        result="Azul"
   elif [[ "$javaJDKVendor" = "openjdk" ]]; then
        result="OpenJDK"
   elif [[ "$javaJDKVendor" = "oracle" ]]; then
        result="Oracle"
   elif [[ "$javaJDKVendor" = "sap" ]]; then
        result="SAP"
   else
        result="Unknown"
   fi   
fi

echo "<result>$result</result>"

exit 0