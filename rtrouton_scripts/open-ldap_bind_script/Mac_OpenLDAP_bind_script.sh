#!/bin/sh

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Environment settings
oddomain="ldap.server.here" 	# Fully qualified DNS of your LDAP server
domain="addomain.org"            	# Fully qualified DNS name of Active Directory Domain
domainname="DOMAIN"             	# Name of the Domain as specified in the search paths

#
#
# If you are adapting this for your own use, run a 
# search and replace for the following:
#
# "dc=replaceme,dc=org" (no quotes)
# You'll need to replace that with your own LDAP search base
#
# "ldap.server.here" (no quotes)
# You'll need to replace that with the
# fully qualified domain name of your
# OpenLDAP server
#
#

# These variables probably don't need to be changed
# Determing if any directory binding exists
nicAddress=$(ifconfig en0 | awk '/ether/{print $2}')

if dscl localhost -list /LDAPv3 | grep . > /dev/null; then
    check4OD=$(dscl localhost -list /LDAPv3 | awk 'NR<2{print $NF}')
    echo "Found LDAP: "$check4OD
else
    echo "No LDAP binding found"
fi

if dscl localhost -list "/Active Directory" | grep $domainname > /dev/null; then
    check4AD=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')
    echo "Found AD: "$check4AD
else
    echo "No AD binding found"
fi

echo ""
echo ""

echo "Binding to LDAP Domain "$oddomain

if [[ ${osvers} -lt 7 ]]; then
   if [ ! -d '/Library/Preferences/DirectoryService' ]; then
    	echo "mkdir /Library/Preferences/DirectoryService"
   fi

   if [ -f /Library/Preferences/DirectoryService/DSLDAPv3PlugInConfig.plist ]; then
     echo "rm /Library/Preferences/DirectoryService/DSLDAPv3PlugInConfig.plist"
   fi
fi

