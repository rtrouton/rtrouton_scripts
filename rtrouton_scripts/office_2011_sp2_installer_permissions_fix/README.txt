When installed by the Office 2011 SP 2 12.2.0 retail installer, the permissions on /Applications/Microsoft Office 2011 look like this:

Owner: root: read/write/execute permissions
Group: wheel: read/write/execute permissions
Everyone: read/write/execute permissions

I've written a script that should find and fix the incorrect group and world-writable permissions and set them to the following permissions:

Owner: root: read/write/execute permissions
Group: admin: read/write/execute permissions
Everyone: read/execute permissions

I've also built a script-only installer package to run this script, to help folks who want to automate running this.