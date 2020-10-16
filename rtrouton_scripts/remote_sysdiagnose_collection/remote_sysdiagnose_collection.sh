#!/bin/bash

# Log collection script which performs the following tasks:
#
# * Collects a sysdiagnose file.
# * Creates a read-only compressed disk image containing the sysdiagnose file.
# * Uploads the compressed disk image to a specified S3 bucket.
# * Cleans up the directories and files created by the script.
#
# You will need to provide the following information to successfully upload
# to an S3 bucket:
# 
# S3 bucket name
# AWS region for the S3 bucket
# AWS programmatic user's access key and secret access key
# The S3 ACL used on the bucket
#
# The AWS programmatic user must have at minimum the following access rights to the specified S3 bucket:
#
# s3:ListBucket
# s3:PutObject
# s3:PutObjectAcl 
#
# The AWS programmatic user must have at minimum the following access rights to all S3 buckets in the account:
#
# s3:ListAllMyBuckets
#
# These access rights will allow the AWS programmatic user the ability to do the following:
# 
# A. Identify the correct S3 bucket
# B. Write the uploaded file to the S3 bucket
#
# Note: The AWS programmatic user would not have the ability to read the contents of the S3 bucket.
#
# Information on S3 ACLs can be found via the link below:
# https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl
#
# By default, the ACL should be the one listed below:
#
# private
# 

# User-editable variables

s3AccessKey="add_AWS_access_key_here"
s3SecretKey="add_AWS_secret_key_here"
s3acl="add_AWS_S3_ACL_here"
s3Bucket="add_AWS_S3_bucket_name_here"
s3Region="add_AWS_S3_region_here"

# It should not be necessary to edit any of the variables below this line.

error=0
date=$(date +%Y%m%d%H%M%S)
serial_number=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
hardware_uuid=$(ioreg -ad2 -c IOPlatformExpertDevice | xmllint --xpath '//key[.="IOPlatformUUID"]/following-sibling::*[1]/text()' -)
results_directory=$(mktemp -d -t logresults-${date})
sysdiagnose_name="sysdiagnose-${serial_number}-${hardware_uuid}-${date}.tar.gz"
dmg_name="${serial_number}-${hardware_uuid}-${date}.dmg"
dmg_file_location=$(mktemp -d -t sysdiagnoselog-${date})
fileName=$(echo "$dmg_file_location"/"$dmg_name")
contentType="application/octet-stream"

LogGeneration()
{

/usr/bin/sysdiagnose -f ${results_directory} -A "$sysdiagnose_name" -u -b

if [[ -f "$results_directory/$sysdiagnose_name" ]]; then
  /usr/bin/hdiutil create -format UDZO -srcfolder ${results_directory} ${dmg_file_location}/${dmg_name}
else
  echo "ERROR! Log file not created!"
  error=1
fi

}

S3Upload()
{

# S3Upload function taken from the following site:
# https://very.busted.systems/shell-script-for-S3-upload-via-curl-using-AWS-version-4-signatures

usage()
{
    cat <<USAGE

Simple script uploading a file to S3. Supports AWS signature version 4, custom
region, permissions and mime-types. Uses Content-MD5 header to guarantee
uncorrupted file transfer.

Usage:
  `basename $0` aws_ak aws_sk bucket srcfile targfile [acl] [mime_type]

Where <arg> is one of:
  aws_ak     access key ('' for upload to public writable bucket)
  aws_sk     secret key ('' for upload to public writable bucket)
  bucket     bucket name (with optional @region suffix, default is us-east-1)
  srcfile    path to source file
  targfile   path to target (dir if it ends with '/', relative to bucket root)
  acl        s3 access permissions (default: public-read)
  mime_type  optional mime-type (tries to guess if omitted)

Dependencies:
  To run, this shell script depends on command-line curl and openssl, as well
  as standard Unix tools

Examples:
  To upload file '~/blog/media/image.png' to bucket 'storage' in region
  'eu-central-1' with key (path relative to bucket) 'media/image.png':

    `basename $0` ACCESS SECRET storage@eu-central-1 \\
      ~/blog/image.png media/

  To upload file '~/blog/media/image.png' to public-writable bucket 'storage'
  in default region 'us-east-1' with key (path relative to bucket) 'x/y.png':

    `basename $0` '' '' storage ~/blog/image.png x/y.png

USAGE
    exit 0
}

guessmime()
{
    mime=`file -b --mime-type $1`
    if [ "$mime" = "text/plain" ]; then
        case $1 in
            *.css)           mime=text/css;;
            *.ttf|*.otf)     mime=application/font-sfnt;;
            *.woff)          mime=application/font-woff;;
            *.woff2)         mime=font/woff2;;
            *rss*.xml|*.rss) mime=application/rss+xml;;
            *)               if head $1 | grep '<html.*>' >/dev/null; then mime=text/html; fi;;
        esac
    fi
    printf "$mime"
}

