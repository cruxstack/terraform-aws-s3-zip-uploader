# ================================================================== general ===

variable "artifact_src_bucket_arn" {
  type        = string
  description = <<-EOF
    ARN of the S3 bucket to store the source artifact zip file. Defaults to the destination bucket if not provided.
  EOF
  default     = ""
}

variable "artifact_src_bucket_path" {
  type        = string
  description = "Path in the S3 bucket where the source artifact zip file is located."
  default     = "__upload__/artifact.zip"
}

variable "artifact_src_local_path" {
  type        = string
  description = "Local path of the artifact zip file where Terraform is executed."
}

variable "artifact_dst_bucket_arn" {
  type        = string
  description = "ARN of the destination S3 bucket to upload the contents of the zip file."
}

variable "artifact_dst_bucket_path" {
  type        = string
  description = "Path in the destination S3 bucket to upload the contents of the zip file."
  default     = "/"
}
