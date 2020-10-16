This is a log collection script which performs the following tasks:

* Collects a sysdiagnose file.
* Creates a read-only compressed disk image containing the sysdiagnose file.
* Uploads the compressed disk image to a specified S3 bucket.
* Cleans up the directories and files created by the script.

You will need to provide the following information to successfully upload
to an S3 bucket:

* S3 bucket name
* AWS region for the S3 bucket
* AWS programmatic user's access key and secret access key
* The S3 ACL used on the bucket

The AWS programmatic user must have at minimum the following access rights to the specified S3 bucket:

* `s3:ListBucket`
* `s3:PutObject`
* `s3:PutObjectAcl`

The AWS programmatic user must have at minimum the following access rights to all S3 buckets in the account:

* `s3:ListAllMyBuckets`

These access rights will allow the AWS programmatic user the ability to do the following:

1. Identify the correct S3 bucket
1. Write the uploaded file to the S3 bucket

**Note:** The AWS programmatic user would not have the ability to read the contents of the S3 bucket.

Information on S3 ACLs can be found via the link below:
[https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl)

By default, the ACL should be the one listed below:

`private`
