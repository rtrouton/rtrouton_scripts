This Jamf Pro Extension Attribute checks to see if Jamf Protect is installed and executable. 

If Jamf Protect is installed:

`/Library/Application Support/JamfProtect/JamfProtect.app` will be present.


If Jamf Protect is not installed::

`/Library/Application Support/JamfProtect/JamfProtect.app` will not be found.

If Jamf Protect is installed, the following message is displayed:

`1`

Otherwise, the following result is returned:

`0`

See `Jamf_Pro_Extension_Attribute_Setup.png` for a screenshot of how the Extension Attribute should be configured.

![Jamf_Pro_Extension_Attribute_Setup.png](Jamf_Pro_Extension_Attribute_Setup.png)
