This script is designed to remove specified prohibited applications and files. As part of using this script, you will need to provide the list of applications and files to be removed, using their complete filepath.

For example, if an app named `Prohibited App.app` is stored in the `/Applications` directory, it should be listed as follows:

`/Applications/Prohibited App.app`

The script will perform the following actions:

Check the list of the prohibited software and perform the following actions if a matching file path is found:

1. Log that a prohibited application was found and that it will be moved to the logged-in user's Trash.
2. Move any matching applications to the logged-in user's Trash.
3. Change ownership of the moved application to the logged-in user so that the user can empty the Trash without permission errors.
4. Verify that the application was moved to the logged-in user's Trash. If not present, log an error.
5. Log that it was moved to the logged-in user's Trash.
6. If one or more prohibited applications are found, message is displayed to the logged-in user notifying the user that prohibited software was removed and providing the location of the log file.


