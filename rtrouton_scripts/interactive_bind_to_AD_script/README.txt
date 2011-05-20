This script binds your 10.6.x Macs to Active Directory by asking you some questions, then using that information to bind the Mac to the correct OU in AD. The script will say "[Process Completed]" once it has completed the AD binding process. It is safe at that point to close that Terminal window.

As written, the script is an interactive .command file that asks you a series of questions and uses the information provided to bind the Mac to AD. All site-specific information has been removed, so you will need to edit the script to add your information. It is also designed for an AD structure where Mac laptops and desktops are bound to different OUs; if this does not meet your needs, edit as needed.

Script was modified from Mike Bombich's script for binding to 10.5.x:

http://www.afp548.com/netboot/mactips/files/scripts/ad-bind-login-leopard.sh

Source: http://www.afp548.com/netboot/mactips/scripts.html