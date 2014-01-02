This script will allow a Mac running 10.6.x through 10.9.x to connect to an OpenLDAP server using a simple anonymous bind.

If you are adapting this for your own use, run a search and replace for the following:

"dc=replaceme,dc=org" (no quotes)

You'll need to replace that with your own LDAP search base

"ldap.server.here" (no quotes)

You'll need to replace that with the fully qualified domain name of your OpenLDAP server.