if [ $# -lt 5 ]; then usage; fi

# Inputs.
aws_ak="$1"                                                              # access key
aws_sk="$2"                                                              # secret key
bucket=`printf $3 | awk 'BEGIN{FS="@"}{print $1}'`                       # bucket name
region=`printf $3 | awk 'BEGIN{FS="@"}{print ($2==""?"us-east-1":$2)}'`  # region name
srcfile="$4"                                                             # source file
targfile=`echo -n "$5" | sed "s/\/$/\/$(basename $srcfile)/"`            # target file
acl=${6:-'public-read'}                                                  # s3 perms
mime=${7:-"`guessmime "$srcfile"`"}                                      # mime type
md5=`openssl md5 -binary "$srcfile" | openssl base64`


# Create signature if not public upload.
key_and_sig_args=''
if [ "$aws_ak" != "" ] && [ "$aws_sk" != "" ]; then

    # Need current and file upload expiration date. Handle GNU and BSD date command style to get tomorrow's date.
    date=`date -u +%Y%m%dT%H%M%SZ`
    expdate=`if ! date -v+1d +%Y-%m-%d 2>/dev/null; then date -d tomorrow +%Y-%m-%d; fi`
    expdate_s=`printf $expdate | sed s/-//g` # without dashes, as we need both formats below
    service='s3'

    # Generate policy and sign with secret key following AWS Signature version 4, below
    p=$(cat <<POLICY | openssl base64
{ "expiration": "${expdate}T12:00:00.000Z",
  "conditions": [
    {"acl": "$acl" },
    {"bucket": "$bucket" },
    ["starts-with", "\$key", ""],
    ["starts-with", "\$content-type", ""],
    ["content-length-range", 1, `ls -l -H "$srcfile" | awk '{print $5}' | head -1`],
    {"content-md5": "$md5" },
    {"x-amz-date": "$date" },
    {"x-amz-credential": "$aws_ak/$expdate_s/$region/$service/aws4_request" },
    {"x-amz-algorithm": "AWS4-HMAC-SHA256" }
  ]
}
POLICY
    )

    # AWS4-HMAC-SHA256 signature
    s=`printf "$expdate_s"   | openssl sha256 -hmac "AWS4$aws_sk"           -hex | sed 's/(stdin)= //'`
    s=`printf "$region"      | openssl sha256 -mac HMAC -macopt hexkey:"$s" -hex | sed 's/(stdin)= //'`
    s=`printf "$service"     | openssl sha256 -mac HMAC -macopt hexkey:"$s" -hex | sed 's/(stdin)= //'`
    s=`printf "aws4_request" | openssl sha256 -mac HMAC -macopt hexkey:"$s" -hex | sed 's/(stdin)= //'`
    s=`printf "$p"           | openssl sha256 -mac HMAC -macopt hexkey:"$s" -hex | sed 's/(stdin)= //'`

    key_and_sig_args="-F X-Amz-Credential=$aws_ak/$expdate_s/$region/$service/aws4_request -F X-Amz-Algorithm=AWS4-HMAC-SHA256 -F X-Amz-Signature=$s -F X-Amz-Date=${date}"
fi


# Upload. Supports anonymous upload if bucket is public-writable, and keys are set to ''.
echo "Uploading: $srcfile ($mime) to $bucket:$targfile"
curl                            \
    -# -k                       \
    -F key=$targfile            \
    -F acl=$acl                 \
    $key_and_sig_args           \
    -F "Policy=$p"              \
    -F "Content-MD5=$md5"       \
    -F "Content-Type=$mime"     \
    -F "file=@$srcfile"         \
    https://${bucket}.s3.amazonaws.com/ | cat # pipe through cat so curl displays upload progress bar, *and* response
}

CleanUp()
{

if [[ -d ${results_directory} ]]; then
   /bin/rm -rf ${results_directory}
fi

if [[ -d ${dmg_file_location} ]]; then
   /bin/rm -rf ${dmg_file_location}
fi

}


LogGeneration

if [[ -f ${fileName} ]]; then
   S3Upload "$s3AccessKey" "$s3SecretKey" "$s3Bucket"@"$s3Region" ${fileName} "$dmg_name" "$s3acl" "$contentType"
   if [[ $? -eq 0 ]]; then
      echo "$dmg_name uploaded successfully to $s3Bucket."
   else
      echo "ERROR! Upload of $dmg_name failed!"
      error=1
   fi
else
    echo "ERROR! Creating $dmg_name failed! No upload attempted."
    error=1
fi

CleanUp

exit $error