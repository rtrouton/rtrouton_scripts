This script is designed to be run on a Mac via a Jamf Pro policy to clear failed MDM commands on a regular basis. This allows failed MDM commands or profiles to be re-pushed automatically.

API rights required by account specified in the script's `jamfpro_user` variable:

**Jamf Pro Server Objects**:

***Computers***: `Read`

**Jamf Pro Server Actions**:

`Flush MDM Commands`

* Original script from: [https://aporlebeke.wordpress.com/2019/01/04/auto-clearing-failed-mdm-commands-for-macos-in-jamf-pro/](https://aporlebeke.wordpress.com/2019/01/04/auto-clearing-failed-mdm-commands-for-macos-in-jamf-pro/)
* GitHub gist: [https://gist.github.com/apizz/48da271e15e8f0a9fc6eafd97625eacdfile-ea_clear_failed_mdm_commands-sh](https://gist.github.com/apizz/48da271e15e8f0a9fc6eafd97625eacdfile-ea_clear_failed_mdm_commands-sh)