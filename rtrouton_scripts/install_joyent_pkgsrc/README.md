This script will download an OS-appropriate gzipped tar file from [Joyent](http://pkgsrc.joyent.com) and install **pkgsrc** using the bootstrap installer stored inside the downloaded tar file.

How the script works:

1. Uses curl to download an OS-appropriate gzipped tar file containing the latest **pkgsrc** bootstrap installer from [http://pkgsrc.joyent.com](http://pkgsrc.joyent.com).
2. Renames the downloaded tar file to **pkgsrc.tar.gz** and stores it in **/tmp**.
3. Installs **pkgsrc** into **/opt/pkg** using the **pkgsrc** bootstrap installer.
4. Updates pkgsrc with the latest package info.
5. After installation, removes the downloaded tar file from the Mac in question.

**Post-installation**

  
Once installed, the pkgsrc binaries are located inside of /opt/pkg. /opt/pkg is not automatically added to the list of places that Terminal will search for commands, so you may wish to add the following entries to your account's **.bash_profile** file or your Mac's **/etc/profile** file:


`PATH=/opt/pkg/sbin:/opt/pkg/bin:$PATH`

`MANPATH=/opt/pkg/man:$MANPATH`


If you want to set these variables for only your account, please run the following commands:


`echo "export PATH=/opt/pkg/sbin:/opt/pkg/bin:$PATH" >> $HOME/.bash_profile`

`echo "export MANPATH=/opt/pkg/man:$MANPATH" >> $HOME/.bash_profile`


If you want to set these variables for all users on your Mac, please run the following commands with root privileges:

`echo "export PATH=/opt/pkg/sbin:/opt/pkg/bin:$PATH" >> /etc/profile`

`echo "export MANPATH=/opt/pkg/man:$MANPATH" >> /etc/profile`

After that, please close and re-open your Terminal window. That will allow the new path settings to take effect.



This script is also available as a payload-free installer package, stored as a .zip file in the **payload_free_installer** directory.

Accompanying blog post: [https://derflounder.wordpress.com/2015/04/23/installing-joyents-pkgsrc-package-manager-on-os-x/](https://derflounder.wordpress.com/2015/04/23/installing-joyents-pkgsrc-package-manager-on-os-x/)