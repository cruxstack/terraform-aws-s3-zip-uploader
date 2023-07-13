# ================================================================== general ===

variable "artifact_src_bucket_arn" {
  description = "The ARN of the S3 bucket where the source artifact zip file will be stored, to be retrieved by the Lambda function performing the upload to the destination S3 bucket. If not provided, the source bucket is assumed to be the same as the destination bucket."
  type        = string
  default     = ""
}

variable "artifact_src_bucket_path" {
  description = "The path within the S3 bucket where the source artifact zip file will be located, to be retrieved by the Lambda function performing the upload to the destination S3 bucket."
  type        = string
  default     = "__upload__/artifact.zip"
}

variable "artifact_src_local_path" {
  description = "The local path of the artifact zip file on the machine where Terraform is executed."
  type        = string
}

variable "artifact_dst_bucket_arn" {
  description = "The ARN of the destination S3 bucket where the contents of the zip file will be uploaded."
  type        = string
}

variable "artifact_dst_bucket_path" {
  description = "The path within the destination S3 bucket where the contents of the zip file will be uploaded."
  type        = string
  default     = "/"
}