if [[ ${osvers} -lt 7 ]]; then
/bin/cat > /tmp/$oddomain.plist << 'NEW_LDAP_BIND'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>LDAP PlugIn Version</key>
	<string>DSLDAPv3PlugIn Version 1.5</string>
	<key>LDAP Server Configs</key>
	<array>
		<dict>
			<key>Attribute Type Map</key>
			<array>
				<dict>
					<key>Native Map</key>
					<array>
						<string>cn</string>
					</array>
					<key>Standard Name</key>
					<string>dsAttrTypeStandard:RecordName</string>
				</dict>
				<dict>
					<key>Native Map</key>
					<array>
						<string>createTimestamp</string>
					</array>
					<key>Standard Name</key>
					<string>dsAttrTypeStandard:CreationTimestamp</string>
				</dict>
				<dict>
					<key>Native Map</key>
					<array>
						<string>modifyTimestamp</string>
					</array>
					<key>Standard Name</key>
					<string>dsAttrTypeStandard:ModificationTimestamp</string>
				</dict>
			</array>
			<key>Delay Rebind Try in seconds</key>
			<integer>120</integer>
			<key>Denied SASL Methods</key>
			<array>
				<string>DIGEST-MD5</string>
			</array>
			<key>Enable Use</key>
			<true/>
			<key>Idle Timeout in minutes</key>
			<integer>2</integer>
			<key>LDAP Referrals</key>
			<true/>
			<key>Local Security Level</key>
			<dict>
				<key>No ClearText Authentications</key>
				<false/>
			</dict>
			<key>OpenClose Timeout in seconds</key>
			<integer>15</integer>
			<key>Port Number</key>
			<integer>389</integer>
			<key>Record Type Map</key>
			<array>
				<dict>
					<key>Attribute Type Map</key>
					<array>
						<dict>
							<key>Native Map</key>
							<array>
								<string>uid</string>
								<string>cn</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:RecordName</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>cn</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:RealName</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>uidNumber</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:UniqueID</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>gidNumber</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:PrimaryGroupID</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>homeDirectory</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:NFSHomeDirectory</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>userPassword</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Password</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>loginShell</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:UserShell</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>description</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Comment</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>shadowLastChange</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Change</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>shadowExpire</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Expire</string>
						</dict>
					</array>
					<key>Native Map</key>
					<array>
						<dict>
							<key>Group Object Classes</key>
							<string>OR</string>
							<key>Object Classes</key>
							<array>
								<string>posixAccount</string>
								<string>inetOrgPerson</string>
								<string>shadowAccount</string>
							</array>
							<key>Search Base</key>
							<string>dc=replaceme,dc=org</string>
						</dict>
					</array>
					<key>Standard Name</key>
					<string>dsRecTypeStandard:Users</string>
				</dict>
				<dict>
					<key>Attribute Type Map</key>
					<array>
						<dict>
							<key>Native Map</key>
							<array>
								<string>memberUid</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:GroupMembership</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>memberUid</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Member</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>gidNumber</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:PrimaryGroupID</string>
						</dict>
					</array>
					<key>Native Map</key>
					<array>
						<dict>
							<key>Group Object Classes</key>
							<string>OR</string>
							<key>Object Classes</key>
							<array>
								<string>posixGroup</string>
							</array>
							<key>Search Base</key>
							<string>dc=replaceme,dc=org</string>
						</dict>
					</array>
					<key>Standard Name</key>
					<string>dsRecTypeStandard:Groups</string>
				</dict>
				<dict>
					<key>Attribute Type Map</key>
					<array>
						<dict>
							<key>Native Map</key>
							<array>
								<string>mountDirectory</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:VFSLinkDir</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>mountOption</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:VFSOpts</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>mountType</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:VFSType</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>mountDumpFrequency</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:VFSDumpFreq</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>mountPassNo</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:VFSPassNo</string>
						</dict>
					</array>
					<key>Native Map</key>
					<array>
						<dict>
							<key>Group Object Classes</key>
							<string>OR</string>
							<key>Object Classes</key>
							<array>
								<string>mount</string>
							</array>
							<key>Search Base</key>
							<string>dc=replaceme,dc=org</string>
						</dict>
					</array>
					<key>Standard Name</key>
					<string>dsRecTypeStandard:Mounts</string>
				</dict>
				<dict>
					<key>Attribute Type Map</key>
					<array>
						<dict>
							<key>Native Map</key>
							<array>
								<string>cn</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:RecordName</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>cn</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:RealName</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>sn</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:LastName</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>givenName</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:FirstName</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>mail</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:EMailAddress</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>telephoneNumber</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:PhoneNumber</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>homePhone</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:HomePhoneNumber</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>facsimileTelephoneNumber</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:FAXNumber</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>mobile</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:MobileNumber</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>pager</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:PagerNumber</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>street</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:AddressLine1</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>postalAddress</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:PostalAddress</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>street</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Street</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>l</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:City</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>st</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:State</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>postalCode</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:PostalCode</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>c</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Country</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>o</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:OrganizationName</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>departmentNumber</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Department</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>title</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:JobTitle</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>buildingName</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Building</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>userCertificate;binary</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:UserCertificate</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>userSMIMECertificate</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:UserSMIMECertificate</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>userPKCS12</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:UserPKCS12Data</string>
						</dict>
					</array>
					<key>Native Map</key>
					<array>
						<dict>
							<key>Group Object Classes</key>
							<string>OR</string>
							<key>Object Classes</key>
							<array>
								<string>inetOrgPerson</string>
							</array>
							<key>Search Base</key>
							<string>dc=replaceme,dc=org</string>
						</dict>
					</array>
					<key>Standard Name</key>
					<string>dsRecTypeStandard:People</string>
				</dict>
				<dict>
					<key>Attribute Type Map</key>
					<array>
						<dict>
							<key>Native Map</key>
							<array>
								<string>cn</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:RecordName</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>authorityRevocationList;binary</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:AuthorityRevocationList</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>certificateRevocationList;binary</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:CertificateRevocationList</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>crossCertificatePair;binary</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:CrossCertificatePair</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>cACertificate;binary</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:CACertificate</string>
						</dict>
					</array>
					<key>Native Map</key>
					<array>
						<dict>
							<key>Group Object Classes</key>
							<string>OR</string>
							<key>Object Classes</key>
							<array>
								<string>certificationAuthority</string>
							</array>
							<key>Search Base</key>
							<string>dc=replaceme,dc=org</string>
						</dict>
					</array>
					<key>Standard Name</key>
					<string>dsRecTypeStandard:CertificateAuthorities</string>
				</dict>
				<dict>
					<key>Attribute Type Map</key>
					<array>
						<dict>
							<key>Native Map</key>
							<array>
								<string>description</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Comment</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>automountMapName</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:RecordName</string>
						</dict>
					</array>
					<key>Native Map</key>
					<array>
						<dict>
							<key>Group Object Classes</key>
							<string>OR</string>
							<key>Object Classes</key>
							<array>
								<string>automountMap</string>
							</array>
							<key>Search Base</key>
							<string>dc=replaceme,dc=org</string>
						</dict>
					</array>
					<key>Standard Name</key>
					<string>dsRecTypeStandard:AutomountMap</string>
				</dict>
				<dict>
					<key>Attribute Type Map</key>
					<array>
						<dict>
							<key>Native Map</key>
							<array>
								<string>description</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:Comment</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>automountInformation</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:AutomountInformation</string>
						</dict>
						<dict>
							<key>Native Map</key>
							<array>
								<string>automountKey</string>
							</array>
							<key>Standard Name</key>
							<string>dsAttrTypeStandard:RecordName</string>
						</dict>
					</array>
					<key>Native Map</key>
					<array>
						<dict>
							<key>Group Object Classes</key>
							<string>OR</string>
							<key>Object Classes</key>
							<array>
								<string>automount</string>
							</array>
							<key>Search Base</key>
							<string>dc=replaceme,dc=org</string>
						</dict>
					</array>
					<key>Standard Name</key>
					<string>dsRecTypeStandard:Automount</string>
				</dict>
			</array>
			<key>SSL</key>
			<false/>
			<key>Search Timeout in seconds</key>
			<integer>120</integer>
			<key>Server</key>
			<string>ldap.server.here</string>
			<key>Server Mappings</key>
			<false/>
			<key>Supported Security Level</key>
			<dict>
				<key>Man In The Middle</key>
				<true/>
				<key>No ClearText Authentications</key>
				<true/>
				<key>Packet Encryption</key>
				<true/>
				<key>Packet Signing</key>
				<true/>
			</dict>
			<key>Template Name</key>
			<string>RFC 2307 (Unix)</string>
			<key>Template Search Base Suffix</key>
			<string>dc=replaceme,dc=org</string>
			<key>Template Version</key>
			<string>10.4</string>
			<key>UI Name</key>
			<string>ldap.server.here</string>
			<key>Use DNS replicas</key>
			<false/>
		</dict>
	</array>
	<key>Service Principals to Create</key>
	<string>host,afpserver,cifs,vnc</string>
