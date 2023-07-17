output "bucket_objects" {
  value = data.aws_s3_objects.website_assets.keys
}
