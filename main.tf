locals {
  name = coalesce(module.this.name, var.name, "uploader")

  artifact_src_local_path  = var.artifact_src_local_path
  artifact_src_bucket_arn  = coalesce(var.artifact_src_bucket_arn, var.artifact_dst_bucket_arn)
  artifact_src_bucket_name = data.aws_arn.artifact_src_bucket.resource
  artifact_src_bucket_path = trim(var.artifact_src_bucket_path, "/")
  artifact_dst_bucket_arn  = var.artifact_dst_bucket_arn
  artifact_dst_bucket_name = data.aws_arn.artifact_dst_bucket.resource
  artifact_dst_bucket_path = trimprefix(var.artifact_dst_bucket_path, "/")

  aws_partition = one(data.aws_partition.current.*.partition)

  iam_role_policies = {
    access = one(data.aws_iam_policy_document.this.*.json)
  }

  iam_role_attachments = [
    "policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}

data "aws_partition" "current" {
  count = module.this.enabled ? 1 : 0
}

data "aws_arn" "artifact_src_bucket" {
  arn = local.artifact_src_bucket_arn
}

data "aws_arn" "artifact_dst_bucket" {
  arn = local.artifact_dst_bucket_arn
}

# ================================================================= artifact ===

resource "aws_s3_object" "artifact" {
  count = module.this.enabled ? 1 : 0

  bucket = local.artifact_src_bucket_name
  key    = local.artifact_src_bucket_path
  source = local.artifact_src_local_path
}

# tflint-ignore: terraform_unused_declarations
data "aws_lambda_invocation" "artifact" {
  count = module.this.enabled ? 1 : 0

  function_name = aws_lambda_function.this[0].function_name

  input = jsonencode({
    artifact_src_bucket_name = local.artifact_src_bucket_name
    artifact_src_bucket_path = local.artifact_src_bucket_path
    artifact_dst_bucket_name = local.artifact_dst_bucket_name
    artifact_dst_bucket_path = local.artifact_dst_bucket_path
  })

  depends_on = [
    aws_lambda_function.this,
    aws_s3_object.artifact,
  ]
}

# ================================================================= uploader ===

module "uploader_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name       = local.name
  attributes = local.name != "uploader" ? ["uploader"] : []
  context    = module.this.context
}

data "archive_file" "uploader" {
  count = module.uploader_label.enabled ? 1 : 0

  type        = "zip"
  source_file = "${path.module}/assets/uploader.py"
  output_path = "${path.module}/dist/uploader.zip"
}

resource "aws_lambda_function" "this" {
  count = module.uploader_label.enabled ? 1 : 0

  function_name    = module.uploader_label.id
  filename         = data.archive_file.uploader[0].output_path
  source_code_hash = data.archive_file.uploader[0].output_base64sha256
  handler          = "uploader.lambda_handler"
  runtime          = "python3.14"
  timeout          = 90
  role             = aws_iam_role.this[0].arn
  layers           = []

  tags = module.uploader_label.tags

  depends_on = [
    aws_cloudwatch_log_group.this,
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  count = module.uploader_label.enabled ? 1 : 0

  name              = "/aws/lambda/${module.uploader_label.id}"
  retention_in_days = 90

  tags = module.uploader_label.tags
}

# ---------------------------------------------------------------------- iam ---

resource "aws_iam_role" "this" {
  count = module.uploader_label.enabled ? 1 : 0

  name        = module.uploader_label.id
  description = ""

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { "Service" : "lambda.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = module.uploader_label.tags
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  for_each = toset(local.iam_role_attachments)

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:${local.aws_partition}:iam::aws:${each.key}"
}

resource "aws_iam_role_policy" "this" {
  for_each = local.iam_role_policies

  name   = each.key
  role   = resource.aws_iam_role.this[0].name
  policy = each.value
}

data "aws_iam_policy_document" "this" {
  count = module.uploader_label.enabled ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${local.artifact_src_bucket_arn}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${local.artifact_dst_bucket_arn}/*"
    ]
  }
}
