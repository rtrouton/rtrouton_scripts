The **setup_osx_server_dot_app** script is designed to automate the setup of OS X Server 5.0.3 and later by using the **server** command line tool within **/Applications/Server.app** to run the initial setup and configuration of OS X Server's services.

When launched, the script will check for the existence of the **server** setup tool. If the **server** setup tool is not located where the script expects it to be, the script will exit. 

If the **server** setup tool is located in the expected location, the script will proceed with the following actions:

1. Create a temporary user with a randomly generated password
2. Give the temporary user admin privileges
3. Run the initial setup and configuration of OS X Server's services.
4. Delete the temporary user

As part of OS X Server's initial setup process, the script will:

A. Agree to the OS X Server license

B. Authorize the setup process using the temporary user's username and password

The script is also available for download as a payload-free package. This payload-free package is located in the **payload-free** directory and is compressed inside a .zip file.
