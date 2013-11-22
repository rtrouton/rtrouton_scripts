This script will allow a Mac to connect to an OpenLDAP server using a simple anonymous bind. It can also be used to migrate from one OpenLDAP server to another


It has been tested on 10.6.8, 10.7.5, 10.8.5 and 10.9.0.


If you are adapting this for your own use, run a search and replace for the following:

"**dc=replaceme,dc=org**" (no quotes)

You'll need to replace that with your own LDAP search base

"**ldap.server.here**" (no quotes)

You'll need to replace that with the fully qualified domain name of your OpenLDAP server.
