Script for use with Casper's Self Service when deploying printers. Script uses a printer queue name (set as **Parameter 4** in the script's parameter list in the JSS) to specify which printer queue should have printer sharing disabled.

You can get the print queue name by verifying that the the printer has been added and then running the following command:

**lpstat -p**