Safari 6.0.4 and later (for Mac OS X 10.7.x and 10.8.x), and 5.1.9 and later (for Mac OS X 10.6.x) now prompts you to enable the Java browser plug-in on a website-by-website basis. When a Java applet is allowed, it is added to a whitelist in Safari.

Update - 10-22-2013: These scripts do not work to manage the Java whitelist on Safari 6.1 and higher. If you are using either of these scripts, please do not use them with Safari 6.1 or higher on Mountain Lion or Mavericks as they may cause Safari to crash.

safari_java_whitelist_firstboot - This script is designed to be a firstboot script. It sets the Safari Java whitelist settings in your Mac's default user template and for all existing users. Currently, it will add two servers to the Safari Java whitelist settings.

safari_set_java_whitelist_at_login - The script will add two servers to the Safari Java whitelist settings. If the servers are already in the whitelist, it will note that in the log, then exit.

To make this work, I’ve written a script and launch agent combination. The LaunchAgent runs the script on login to any user account with the logging-in user's privileges and permissions. 

Credit goes to @aurica (https://twitter.com/aurica) for figuring out the defaults commands that made these scripts work properly.

