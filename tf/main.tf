# ========================================
# Política de IAM para la Integración AWS-Datadog
# ========================================
# Esta política permite a Datadog acceder a recursos de AWS
resource "aws_iam_policy" "datadog_policy" {
  name        = "${var.project_name}-datadog-policy"
  description = "Política para permitir a Datadog acceder a CloudWatch, Logs y recursos de EC2"
  
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "autoscaling:Describe*",
          "cloudformation:GetStackPolicy",
          "cloudformation:GetStackResource",
          "cloudformation:ListStackResources",
          "cloudformation:ListStacks",
          "cloudformation:DescribeStacks",
          "cloudtrail:LookupEvents",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "directconnect:Describe*",
          "dynamodb:ListTables",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeStream",
          "ec2:Describe*",
          "ecs:Describe*",
          "ecs:List*",
          "elasticache:Describe*",
          "elasticloadbalancing:Describe*",
          "elasticmapreduce:ListInstances",
          "elasticmapreduce:ListClusters",
          "elasticmapreduce:DescribeCluster",
          "elasticmapreduce:DescribeStep",
          "health:DescribeEvents",
          "health:DescribeEventDetails",
          "kinesis:List*",
          "kinesis:Describe*",
          "lambda:List*",
          "lambda:GetPolicy",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:PutSubscriptionFilter",
          "logs:DeleteSubscriptionFilter",
          "logs:TestMetricFilter",
          "logs:DescribeResourcePolicies",
          "logs:GetResourcePolicy",
          "rds:Describe*",
          "rds:ListTagsForResource",
          "route53:List*",
          "route53:Get*",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets",
          "s3:GetBucketTagging",
          "s3:ListBucket",
          "s3:GetLifecycleConfiguration",
          "sns:List*",
          "sqs:ListQueues",
          "sqs:GetQueueAttributes",
          "sqs:ListQueueTags",
          "states:ListStateMachines",
          "states:DescribeStateMachine",
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues"
        ],
        "Resource": "*"
      }
    ]
  })
}

# ========================================
# Datos para obtener la información de la cuenta AWS
# ========================================
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# ========================================
# Obtener instancias EC2 en ejecución
# ========================================
data "aws_instances" "all" {
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

