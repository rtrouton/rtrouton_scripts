This script reads a .csv file formatted as follows:

"Jamf Pro ID, PIN Code" as the first line

Subsequent lines:
Column 1: A Mac's Jamf Pro ID
Column 2: Device Lock PIN code

Example:


|Jamf Pro ID|PIN Code|
|-----------|--------|
|26         |165234  |
|52         |197898  |
|1226       |201145  |

This script is designed to run as shown below:

`/path/to/Jamf_Pro_MDM_Device_Lock.sh filename_goes_here.csv`

Once executed, the script will then do the following:

Skip the first line of the .csv file (this is the "Jamf Pro ID, PIN Code" line.)
Read each subsequent line of the .csv one at a time and assign the values of column 1
and column 2 to separate variables.

Use the variables in an API PUT call to identify a Jamf Pro computer inventory record
using the Jamf Pro ID listed in the .csv file and lock the Mac in question using the 
the PIN code listed in the .csv file.

A successful MDM lock should produce output similar to that shown below:

``Attempting to send MDM lock to Jamf Pro ID 2935 with PIN code 348202.``
``<?xml version="1.0" encoding="UTF-8"?><computer_command><command><name>DeviceLock</name><command_uuid>98d915a4-6132-4535-b474-c8381e48425a</command_uuid><computer_id>2935</computer_id></command></computer_command>``
``Successfully locked computer with Jamf Pro ID 1925 with PIN code 348202.``

Failures should look similar to this:

``Attempting to send MDM lock to Jamf Pro ID 1234567890 with PIN code 348201.``

``ERROR! MDM lock of computer with Jamf Pro ID 1234567890 failed.``

``Attempting to send MDM lock to Jamf Pro ID 29352935 with PIN code 12345.``

``Invalid PIN code data provided: 12345``

``Attempting to send MDM lock to Jamf Pro ID AA2319 with PIN code 348206.``

``Invalid Jamf Pro ID data provided: AA2319``

If setting up a specific user account with limited rights, here are the required API privileges
for the account on the Jamf Pro server:

**Jamf Pro Server Objects**:

`Computers: Create`

**Jamf Pro Server Action**:

`Send Computer Remote Lock Command`