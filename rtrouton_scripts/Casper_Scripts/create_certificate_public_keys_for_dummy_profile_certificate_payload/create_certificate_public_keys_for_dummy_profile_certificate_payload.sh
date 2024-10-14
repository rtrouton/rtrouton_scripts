#!/bin/bash

# This script is used for creating SSL certificate public keys for use with Jamf Pro
# dummy profiles. The SSL certificate public keys created by this script by default
# have the following characteristics:
#
# * Self-signed
# * RSA 4096-bit key
# * Good for ten years (3652 days)

public_certificate_directory=$(mktemp -d)
private_key_directory=$(mktemp -d)
certificate_name=$(uuidgen)
certificate_bit="4096"
certificate_lifespan="3652"

# Generate a self-signed SSL certificate's public key and associated private key, where
# the script's default settings are to use a 4096-bit RSA key and a lifespan of 3652
# days. The private keys and public keys are stored in separate directories to help avoid
# confusion about which is which for script users who are new to using certificates.
#
# The private keys created by this script are completely disposable. For this purpose,
# we only want the public keys created by this script because we want a certificate payload
# for Jamf Pro dummy profiles which is functionally useless.

echo "Creating self-signed certificate with $certificate_bit bit RSA key and a lifespan of $certificate_lifespan days."
/usr/bin/openssl req -x509 -newkey rsa:"$certificate_bit" -sha256 -days "$certificate_lifespan" -nodes -keyout "$private_key_directory/$certificate_name.key" -out "$public_certificate_directory/$certificate_name.cer" -subj "/CN=$certificate_name"

# If the self-signed SSL certificate's public key and private key are successfully
# created, script displays a message listing public key certificate name with a 
# .cer file extension and the certificate public key's location on the filesystem.

if [[ -f "$public_certificate_directory/$certificate_name.cer" ]] && [[ -f "$private_key_directory/$certificate_name.key" ]]; then
    echo "Self-signed certificate successfully generated."
    echo "Self-signed certificate public key name: $certificate_name.cer"
    echo "Self-signed certificate public key location: $public_certificate_directory/$certificate_name.cer"
else
    echo "ERROR: Self-signed certificate creation failed."
fi