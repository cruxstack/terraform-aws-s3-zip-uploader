module "artifact_packager" {
  source  = "sgtoj/artifact-packager/docker"
  version = "1.2.1"

  docker_build_context   = "${path.module}/fixtures/website"
  docker_build_target    = "package"
  artifact_src_type      = "directory"
  artifact_src_path      = "/opt/app/dist/"
  artifact_dst_directory = "${path.module}/dist"
}

resource "random_string" "website_bucket_random_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "example-tf-aws-zip-uploader-${random_string.website_bucket_random_suffix.result}"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

module "s3_zip_uploader" {
  source = "../../"

  artifact_src_local_path = module.artifact_packager.artifact_dst_path
  artifact_dst_bucket_arn = aws_s3_bucket.website_bucket.arn
}
