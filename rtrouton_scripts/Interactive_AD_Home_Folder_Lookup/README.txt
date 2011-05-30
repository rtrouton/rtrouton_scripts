One of the occasional issues I’ve run into at work is that we don’t have one central location that stores all of our AD home directories. As a result, telling someone where it is can take some digging and delay. To help speed up the process, I've built an interactive shell script that looks this information up. It should be pretty generic, but the only location I’ve tested it at is here at my workplace. Your milage may vary.

Assumptions: In order to work correctly, the script needs for the Mac to be bound to an AD domain. The AD-bound Mac also needs to be connected to the AD domain via a domain-reachable network connection or via VPN.

Using the script:

Launch the script and provide the username in the blank provided, then click OK. It will confirm the username you want to look up, and then display the AD user's home folder location (as defined in their AD account's profile.)
