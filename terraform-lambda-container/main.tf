# current region, used in the IAM condition below
data "aws_region" "current" {}

locals {
  log_group_name = "/aws/lambda/${var.function_name}"

  # tags applied to every resource in this module
  common_tags = merge(
    {
      Name      = var.function_name
      ManagedBy = "terraform"
      Module    = "terraform-lambda-container"
    },
    var.tags,
  )
}

# create the log group ourselves to control retention, tags and encryption
resource "aws_cloudwatch_log_group" "this" {
  name              = local.log_group_name
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.log_kms_key_arn

  tags = local.common_tags
}

# only the Lambda service can assume this role
data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# dedicated execution role for the function
resource "aws_iam_role" "this" {
  name                 = "${var.function_name}-role"
  description          = "Execution role for the ${var.function_name} Lambda function."
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  max_session_duration = 3600

  tags = local.common_tags
}

# least-privilege policy: write logs + manage the VPC network interfaces
data "aws_iam_policy_document" "execution" {
  # write to this function's log group only
  statement {
    sid    = "WriteFunctionLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.this.arn,
      "${aws_cloudwatch_log_group.this.arn}:*",
    ]
  }

  # required for a VPC Lambda to create/remove its ENIs; scoped to this region
  statement {
    sid    = "ManageVpcEni"
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [data.aws_region.current.name]
    }
  }
}

resource "aws_iam_policy" "execution" {
  name        = "${var.function_name}-execution"
  description = "Least-privilege execution policy for ${var.function_name}."
  policy      = data.aws_iam_policy_document.execution.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.execution.arn
}

# dedicated security group: no inbound, outbound HTTPS only
resource "aws_security_group" "this" {
  name        = "${var.function_name}-sg"
  description = "Lambda security group for ${var.function_name}: no ingress, HTTPS egress only."
  vpc_id      = var.vpc_id

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

# allow outbound HTTPS only (to reach AWS service endpoints)
resource "aws_vpc_security_group_egress_rule" "https_out" {
  security_group_id = aws_security_group.this.id
  description       = "Allow outbound HTTPS to AWS service endpoints."
  ip_protocol       = "tcp"
  from_port         = var.egress_port
  to_port           = var.egress_port
  cidr_ipv4         = var.egress_cidr

  tags = local.common_tags
}

# container-image Lambda placed in the private subnets
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = "Container-image Lambda ${var.function_name} running in private subnets."
  role          = aws_iam_role.this.arn

  package_type  = "Image"
  image_uri     = var.image_uri
  architectures = var.architectures

  memory_size = var.memory_size
  timeout     = var.timeout

  # run inside the VPC using our private subnets and security group
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.this.id]
  }

  # only add the environment block when variables are provided
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  tags = local.common_tags

  # make sure the log group and policy exist before the function
  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.execution,
  ]
}
