module "artifact_packager" {
  source  = "cruxstack/artifact-packager/docker"
  version = "1.2.1"

  docker_build_context   = "${path.module}/fixtures/website"
  docker_build_target    = "package"
  artifact_src_path      = "/tmp/package.zip"
  artifact_dst_directory = "${path.module}/dist"
}

resource "random_string" "website_bucket_random_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "website_bucket" {
  bucket        = "example-tf-aws-zip-uploader-${random_string.website_bucket_random_suffix.result}"
  force_destroy = true

  website {
    index_document = "index.html"
  }
}

module "s3_zip_uploader" {
  source = "../../"

  artifact_src_local_path = module.artifact_packager.artifact_package_path
  artifact_dst_bucket_arn = aws_s3_bucket.website_bucket.arn

  depends_on = [
    module.artifact_packager
  ]
}

data "aws_s3_objects" "website_assets" {
  bucket = aws_s3_bucket.website_bucket.id
}
