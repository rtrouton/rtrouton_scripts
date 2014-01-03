This script checks to see if the Mac is either a MacBook Pro Retina or MacBook Air. If it's either of these machines, the script will then check for external USB or Thunderbolt ethernet adapters. If type of adapter is present, it will add the adapter to network services. Script is also available as a payload-free package.

Script was written to resolve an issue with USB and Thunderbolt Ethernet adapters not being recognized by [DeployStudio](http://www.deploystudio.com/)'s ds_finalize process. 

Original script by [Allen Golbig](https://github.com/golbiga/):
[https://github.com/golbiga/Scripts/blob/master/enable_external_network_adapter/enable_external_network_adapter.sh](https://github.com/golbiga/Scripts/blob/master/enable_external_network_adapter/enable_external_network_adapter.sh)