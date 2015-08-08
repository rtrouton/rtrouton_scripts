#!/usr/bin/python
import plistlib, os.path

# Based off of https://forums.developer.apple.com/message/6741

def jdk_info_plists():
    # Find all the JDK Info.plist files
    JDK_ROOT = "/Library/Java/JavaVirtualMachines"
    if (os.path.exists(JDK_ROOT) and os.path.isdir(JDK_ROOT)):
        # It's present, let's look for installs
        for file in os.listdir(JDK_ROOT):
            jdk_dir = os.path.join(JDK_ROOT, file)
            if (os.path.isdir(jdk_dir)):
                # Check for Info.plist
                info_plist = os.path.join(jdk_dir, "Contents", "Info.plist")
                if (os.path.isfile(info_plist)):
                    yield info_plist

for info_plist in jdk_info_plists():
    # Change all the plists of all the installed JDKs
    info = plistlib.readPlist(info_plist)
    # Convert the capabilities into a set
    capabilities = set(info['JavaVM']['JVMCapabilities'])
    capabilities.add('JNI')
    capabilities.add('BundledApp')
    # Update our changes
    info['JavaVM']['JVMCapabilities'] = sorted(capabilities)
    # Write back our changes
    plistlib.writePlist(info, info_plist)
