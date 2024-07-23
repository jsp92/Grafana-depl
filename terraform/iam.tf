// task execution assume role policy document
data "aws_iam_policy_document" "grafana_ecs_task_execution_assume_role" {
  statement {
    sid    = "AllowECSTasksToAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

// task execution role policy document
data "aws_iam_policy_document" "grafana_ecs_task_execution_role" {
  statement {
    sid       = "AllowECSToAuthenticateToECRInCentralAccount"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    sid       = "AllowSSMRead"
    effect    = "Allow"
    actions   = ["ssm:GetParameters"]
    resources = ["*"]
  }


  statement {
    sid    = "AllowECSToPullSportslinegrafanaImage"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = ["${aws_ecr_repository.grafana.arn}", ]
  }

  statement {
    sid    = "AllowECSToWriteLogsToCloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [aws_cloudwatch_log_group.grafana.arn]
  }

  statement {
    sid    = "AllowCloudWatchFullAccess"
    effect = "Allow"

    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]

    resources = ["*"]
  }
}

// task execution role
resource "aws_iam_role" "grafana_ecs_task_execution" {
  name               = "grafana-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.grafana_ecs_task_execution_assume_role.json
}

// task execution role policy
resource "aws_iam_role_policy" "grafana_ecs_task_execution" {
  name   = "grafana-ecs-task-execution"
  role   = aws_iam_role.grafana_ecs_task_execution.name
  policy = data.aws_iam_policy_document.grafana_ecs_task_execution_role.json
}

// task assume role policy document
data "aws_iam_policy_document" "grafana_ecs_task_assume_role" {
  statement {
    sid    = "AllowECSTasksToAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

// task role policy document
data "aws_iam_policy_document" "grafana_ecs_task_role" {
  statement {
    sid     = "AllowServiceToAccessSecretsFromSSM"
    effect  = "Allow"
    actions = ["ssm:GetParametersByPath"]

    resources = [
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter/grafana/*",
    ]
  }

  statement {
    sid       = "AllowAccessToKMSForDecryptingSSMParameters"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["arn:aws:kms:${var.region}:${var.account_id}:alias/aws/ssm"]
  }

  statement {
    sid    = "AllowCloudWatchFullAccess"
    effect = "Allow"

    actions = [
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowSSMRead"
    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = ["*"]
  }


  statement {
    sid    = "DenyEverythingElse"
    effect = "Deny"

    not_actions = [
      "kms:Decrypt",
      "ssm:GetParametersByPath",
      "sts:AssumeRole",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]

    resources = ["*"]
  }
}

// task role
resource "aws_iam_role" "grafana_ecs_task" {
  name               = "grafana-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.grafana_ecs_task_assume_role.json
}

// task role policy
resource "aws_iam_role_policy" "grafana_ecs_task" {
  name   = "grafana-ecs-task"
  role   = aws_iam_role.grafana_ecs_task.name
  policy = data.aws_iam_policy_document.grafana_ecs_task_role.json
}

// grafana role policy document
data "aws_iam_policy_document" "grafana_role" {
  statement {
    sid    = "AllowReadingMetricsFromCloudWatch"
    effect = "Allow"

    actions = [
      "cloudwatch:GetMetric*",
      "cloudwatch:ListMetrics",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowReadingTagsFromEC2"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]

    resources = ["*"]
  }
}