</dict>
</plist>
NEW_LDAP_BIND

  if [ -f /Library/Preferences/DirectoryService/DSLDAPv3PlugInConfig.plist ]; then
     rm /Library/Preferences/DirectoryService/DSLDAPv3PlugInConfig.plist
     mv /tmp/$oddomain.plist /Library/Preferences/DirectoryService/DSLDAPv3PlugInConfig.plist
  fi

  echo "Killing DirectoryService"
  killall DirectoryService
  
  echo "Giving Directory Services some time to reload..."
  sleep 10

  
  echo "Killing DirectoryService"
  killall DirectoryService

fi


if [[ ${osvers} -ge 7 ]]; then
	if [ ! -d /Library/Preferences/OpenDirectory/Configurations/LDAPv3 ]; then
    	mkdir /Library/Preferences/OpenDirectory/Configurations/LDAPv3
	fi

	if [ -f /Library/Preferences/OpenDirectory/Configurations/LDAPv3/$oddomain.plist ]; then
    	mv /Library/Preferences/OpenDirectory/Configurations/LDAPv3/$oddomain.plist /tmp/config_$oddomain.plist
	fi
fi

if [[ ${osvers} -ge 7 ]]; then
/bin/cat > /tmp/$oddomain.plist << 'NEW_LDAP_BIND'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>description</key>
	<string>ldap.server.here</string>
	<key>mappings</key>
	<dict>
		<key>template</key>
		<string>RFC2307</string>
	</dict>
	<key>module options</key>
	<dict>
		<key>AppleODClient</key>
		<dict>
			<key>Server Mappings</key>
			<false/>
		</dict>
		<key>ldap</key>
		<dict>
			<key>Denied SASL Methods</key>
			<array>
				<string>DIGEST-MD5</string>
				<string>NTLM</string>
				<string>GSSAPI</string>
				<string>CRAM-MD5</string>
				<string>DIGEST-MD5</string>
			</array>
			<key>LDAP Referrals</key>
			<true/>
			<key>Template Search Base Suffix</key>
			<string>dc=replaceme,dc=org</string>
			<key>Use DNS replicas</key>
			<false/>
		</dict>
	</dict>
	<key>node name</key>
	<string>/LDAPv3/ldap.server.here</string>
	<key>options</key>
	<dict>
		<key>connection idle disconnect</key>
		<integer>60</integer>
		<key>connection setup timeout</key>
		<integer>10</integer>
		<key>destination</key>
		<dict>
			<key>host</key>
			<string>ldap.server.here</string>
			<key>other</key>
			<string>ldap</string>
			<key>port</key>
			<integer>389</integer>
		</dict>
		<key>man-in-the-middle</key>
		<false/>
		<key>no cleartext authentication</key>
		<true/>
		<key>packet encryption</key>
		<integer>1</integer>
		<key>packet signing</key>
		<integer>1</integer>
		<key>query timeout</key>
		<integer>30</integer>
	</dict>
	<key>template</key>
	<string>LDAPv3</string>
	<key>trusttype</key>
	<string>anonymous</string>
