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

`/path/to/Jamf_Pro_MDM_Device_Lock.sh /path/to/filename_goes_here.csv`

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


This script will also generate a report in .tsv format with information similar to what's shown below:

|Jamf Pro ID Number|Make |Model                      |Serial Number|UDID                                |Jamf Pro URL                                             |MDM Lock Successful|
|------------------|-----|---------------------------|-------------|------------------------------------|---------------------------------------------------------|-------------------|
|10734             |Apple|MacBook Pro (13-inch, 2018)|C02TW0WAHX874 |C66B7C82-9CAB-4C89-85BE-7271121592A8|https://jamf.pro.server.here/computers.html?id=10734|Yes                |
|858             |Apple|MacBook Pro (13-inch, 2018)|C027251024N23 |159C6524-5069-41EC-9EDE-81158843F2EC|https://jamf.pro.server.here/computers.html?id=858|No                |
|421             |Apple|MacBook Pro (13-inch, 2018)|Q027251024R23 |A5C73F1F-35BD-4E27-BE63-E5760F886A1A|https://jamf.pro.server.here/computers.html?id=421|Yes                |
|1217             |Apple|MacBook Pro (13-inch, 2018)|C02F0U5WAHX54 |D59F50C3-3559-4B6A-AE04-81FF6BF25349|https://jamf.pro.server.here/computers.html?id=1217|Yes                |



If setting up a specific user account with limited rights, here are the required API privileges
for the account on the Jamf Pro server:

**Jamf Pro Server Objects**:

`Computers: Create, Read`

**Jamf Pro Server Action**:

`Send Computer Remote Lock Command`