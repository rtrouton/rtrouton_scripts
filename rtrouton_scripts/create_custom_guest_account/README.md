If you want others to be able to temporarily use your computer, but you don’t want to create an account for each user, [Mac OS X allows you to create a guest account](http://support.apple.com/kb/PH11321). This guest account allows a person to log in to the Mac without entering a password, but the account type has the following limitations:

1. Guest users can't make changes to other user accounts
2. Guest users can't change setting on the computer
3. Guest users can't log in remotely.
4. Files created by guest users are deleted when the user logs out. As part of this, a temporary home folder is created for the guest’s files but this folder and its contents are deleted when the user logs out.

By default, OS X only allows the creation of a single guest account with the name of Guest. That said, it is possible to create custom guest accounts with names that are different from Guest. This would allow Mac admins to create multiple guest accounts if needed.

I've built a script for creating a custom guest account, [based on earlier work](https://gist.github.com/nbalonso/5696340) by [Noel B. Alonso](http://nbalonso.com). The script is available here and has been tested on Mac OS X 10.6.8 - 10.9.1.

One thing to be aware of is that, if the login window is set to show icons instead of the username and password blanks, all guest accounts created will show up with a "Guest User" account icon regardless of the account's name. If you need to have multiple user accounts, I recommend setting the login window to display username and password blanks and then logging in with the relevant username.