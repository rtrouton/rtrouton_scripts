This script is designed to ping an IP that's only available on your AD domain. If the ping does not return successfully, the following command is run to remove the AD domain from the Directory Utility Authentication path:

sudo dscl /Search -delete / CSPSearchPath "/Active Directory/domain.com"

With that path removed, the Mac is no longer aware that it should be looking outside of the Mac for authentication for its AD accounts. AD mobile accounts should immediately fall back on their cached credentials without any timeout needed.

If the ping succeeds on a following run of the script, the following command puts the AD domain back into Directory Utility's Authentication path:

sudo dscl /Search -append / CSPSearchPath "/Active Directory/domain.com"

With the path added back, the Mac should be able to check with AD again for its authentication.

The "adcheck" script is designed to be tied to a LaunchDaemon. In this case, the com.company.adcheck LaunchDaemon is watching /var/run/resolv.conf. When /var/run/resolv.conf changes, the script runs.


NOTE: Be aware that this script may have scaling problems. The internal IP(s) you're pinging must be able to stay up even when being pinged by the population of Macs you have deployed it to.

