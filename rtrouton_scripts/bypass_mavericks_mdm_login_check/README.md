With the release of 10.9, a number of Mac admins began seeing an **Updating Managed Settings** message appear at the login window.

![image](http://i.imgur.com/tYsE3no.png)

When contacted, Apple said that this was new behavior and it was added for the following reasons:

> Starting with 10.9, MCX will attempt to contact an AD/OD/MDM server during login, before the Finder is launched to ensure that all managed settings are applied before any user session applications run.
> 
> The dialog you are seeing comes up if this process takes more than a couple seconds.
> 
> The dialog does not add any time to the login process.
> 
> It’s just telling you why the login is taking extra time.
> 
> If your AD/OD/MDM server is responding slowly, then this is “normal” as the client just has to wait for the operations to complete.

It is possible to disable the MDM check that is causing both the login delay and the **Updating Managed Settings** message to appear. 

The script available here will check to see if your Mac is on 10.9 and apply the bypass setting if it doesn't exist. It's also available as a payload-free package.


**Effects of disabling the login check**

Disabling the login check causes any pending profiles that contain user-level managed preferences not to be applied until the following login. The point of the delay was to make sure that the MDM server had a chance to apply settings; bypassing the login check-in will affect that.

For my own needs, disabling the check is an acceptable solution but different shops have different needs. Evaluate your own needs carefully.

Blog post: [http://derflounder.wordpress.com/2013/11/13/bypassing-the-mavericks-managed-preferences-login-check/](http://derflounder.wordpress.com/2013/11/13/bypassing-the-mavericks-managed-preferences-login-check/)