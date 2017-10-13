# FileVault Encryption
**Extension Attribute to check FileVault 2 Encryption status**

Original author: Rich Trouton  
Refactoring and update for 10.12+ and APFS: Bartłomiej Sojka

The script checks to see if a Mac is running 10.7 or higher and if it is, reports on whether or not it is encrypted with Apple's FileVault 2 encryption and gives the encryption or decryption status.

Available states are:
- Unknown version of Mac OS X
- Unrecognised file system
- Not available
- Not enabled
- In progress, including:  
In progress - Paused  
In progress - *%* of *size* encrypted  
In progress - Optimizing  
- Enabled
- Decrypting - *%* of *size* decrypted  
Decrypting - Paused *(APFS-exclusive)* 
- Disabled
- Status unknown - Please verify

**Some states are not available for particular OS versions or filesystems.**

Please note, that when selecting conditions for smart groups or advanced searches it is recommended to interpret `In progress` and `Decrypting` states with `like` matching.

---

### Extension Attribute in JAMF:

Due to inability to place any EAs in *Disk Encryption* or *Security* tabs of *Inventory*, the *Operating System* seems to be the most suitable for this (although *Extension Attributes* would do as well).  

Example of complete configuration of this EA could be as follows:

<img src="https://github.com/bsojka/readme-images/raw/master/rtrouton_scripts/FileVault%20Encryption%20EA.png?raw=true" width="486" height="330">

With *Description* being:
```
The script checks to see if a Mac is running 10.7 or higher and if it is, reports on whether or not it is encrypted with Apple's FileVault 2 encryption and gives the encryption or decryption status.

Available states are:
- Unknown version of Mac OS X
- Unrecognised file system
- Not available
- Not enabled
- In progress
- Enabled
- Decrypting
- Disabled
- Status unknown
```

---

#### TODO:

- Optimisation of `diskutil` calls for HFS filesystem, based on a code for APFS,
- Getting rid of temporary file creation altogether, based on a code for APFS.