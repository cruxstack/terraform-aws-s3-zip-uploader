# Terraform Module: AWS S3 ZIP Uploader

This Terraform module is a utility for uploading the contents of a ZIP file to
an AWS S3 bucket. It's especially useful when you need to manage an unknown
number of files at plan time, a scenario where Terraform's built-in capabilities
fall short.

## Features

- Handles an unknown number of files at plan time by working with ZIP files.
- Uploads a ZIP file from a local path to an S3 bucket.
- Unzips the ZIP file and uploads its contents to an S3 bucket.
- Provides customizable options for bucket names and paths.
- Automatically creates and configures necessary AWS resources.

This module offers a handy solution for deploying static websites, managing
large data sets, and handling other situations where the number of files can't
be determined in advance.

## Usage

```hcl
module "s3_zip_uploader" {
  source  = "cruxstack/s3-zip-uploader/aws"
  version = "x.x.x"

  artifact_src_local_path = "/path/to/yourfile.zip"
  artifact_dst_bucket_arn = "arn:aws:s3:::yourdestinationbucket"
}
```

## Inputs

This module uses the `cloudposse/label/null` module for naming and tagging
resources. As such, it also includes a `context.tf` file with additional
optional variables you can set. Refer to the [`cloudposse/label` documentation](https://registry.terraform.io/modules/cloudposse/label/null/latest)
for more details on these variables.

| Name                       | Description                                                                                                     | Type   | Default                     | Required |
|----------------------------|-----------------------------------------------------------------------------------------------------------------|--------|-----------------------------|----------|
| `artifact_src_bucket_arn`  | ARN of the S3 bucket to store the source artifact zip file. Defaults to the destination bucket if not provided. | string | `""`                        | No       |
| `artifact_src_bucket_path` | Path in the S3 bucket where the source artifact zip file is located.                                            | string | `"__upload__/artifact.zip"` | No       |
| `artifact_src_local_path`  | Local path of the artifact zip file where Terraform is executed.                                                | string | N/A                         | Yes      |
| `artifact_dst_bucket_arn`  | ARN of the destination S3 bucket to upload the contents of the zip file.                                        | string | N/A                         | Yes      |
| `artifact_dst_bucket_path` | Path in the destination S3 bucket to upload the contents of the zip file.                                       | string | `"/"`                       | No       |

## Outputs

_This module does not currently provide any outputs._

## Contributing

We welcome contributions to this project. For information on setting up a
development environment and how to make a contribution, see [CONTRIBUTING](./CONTRIBUTING.md)
documentation.
