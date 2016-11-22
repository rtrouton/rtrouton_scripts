The EndNote 7 site license is stored in `/Applications/EndNote X7/.license.dat` and has a format that looks like this:

`Company Name`

`1234567890`

`V2ZMQT6556P8WMH38MTQ6YSM8UXCCRYQ5MDS4WJGLKMP7RGSWECBCMT77556P8WCE8KMTQ6YSMNXJCCRYQ59MD9WJGLKMCSESSWECBCMB76556P8WCU3NMTQ6YSMLUYCCRYQ5MET8WJGLKMPSMJSWECBCM57F556P8WCU3CMTQ6YSM9DECCRYQ59XSCWJGLKMPNE9SWECBCMB79556P8WCH8KMTQ6YSMDXECCRYQ5MTSMWJGLKMPYRMSWECBCB7W7556P8W`

To use this script, copy what’s in your existing site license file to the `endnote_license` value and add `\n` where you need line breaks.
The current `endnote_license` values correspond to the example above. 

Note: The `Company Name` value may show up twice in your `.license.dat` file. If it does, make sure to add it twice to the `endnote_license` value or your license may not work properly with Endnote.