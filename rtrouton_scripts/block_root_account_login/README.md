This script is designed to block login access to the `root` account on macOS. It does this with the following actions:

1. Sets the `root` account's password to a random 32 character long password using the `openssl` command.
2. Sets the `root` account's login shell to `/usr/bin/false`

There is a payload-free package for running the script, available in the **payload-free_package** directory.