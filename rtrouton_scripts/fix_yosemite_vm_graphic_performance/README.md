Being able to virtualize OS X with VMware Fusion has been a great tool for Mac admins, as it allows them to test out new workflows and configurations before committing them to actual Macs. To go along with the convenience, there can be a performance trade-off between VMs and physical Macs, but it's usually been one where assigning adequate RAM and processors to the VMware Fusion VM  usually resulted in decent performance in the VM.

This changed with Yosemite, where the graphics performance in a VM was sluggish and assigning more RAM and processors to a VM did not address the issue. Even ensuring that the VMware Tools were installed did not markedly improve performance. I also saw redraw issue involving windows that had been in the background and hidden behind other windows. These windows were not redrawing correctly when they were selected and brought to the foreground, resulting in parts of windows showing up as being transparent.

On investigation, the root cause of the issue was beam synchronization, which is [a technique first introduced in 10.4.x](http://arstechnica.com/apple/2007/04/beam-synchronization-friend-or-foe/) to better handle screen redraw and allow OS X's window management process to be more efficient. Beam synchronization works fine on Yosemite when running on actual machines, but it was apparently a significant issue when running in a VMware VM.

Fortunately, the answer is relatively simple - disable beam synchronization. Once that's done, the performance of an OS X VM running 10.10.x improves dramatically. However, there were two hitches:

1. The way to disable it was to use Apple's [Quartz Debug developer tool](https://developer.apple.com/library/mac/documentation/GraphicsAnimation/Conceptual/HighResolutionOSX/Testing/Testing.html).

2. You had to disable it on every login.

Enter [BeamOff](https://github.com/JasF/beamoff), an application designed to do one thing - disable beam synchronization. 

**BeamOff** was developed by [JasF](http://www.insanelymac.com/forum/user/1190299-jasf/), who developed BeamOff to fix the performance issue he was having with Yosemite VMs. He posted [his source files to GitHub](https://github.com/JasF/beamoff) and a [compiled version of the application](https://www.sendspace.com/file/sm9sf7) as part of [this thread on the InsanelyMac forums](http://).

When **BeamOff** runs, you should see it appear briefly in the dock and bounce once or twice as it runs. Once it has finished disabling beam sync, it then quits automatically.

When I tested the compiled **BeamOff** application, I saw a considerable improvement in how fast the VM was now responding. The window redraw issues I had previously seen were now also addressed, where windows were now being refreshed correctly regardless if they were in the background or foreground.

Because I wanted to have **BeamOff** run automatically, I installed it in **/Applications** of my Yosemite VM and wrote the LaunchAgent linked below to launch and run BeamOff on login:

[https://gist.github.com/rtrouton/b732cb81b947e20b8bdc](https://gist.github.com/rtrouton/b732cb81b947e20b8bdc)

To assist other Mac admins who are also dealing with this issue, I've also built and posted an installer for **BeamOff** and the LaunchAgent, which is available as a .zip file from the **installer** directory. The installer adds **BeamOff** to **/Applications** and installs the  LaunchAgent to **/Library/LaunchAgents**.


For those interested in building their own installer, I've also posted a copy of the compiled **BeamOff** application, the LaunchAgent and the [Packages](http://s.sudre.free.fr/Software/Packages/about.html) project files I used to build the installer. Those are available in the **resources** directory.

Blog post: [http://derflounder.wordpress.com/2014/12/13/improving-yosemite-vm-performance-in-vmware-fusion/](http://derflounder.wordpress.com/2014/12/13/improving-yosemite-vm-performance-in-vmware-fusion/)