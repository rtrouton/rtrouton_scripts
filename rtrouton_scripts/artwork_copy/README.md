When building a presentation in Keynote, I often use Apple's icons and other images included in the OS to illustrate my slides. This is because Apple's already done a lot of work creating high-res images for OS X and it's often helpful to use Apple's own artwork when illustrating how something works. However, this artwork can also be hard to find as it can be buried deep within applications and other resource files. 

To help me get this artwork all together in one place, I've developed this script to search OS X for icons and other relevant images in various file formats, copy them when found, then organize the copied artwork.

This script uses [find](https://en.wikipedia.org/wiki/Find) to examine the following two directories: 

**/Applications**

**/System/Library**

It searches for files stored in these formats:

[icns](https://en.wikipedia.org/wiki/Apple_Icon_Image_format)

[pdf](https://en.wikipedia.org/wiki/Portable_Document_Format)

[png](https://en.wikipedia.org/wiki/Portable_Network_Graphics)

Once matching files are located, they are copied to a folder in **/tmp**. Once the script has completed its run, it will notify you and display the location of the folder in **/tmp** with the copied artwork. The folder in **/tmp** will have the files sorted by file type, then by the location (**Applications** or **System**) from which the images were copied.

This script should be able to run without needing root privileges. Since it's designed to dig around inside the **/System** directory, I'd recommend running it without root privileges to avoid any potential issues.