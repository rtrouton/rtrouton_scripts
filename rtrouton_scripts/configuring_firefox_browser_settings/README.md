This script is an example of how Firefox browser settings may be configured from OS X's command line. In this example, the script is checking to see if the logged-in user is OS X's **Guest** user account. If the **Guest** user account is logged in, running the script as the **Guest** user will set the following settings in an existing Firefox browser profile:

* Homepage is set to whatever is set in the script's **$firefox_homepage** variable
* Firefox's update mechanism is set to be disabled
* Firefox's default browser check is disabled