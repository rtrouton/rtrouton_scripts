#!/usr/bin/python
import plistlib, os.path, os

# Based off of https://forums.developer.apple.com/message/6741
#          and http://apple.stackexchange.com/a/136976

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
    # Create a symlink to fix legacy applications
    # Find the Contents directory
    contents_path = os.path.dirname(info_plist)
    # make the bundle/Libraries subpath
    bundle_libraries = os.path.join(contents_path, "Home", "bundle", "Libraries")
    try:
        # Just in case you run this script multiple times, we'll fail if the directory already exists
        os.makedirs(os.path.join(bundle_libraries))
    except:
        pass
    # create the symlink between libjvm.dylib and libserver.dylib
    libjvm_dylib = os.path.join(contents_path, "Home", "jre", "lib", "server", "libjvm.dylib")
    libserver_dylib = os.path.join(bundle_libraries, "libserver.dylib")
    try:
        # Just in case you run this script multiple times, we'll fail if the file already exists
        os.symlink(libjvm_dylib, libserver_dylib)
    except:
        pass
