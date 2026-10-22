data "aws_iam_policy_document" "lambda_assume_role" {
  count = local.create_execution_role ? 1 : 0

  statement {
    sid     = "AllowLambdaServiceAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = local.create_execution_role ? 1 : 0

  name               = local.effective_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role[0].json
  description        = "Execution role for Lambda function ${var.function_name}"

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  count = local.create_execution_role ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  count = local.create_execution_role && var.enable_vpc_config ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = local.create_execution_role ? var.additional_policy_arns : toset([])

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "additional_inline" {
  count = local.create_execution_role && var.additional_policy_json != null ? 1 : 0

  name   = "${substr(var.function_name, 0, 40)}-additional-policy"
  role   = aws_iam_role.this[0].id
  policy = var.additional_policy_json
}

data "aws_partition" "current" {}