This script reads a .csv file formatted as follows:

`Serial number, Asset number` as the first line

Subsequent lines:

* Column 1: A Mac's serial number
* Column 2: An inventory asset code

Example:

```
Serial number, Asset number
W8810X481AX,1652
W89020U8289,1978
CK1243R4DB6,2011
```

This script is designed to run as shown below:

`/path/to/Jamf_Pro_Inventory_Asset_Tag_Update.sh filename_goes_here.csv`

Once executed, the script will then do the following:

* Skip the first line of the .csv file (this is the `Serial number, Asset number` line.)
* Read each subsequent line of the .csv one at a time and assign the values of column 1 and column 2 to separate variables.

Use the variables in an API PUT call to identify a Jamf Pro 
computer inventory record using the serial number listed in 
the .csv file and populate the asset tag information using
the inventory asset code listed in the .csv file.

Display HTTP return code and API output

Successful asset update should produce output similar to that shown below:

```
Successfully updated computer record with serial number W8810X481AX with asset number 1652
Successfully updated computer record with serial number W89020U8289 with asset number 1978
Successfully updated computer record with serial number CK1243R4DB6 with asset number 2011
```

If setting up a specific user account with limited rights, here are the required API privileges
for the account on the Jamf Pro server:

Jamf Pro Server Objects:

`Computers: Read, Update`