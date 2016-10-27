This script is designed for use as part of a Casper policy to perform the following actions:

* Fix the ByHost files for the current boot drive
* Flush caches from ~/Library/Caches/, ~/.jpi_cache/, and the Microsoft Office font cache for the logged-in user
* Flush caches from /Library/Caches/ and /System/Library/Caches/, except for any com.apple.LaunchServices caches