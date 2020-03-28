This script sets one of four boot arguments and passes it to NVRAM:

* `RecoveryModeDisk`: Boots to the Recovery volume on your local boot drive
* `RecoveryModeNetwork`: Boots to Internet Recovery
* `DiagsModeDisk`: Boots to the Diagnostics or Apple Hardware Test volume on your local boot drive.
* `DiagsModeNetwork`: Boots to Internet Diagnostics or Apple Hardware Test

**Note:** If booting to macOS Recovery, this script will set the logged-in account to have admin privileges. This is because an admin account is needed to be able to access the macOS Utilites tools in the Recovery environment.	