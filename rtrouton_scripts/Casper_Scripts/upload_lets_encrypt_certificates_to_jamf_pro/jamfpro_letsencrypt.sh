#!/bin/bash

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# Original script written by Kyle Bareis

# Webmin-specific additions by Rich Trouton

# Based off of Ivan Tichy - http://blog.ivantichy.cz/blogpost/view/74
# Based off of Jon Yergatian - https://github.com/sonofiron

####### Requreiments #######

# This script will pull the latest copy of Lets Encrypt certificates downloaded
# by Webmin and configure them for use with your Jamf Pro server running on Linux.
#
# Please read though the entire script before running this. It is highly recomended
# That you test this on a development envronment before trying in production.

# You must have the following software installed:
#	* Java (either OpenJDK or Oracle Java)
#	* Jamf Pro server (Tomcat)

# This script must be run with sudo.

# If you have restrictive firewall rules, port 80 must be open from server out to
# the internet. LetsEncrypt uses port 80 to validate certs. Addiitionally, certs
# may only be renewed every 60-90 days.

####### How to use #######

# 1. Ensure the JSS is running and that you can access the web console
# 2. Review and modify variables below. Stop before the script logic section
# 3. Copy script to JSS server and place in a safe place (not tmp)
# 4. run chmod +x /path/to/jamfpro_letsEncrypt.sh
# 5. run sudo bash /path/to/jamfpro_letsEncrypt.sh
# 6. (Optional) Place in /etc/cron.daily/ for the script to run automatically
#		6.a Change ownership of the file
#		6.b Change file permissions
# 	6.c Remove .sh from script. Validate setup by running: run-parts --test /etc/cron.daily

####### Variables #######

# FQDN of the JSS. This cannot be a .local domain

DOMAIN="jamf_pro_server.address.goes.here"

# JSS Tomcat Service (default is jamf.tomcat8 for Casper Suite 9.101). May need to
# be changed if JSS was manually installed or if there is a different verison of
# Tomcat.

JSS_SERVICE="jamf.tomcat8"

# JSS (Tomcat) Server XML file location

JSS_SERVER_XML="/usr/local/jss/tomcat/conf/server.xml"


# Lets Encrypt password for .pem file
# This is a password for the holding container that we generate certs into.
# While this is not an outward facing cert file, it is recomended that you use
# a secure password. This will only be used by this script.

LETSENCRYPT_STOREPASS="changeit"

# Log file location

LOG="/var/log/letsEncryptConsole.log"

####### Script Logic #######

# JSS keystore location read from the server.xml file

JSS_KEYSTORE_LOCATION=$(sed -n 's/^.*keystoreFile=/keystoreFile=/p' $JSS_SERVER_XML | cut -d '"' -f2)

# JSS keystore password read from the server.xml file

JSS_STOREPASS=$(sed -n 's/^.*keystorePass=/keystorePass=/p' $JSS_SERVER_XML | cut -d '"' -f2)

# Checking to see if required services are installed. For each service in the
# array, the for loop will look to see if it can find the binary. If it can't
# the script will exit.

REQUIRED_SERVICES=("java" "keytool" "openssl")

	for SERVICE in "${REQUIRED_SERVICES[@]}"; do
		if type -p "$SERVICE"; then
			echo "$(date "+%a %h %d %H:%M:%S"): $SERVICE installed" 2>&1 | tee -a "$LOG"
		else
			echo "$(date "+%a %h %d %H:%M:%S"): Could not find $SERVICE installed. Exiting script!" 2>&1 | tee -a "$LOG"
			exit 1
		fi
	done

# Checking to see if the JSS is installed and running. If not, it will exit

	if [ ! -f "$JSS_KEYSTORE_LOCATION" ]; then
		echo "$(date "+%a %h %d %H:%M:%S"): Unable to find the JSS keystore at $JSS_KEYSTORE_LOCATION. Exiting script!" 2>&1 | tee -a "$LOG"
		exit 1
	else
		echo "$(date "+%a %h %d %H:%M:%S"): Keystore found. JSS appears to be installed." 2>&1 | tee -a "$LOG"
	fi

# In order to export the certs for proper use with Tomcat, the files need to be placed in
# .pem file format.

# We're going to rely on Webmin's renewal of LetsEncrypt certificates for generation of the proper .pem files.
# The reason for this is so that we can piggyback on Webmin's automated renewal of LetsEncrypt certificates.
#
# In this case, we're assuming that the following certificates are stored in /etc/webmin:
#
# Private key file: /etc/webmin/letsencrypt-key.pem
# Certificate file: /etc/webmin/letsencrypt-cert.pem
# Certificate authority chain file: /etc/webmin/letsencrypt-ca.pem

# Check to see if certificates have already been configured by Webmin. If certs have
# been configured, then the script will check and see if they need to be renewed.

if [[ -f /etc/webmin/letsencrypt-key.pem ]] && [[ -f /etc/webmin/letsencrypt-cert.pem ]] && [[ -f /etc/webmin/letsencrypt-cert.pem ]]; then
		echo "$(date "+%a %h %d %H:%M:%S"): Certificates for $DOMAIN are already generated. Checking date and time stamps." 2>&1 | tee -a "$LOG"

			# Running a comparision between todays date and the time stamp on the private key
			# Certs can only be renewed max every 60 days from Lets Encrypt, so the date check
			# is set for 75 days.

				PRIVATE_KEY_DATE=$(date -r /etc/webmin/letsencrypt-key.pem +%Y%m%d)
				MIN_RENEWAL_DATE=$(date -d "$PRIVATE_KEY_DATE 75 days" +"%Y%m%d")
				TODAYS_DATE=$(date +"%Y%m%d")
				if [ "$TODAYS_DATE" -gt "$MIN_RENEWAL_DATE" ]; then
					echo "$(date "+%a %h %d %H:%M:%S"): Certificates can be updated. Check Webmin." 2>&1 | tee -a "$LOG"
				else
					echo "$(date "+%a %h %d %H:%M:%S"): Certificates do not need to be updated. Next update needed after $MIN_RENEWAL_DATE" 2>&1 | tee -a "$LOG"
					exit 0
				fi
	else
		echo "$(date "+%a %h %d %H:%M:%S"): Certificates not found for $DOMAIN. Check Webmin SSL configuration." 2>&1 | tee -a "$LOG"

