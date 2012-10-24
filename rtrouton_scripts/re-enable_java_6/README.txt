Once the Java for OS X 2012-006 update has been installed, the Apple-provided Java applet plug-in from /Library/Internet Plug-Ins is removed, which means that web browsers will not be able to launch Java applets from inside the browser. The update also removes the Java Preferences application from /Applications/Utilities. 

However, the rest of the Java 6 framework is still installed and it is possible to re-enable the Apple-provided Java plug-in and browser functionality. Apple has provided a KBase article showing how to do this process manually:

http://support.apple.com/kb/HT5559

This  script that automates the process of removing the Oracle Java 7 plug-in and replace it with the Apple-built Java 6 plug-in.