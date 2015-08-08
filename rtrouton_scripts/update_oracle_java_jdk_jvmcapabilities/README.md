[Michael Lynn](https://twitter.com/mikeymikey) has developed a Python script for adding the
following options to Oracle's Java JDK:

`JNI`

`BundledApp`

When this script is run, it will update all of the Java JDKs stored in **/Library/Java/JavaVirtualMachines** with the options specified above by modifying the file below:

`/Library/Java/JavaVirtualMachines/jdk_version_info_goes_here.jdk/Contents/Info.plist`

[https://gist.github.com/pudquick/349f063c242239952a2e](https://gist.github.com/pudquick/349f063c242239952a2e)

I'm hosting a copy of this script for my own use. This script is also available as a payload-free installer package, stored as a .zip file in the **payload_free_installer** directory.