fi

# Remove any existing /root/cert_and_key.p12 prior to creating one.

if [[ -f /root/cert_and_key.p12 ]]; then
     rm /root/cert_and_key.p12
fi

if [[ -f /etc/webmin/letsencrypt-key.pem ]] && [[ -f /etc/webmin/letsencrypt-cert.pem ]] && [[ -f /etc/webmin/letsencrypt-cert.pem ]]; then
	echo "$(date "+%a %h %d %H:%M:%S"): Exporting certificates from Lets Encrypt" 2>&1 | tee -a "$LOG"
	openssl pkcs12 -export -in /etc/webmin/letsencrypt-cert.pem -inkey /etc/webmin/letsencrypt-key.pem -out /root/cert_and_key.p12 -name tomcat -CAfile /etc/webmin/letsencrypt-ca.pem -caname tomcat -password pass:"$LETSENCRYPT_STOREPASS"
fi

# Stopping Tomcat while making changes. The script will restart Tomcat when finished.
	CHECK_JSS_SERVICE=$(systemctl status "$JSS_SERVICE" | awk '/Active/ {print $3}' | head -2 | tr -d '()')
	if [ "$CHECK_JSS_SERVICE" = "running" ]; then
		echo "$(date "+%a %h %d %H:%M:%S"): $JSS_SERVICE is running. Stopping service now." 2>&1 | tee -a "$LOG"
		systemctl stop "$JSS_SERVICE"
	else
		echo "$(date "+%a %h %d %H:%M:%S"): $JSS_SERVICE not found. Exiting script!" 2>&1 | tee -a "$LOG"
		echo "$(date "+%a %h %d %H:%M:%S"): If this has worked before for you, please check and see if Tomcat is running." 2>&1 | tee -a "$LOG"
		exit 1
	fi

# Backing up the existing Keystore. This is primarily for safety. Never want to
# delete things unless you have a backup!
	echo "$(date "+%a %h %d %H:%M:%S"): Creating back up of keystore. Location: $JSS_KEYSTORE_LOCATION.old" 2>&1 | tee -a "$LOG"
	cp "$JSS_KEYSTORE_LOCATION" "$JSS_KEYSTORE_LOCATION.old"

# Removing any existing aliases within the Tomcat Keystore. We need to existing
# keystore for tomcat to be empty so this will remove every alias within the file
	TOMCAT_ALIAS=$(keytool -list -v --keystore "$JSS_KEYSTORE_LOCATION" -storepass "$JSS_STOREPASS" | grep Alias | cut -d ' ' -f3)

	for ALIAS in $TOMCAT_ALIAS; do
		echo "$(date "+%a %h %d %H:%M:%S"): Removing $ALIAS from $JSS_KEYSTORE_LOCATION" 2>&1 | tee -a "$LOG"
		keytool -delete -alias "$ALIAS" -storepass "$JSS_STOREPASS" -keystore "$JSS_KEYSTORE_LOCATION"
	done

# Importing Unique Tomcat Certificates
	echo "$(date "+%a %h %d %H:%M:%S"): Importing Tomcat Certicate" 2>&1 | tee -a "$LOG"
	keytool -importkeystore -srcstorepass "$LETSENCRYPT_STOREPASS" -deststorepass "$JSS_STOREPASS" -destkeypass "$JSS_STOREPASS" -srckeystore /root/cert_and_key.p12 -srcstoretype PKCS12 -alias tomcat -keystore "$JSS_KEYSTORE_LOCATION"

# Importing Chain Certificates
	echo "$(date "+%a %h %d %H:%M:%S"): Importing Chain Certificates" 2>&1 | tee -a "$LOG"
	keytool -import -trustcacerts -alias root -deststorepass "$JSS_STOREPASS" -file /etc/webmin/letsencrypt-ca.pem -noprompt -keystore "$JSS_KEYSTORE_LOCATION"

# Clean up exported cert_and_key.p12 file

if [[ -f /root/cert_and_key.p12 ]]; then
     rm /root/cert_and_key.p12
fi

# Restarting Tomcat
	CHECK_JSS_SERVICE=""
	systemctl start "$JSS_SERVICE"
	CHECK_JSS_SERVICE=$(systemctl status "$JSS_SERVICE" | awk '/Active/ {print $3}' | head -2 | tr -d '()')
	if [ "$CHECK_JSS_SERVICE" = "running" ]; then
		echo "$(date "+%a %h %d %H:%M:%S"): $JSS_SERVICE is running." 2>&1 | tee -a "$LOG"
		exit 0
	else
		echo "$(date "+%a %h %d %H:%M:%S"): $JSS_SERVICE not found. Tomcat failed to restart. Exiting script!" 2>&1 | tee -a "$LOG"
		echo "$(date "+%a %h %d %H:%M:%S"): You must manually put back your old keystore $JSS_KEYSTORE_LOCATION.old" 2>&1 | tee -a "$LOG"
		exit 1
	fi

# Successful exit code
	echo "$(date "+%a %h %d %H:%M:%S"): Script sucessfull!" 2>&1 | tee -a "$LOG"
	exit 0