</dict>
</plist>
NEW_LDAP_BIND

    if [ ! -f /Library/Preferences/OpenDirectory/Configurations/LDAPv3/$oddomain.plist ]; then
    	mv /tmp/$oddomain.plist /Library/Preferences/OpenDirectory/Configurations/LDAPv3/$oddomain.plist
    fi
    
    sleep 5

	echo "Killing opendirectoryd"
	killall opendirectoryd

fi

echo "Finished OD Binding."
# Give DS a chance to catch up
sleep 5

if [[ ${osvers} -ge 7 ]]; then
    echo "Removing previous bindings"
    dscl localhost -delete Search CSPSearchPath '/Active Directory/DOMAIN/All Domains'
    dscl localhost -merge Search CSPSearchPath '/LDAPv3/ldap.server.here'

# Even if using All Domains, you need to add '/Active Directory/DOMAIN'
# to the authentication search path

    dscl localhost -merge Search CSPSearchPath '/Active Directory/DOMAIN'
    dscl localhost -merge Search CSPSearchPath '/Active Directory/DOMAIN/All Domains'

# If you're planning to use All Domains, remove '/Active Directory/DOMAIN'
# from the search path

    dscl localhost -delete Search CSPSearchPath '/Active Directory/DOMAIN'
    echo "Killing opendirectoryd"
    killall opendirectoryd
fi

if [[ ${osvers} -lt 7 ]]; then
  echo "Removing AD binding"
  dscl localhost -delete Search CSPSearchPath '/Active Directory/All Domains'
  dscl localhost -merge Search CSPSearchPath '/LDAPv3/ldap.server.here'
  dscl localhost -merge Search CSPSearchPath '/Active Directory/All Domains'
  echo "Killing DirectoryService"
  killall DirectoryService
fi

echo -n "Now bound to OD Domain: "
dscl localhost -list /LDAPv3
echo -n "With Search Path entries: "
dscl /Search -read / CSPSearchPath | grep /LDAP

echo -n "Now bound to AD Domain: "
dscl localhost -list "/Active Directory"
echo -n "With Search Path entries: "
dscl /Search -read / CSPSearchPath | grep /Active

exit 0                    ## Success
