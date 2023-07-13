# Terraform Module Example

## Example: Deploying a Static Website to S3

This example demonstrates how to use the `terraform-aws-s3-zip-uploader` module
to deploy a static website to an S3 bucket.

The Terraform configuration uses a Dockerfile to build a static website, which
is then packaged into a ZIP file. The `artifact_builder` module handles the
Docker build and the packaging of the build artifacts. The output is a ZIP file
saved to a local directory.

The `terraform-aws-s3-zip-uploader` module is then used to upload this ZIP file
to an AWS S3 bucket and extract its contents into the root of the bucket. This
is done using an AWS Lambda function, which is created and managed by the
module.

The S3 bucket is configured to serve a static website, with `index.html` as the
index document. After running this Terraform configuration, you should be able
to access the website by navigating to the S3 bucket's website endpoint in your
web browser.

This example clearly shows the usefulness of the `terraform-aws-s3-zip-uploader`
module in real-world scenarios, demonstrating how it can be used to automate the
process of deploying static websites to S3.
