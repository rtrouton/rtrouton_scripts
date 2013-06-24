#!/bin/sh

# Determines if either of the following 
# Java builds are installed: 
#
# 10.6.x: 1.6.0_51-b11-456-10M4508
# 10.7.x - 10.8.x: 1.6.0_51-b11-456-11M4508
#
# This builds were installed by the first versions of
# Java for OS X 2013-004 and Java for Mac OS X 10.6 Update 16 
# and can cause problems for Java Swing applications
# like MATLAB and Papercut.

JAVA_BUILD_CHECK=`java -version 2>&1 | awk '/4508/{print $NF}' | sed '$s/.$//'`
FOUND=`echo "Installed"`
NOT_FOUND=`echo "Not Found"`


if [ "$JAVA_BUILD_CHECK" = "1.6.0_51-b11-456-10M4508" ]; then
        result=$FOUND
elif [ "$JAVA_BUILD_CHECK" = "1.6.0_51-b11-456-11M4508" ]; then
        result=$FOUND
elif [ "$JAVA_BUILD_CHECK" = "" ]; then
        result=$NOT_FOUND
fi

# If either 1.6.0_51-b11-456-10M4508 or 1.6.0_51-b11-456-11M4508
# is installed, an "Installed" message is displayed.
#
# If neither 1.6.0_51-b11-456-10M4508 or 1.6.0_51-b11-456-11M4508
# is installed, a "Not Found" message is displayed.

echo "<result>$result</result>"
