There is a compatibility issue preventing the Java 7 runtime from launching on OS X platforms lacking hardware-accelerated OpenGL support, including OS X VMware virtual machines running on Fusion and ESXi.
 
This script from VMWare applies a binary patch to liblwawt.dylib in the Java 7 Runtime Environment for Mac OS (the JRE) to address this specific problem.

System requirements: OS X 10.8 VM on VMware Fusion or ESXi, with Java 7 installed in the VM. Does not work for OS X 10.7.x VMs

Link: http://communities.vmware.com/docs/DOC-22830
Forum discussion: http://communities.vmware.com/message/2222053

I've also built a payload-free package that applies this script, allowing it to be applied as part of an automated build process for VMWare Fusion VMs.