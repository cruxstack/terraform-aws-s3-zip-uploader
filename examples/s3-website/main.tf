locals {
  name = "tf-example-complete-${random_string.example_random_suffix.result}"
  tags = { tf-module = "cruxstack/s3-zip-uploader/aws", tf-module-example = "complete" }
}

# ================================================================== example ===

module "s3_zip_uploader" {
  source = "../../"

  artifact_src_local_path = module.artifact_packager.artifact_package_path
  artifact_dst_bucket_arn = aws_s3_bucket.website_bucket.arn

  depends_on = [
    module.artifact_packager
  ]
}

module "artifact_packager" {
  source  = "cruxstack/artifact-packager/docker"
  version = "1.3.6"

  docker_build_context   = "${path.module}/fixtures/website"
  docker_build_target    = "package"
  artifact_src_path      = "/tmp/package.zip"
  artifact_dst_directory = "${path.module}/dist"

  context = module.example_label.context # not required
}

# ===================================================== supporting-resources ===

module "example_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name        = "tf-example-complete-${random_string.example_random_suffix.result}"
  environment = "use1" # us-east-1
  tags        = local.tags
}

resource "random_string" "example_random_suffix" {
  length  = 6
  special = false
  upper   = false
}

# ----------------------------------------------------------------------- s3 ---

resource "aws_s3_bucket" "website_bucket" {
  bucket        = module.example_label.id
  force_destroy = true

  tags = module.example_label.tags
}

resource "aws_s3_bucket_website_configuration" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

data "aws_s3_objects" "website_assets" {
  bucket = aws_s3_bucket.website_bucket.id

  depends_on = [
    module.s3_zip_uploader
  ]
}
