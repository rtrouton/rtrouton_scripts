This script is intended to create self-signed certificate public keys for use with Jamf Pro dummy profiles. The script performs the following actions:

1.  Generates a self-signed SSL certificate's public key and associated private key, where the script's default settings are to create a self-signed certificate with the following characteristics:
```
• Certificate subject name is set to a UUID value.
```
```
• Certificate key is set to use a 4096-bit RSA key
```
```
• Certificate lifespan is set to 3652 days.
```
2. If the self-signed SSL certificate's public key and private key are successfully created, script displays a message listing public key certificate name with a `.cer` file extension and the certificate public key's location on the filesystem.
3. If the self-signed SSL certificate's public key and private key are not successfully created, script displays an error message.

**Note:** Both the RSA key bit strength and lifespan are set using variables in the script, so these default settings can be adjusted as needed.

The private keys created by this script are completely disposable. For this purpose, we only want the public keys created by this script because we want a certificate payload for Jamf Pro dummy profiles which is functionally useless.

A successful run of the script should produce output similar to that shown below:

```
username@computername % /path/to/create_certificate_public_keys_for_dummy_profile_certificate_payload.sh
Creating self-signed certificate with 4096 bit RSA key and a lifespan of 3652 days.
Generating a 4096 bit RSA private key
...........................................................++++
..........................................................................................................++++
writing new private key to '/var/folders/bq/d25fcnnj74j2gd8cnkhjmlqh0000gp/T/tmp.qkbeMzYTIY/2E69ABC8-3B5C-4F8F-ACE9-BAAAE592BF1C.key'
-----
Self-signed certificate successfully generated.
Self-signed certificate public key name: 2E69ABC8-3B5C-4F8F-ACE9-BAAAE592BF1C.cer
Self-signed certificate public key location: /var/folders/bq/d25fcnnj74j2gd8cnkhjmlqh0000gp/T/tmp.E45hx0xaW2/2E69ABC8-3B5C-4F8F-ACE9-BAAAE592BF1C.cer
username@computername % 
```