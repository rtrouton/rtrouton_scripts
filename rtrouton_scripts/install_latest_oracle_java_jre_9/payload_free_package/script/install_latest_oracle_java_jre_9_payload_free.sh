#!/bin/bash

# This script downloads and installs the latest available Oracle Java 9 JRE CPU release or PSU release for compatible Macs

# Set error status

error=0

# Determine OS version

osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

IdentifyLatestJRERelease(){

# Determine the download URL for the latest CPU release or PSU release.

Java_9_JRE_CPU_URL=$(/usr/bin/curl -s http://www.oracle.com/technetwork/java/javase/downloads/jre9-downloads-3848532.html | grep -ioE "http://download.oracle.com/otn-pub/java/jdk/.*?/jre-9.*?.dmg" | head -1)

Java_9_JRE_PSU_URL=$(/usr/bin/curl -s http://www.oracle.com/technetwork/java/javase/downloads/jre9-downloads-3848532.html | grep -ioE "http://download.oracle.com/otn-pub/java/jdk/.*?/jre-9.*?.dmg" | tail -1)

# Use the Version variable to determine if the script should install the latest CPU release or PSU release.

 if [[ "$Version" = "PSU" ]] && [[ "$Java_9_JRE_PSU_URL" != "" ]]; then
    fileURL="$Java_9_JRE_PSU_URL"
    echo "Installing Oracle Java 9 JRE Patch Set Update (PSU) -" "$Java_9_JRE_PSU_URL"
 elif [[ "$Version" = "PSU" ]] && [[ "$Java_9_JRE_PSU_URL" = "" ]]; then
     echo "Unable to identify download URL for requested Oracle Java 9 JRE Patch Set Update (PSU). Exiting."
     error=1
     exit "$error"
 fi

 if [[ "$Version" = "CPU" ]] && [[ "$Java_9_JRE_CPU_URL" != "" ]]; then
    fileURL="$Java_9_JRE_CPU_URL"
    echo "Installing Oracle Java 9 JRE Critical Patch Update (CPU) -" "$Java_9_JRE_PSU_URL"
 elif [[ "$Version" = "CPU" ]] && [[ "$Java_9_JRE_CPU_URL" = "" ]]; then
    echo "Unable to identify download URL for requested Oracle Java 9 JRE Critical Patch Update (CPU). Exiting."
    error=1
    exit "$error"
 fi

}

if [[ ${osvers} -lt 10 ]]; then
  echo "Oracle Java 9 JRE is not available for Mac OS X 10.9.5 or earlier."
fi

if [[ ${osvers} -ge 10 ]]; then

    # Specify name of downloaded disk image

    java_nine_jre_dmg="/tmp/java_nine_jre.dmg"



    # Use the Version variable to set if you want to download the latest CPU release or the latest PSU release.
    # The difference between CPU and PSU releases is as follows:
    #
    # Critical Patch Update (CPU): contains both fixes to security vulnerabilities and critical bug fixes.
    #
    # Patch Set Update (PSU): contains all the fixes in the corresponding CPU, plus additional fixes to non-critical problems.
    #
    # For more details on the differences between CPU and PSU updates, please see the link below:
    #
    # http://www.oracle.com/technetwork/java/javase/cpu-psu-explained-2331472.html
    #
    # Setting the variable as shown below will set the script to install the CPU release:
    #
    # Version=CPU
    #
    # Setting the variable as shown below will set the script to install the PSU release:
    #
    # Version=PSU
    #
    # By default, the script is set to install the CPU release.

    Version=CPU

    # Identify the URL of the latest Oracle Java 9 JRE software disk image
    # using the IdentifyLatestJRERelease function.

    IdentifyLatestJRERelease

    # Download the latest Oracle Java 9 JRE software disk image
    # The curl -L option is needed because there is a redirect
    # that the requested page has moved to a different location.

    /usr/bin/curl --retry 3 -Lo "$java_nine_jre_dmg" "$fileURL" -H "Cookie: oraclelicense=accept-securebackup-cookie"

    # Specify a /tmp/java_nine_jre.XXXX mountpoint for the disk image

    TMPMOUNT="$(/usr/bin/mktemp -d "$3"/tmp/java_nine_jre.XXXX)"

    # Mount the latest Oracle Java 9 disk image to /tmp/java_nine_jre.XXXX mountpoint

    hdiutil attach "$java_nine_jre_dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen

    # Install Oracle Java 9 JRE from the installer package. This installer may
    # be stored inside an install application on the disk image, or there
    # may be an installer package available at the root of the mounted disk
    # image.

    if [[ -e "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*Java*\.pkg -o -iname \*Java*\.mpkg \))" ]]; then
      pkg_path="$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*Java*\.pkg -o -iname \*Java*\.mpkg \))"
    elif [[ -e "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.app \))" ]]; then
         oracle_app=$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.app \))
        if [[ -e "$(/usr/bin/find "$oracle_app"/Contents/Resources -maxdepth 1 \( -iname \*Java*\.pkg -o -iname \*Java*\.mpkg \))" ]]; then
          pkg_path="$(/usr/bin/find "$oracle_app"/Contents/Resources -maxdepth 1 \( -iname \*Java*\.pkg -o -iname \*Java*\.mpkg \))"
        fi
    fi

    # Before installation, the installer's developer certificate is checked to
    # see if it has been signed by Oracle's developer certificate. Once the
    # certificate check has been passed, the package is then installed.

    if [[ "${pkg_path}" != "" ]]; then
        signature_check=$(/usr/sbin/pkgutil --check-signature "$pkg_path" | awk /'Developer ID Installer/{ print $5 }')
           if [[ ${signature_check} = "Oracle" ]]; then
             echo "The downloaded Oracle Java 9 JRE installer package is signed by Oracle's Developer ID Installer certificate."
             echo "Proceeding with installation of the latest Oracle Java 9 JRE."
             # Install Oracle Java 9 JRE from the installer package stored inside the disk image
             /usr/sbin/installer -dumplog -verbose -pkg "${pkg_path}" -target "$3"

             # Report on the currently installed version of the Oracle Java 9 JRE
             javaJREVersion=$(/usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleVersion)
             echo "Oracle Java 9 JRE $javaJREVersion has been installed."

           fi
    fi

    # Clean-up

    # Unmount the Oracle Java 9 JRE disk image from /tmp/java_nine_jre.XXXX

    /usr/bin/hdiutil detach -force "$TMPMOUNT"

    # Remove the /tmp/java_nine_jre.XXXX mountpoint

    /bin/rm -rf "$TMPMOUNT"

    # Remove the downloaded disk image

    /bin/rm -rf "$java_nine_jre_dmg"
fi

exit "$error"