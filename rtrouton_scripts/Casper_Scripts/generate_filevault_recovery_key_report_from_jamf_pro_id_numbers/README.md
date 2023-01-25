This script imports a list of Jamf Pro ID numbers from a plaintext file and uses that information to generate a report about the matching computers' FileVault personal recovery keys.

Usage: `/path/to/generate_filevault_recovery_key_report_from_jamf_pro_id_numbers.sh /path/to/jamf_pro_id_numbers.txt`

Once the Jamf Pro ID numbers are read from in from the plaintext file, the script takes the following actions:

1. Uses the Jamf Pro API to download all information about the matching computer inventory record in XML format.
2. Pulls the following information out of the inventory entry:

*    Manufacturer
*    Model
*    Serial Number
*    Hardware UDID

3. Runs a separate API call to retrieve the following in JSON format.

* FileVault personal recovery key

4. Create a report in tab-separated value (.tsv) format which contains the following information
   about the computers.

*    Jamf Pro ID
*    Manufacturer
*    Model
*    Serial Number
*    Hardware UDID
*    FileVault recovery key if available
*    Jamf Pro URL for the computer inventory record

```
Jamf Pro ID Number	Make	Model	Serial Number	UDID	FileVault Recovery Key Available	FileVault Recovery Key	Jamf Pro URL
13	Apple	Mac mini (Mid 2011)	C07GM01TDJD0	00BC7701-6791-573D-B461-470B44D16DF6	No	NA	https://jamfpro.pretendco.com:8443/computers.html?id=13
86	Apple	iMac Pro Intel (Retina 5k, 27-inch, Late 2017)	VM0N0WRc4EjC	564D33BC-AF4C-86CF-1DFB-AF6EDFC395A3	Yes	3CZZ-OB8K-HXCF-5O3D-ZPQR-AFP2	https://jamfpro.pretendco.com:8443/computers.html?id=86
87	Apple	iMac Pro Intel (Retina 5k, 27-inch, Late 2017)	VMWmmR2FJqk3	564D4A6F-280F-1EC0-5E66-178DB2D45A8A	Yes	KGPW-DE8Q-ACHK-OCHX-CG52-JNHT	https://jamfpro.pretendco.com:8443/computers.html?id=87
85	Apple	VMware Virtual Platform	VMD4TkB2CNtn	564D6125-8B99-47F1-9867-F92CD80BF0C9	Yes	TLFA-PEUM-6G5W-4MBF-XG7U-BL24	https://jamfpro.pretendco.com:8443/computers.html?id=85
```
