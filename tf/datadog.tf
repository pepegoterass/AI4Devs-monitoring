# Data source to get AWS account ID
data "aws_caller_identity" "current" {}

# IAM Role for Datadog AWS Integration
resource "aws_iam_role" "datadog_integration_role" {
  name               = "DatadogIntegrationRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::464622532012:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.datadog_external_id
          }
        }
      }
    ]
  })

  tags = {
    Name        = "DatadogIntegrationRole"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# IAM Policy for Datadog monitoring
resource "aws_iam_role_policy" "datadog_integration_policy" {
  name = "DatadogIntegrationPolicy"
  role = aws_iam_role.datadog_integration_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "apigateway:GET",
          "autoscaling:Describe*",
          "budgets:ViewBudget",
          "cloudfront:GetDistributionConfig",
          "cloudfront:ListDistributions",
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetTrailStatus",
          "cloudtrail:LookupEvents",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "codedeploy:List*",
          "codedeploy:BatchGet*",
          "directconnect:Describe*",
          "dynamodb:List*",
          "dynamodb:Describe*",
          "ec2:Describe*",
          "ecs:Describe*",
          "ecs:List*",
          "elasticache:Describe*",
          "elasticache:List*",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeTags",
          "elasticloadbalancing:Describe*",
          "elasticmapreduce:List*",
          "elasticmapreduce:Describe*",
          "es:ListTags",
          "es:ListDomainNames",
          "es:DescribeElasticsearchDomains",
          "health:DescribeEvents",
          "health:DescribeEventDetails",
          "health:DescribeAffectedEntities",
          "kinesis:List*",
          "kinesis:Describe*",
          "lambda:AddPermission",
          "lambda:GetPolicy",
          "lambda:List*",
          "lambda:RemovePermission",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DeleteLogGroup",
          "logs:DeleteLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:FilterLogEvents",
          "logs:PutLogEvents",
          "logs:TestMetricFilter",
          "organizations:DescribeOrganization",
          "rds:Describe*",
          "rds:List*",
          "redshift:DescribeClusters",
          "redshift:DescribeLoggingStatus",
          "route53:List*",
          "s3:GetBucketLogging",
          "s3:GetBucketLocation",
          "s3:GetBucketNotification",
          "s3:GetBucketTagging",
          "s3:ListAllMyBuckets",
          "s3:PutBucketNotification",
          "ses:Get*",
          "sns:List*",
          "sns:Publish",
          "sqs:ListQueues",
          "support:*",
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues",
          "xray:BatchGetTraces",
          "xray:GetTraceSummaries"
        ]
        Resource = "*"
      }
    ]
  })
}

# Datadog AWS Integration
resource "datadog_integration_aws" "main" {
  account_id  = data.aws_caller_identity.current.account_id
  role_name   = aws_iam_role.datadog_integration_role.name
  filter_tags = ["env:production"]
  host_tags   = ["env:production", "project:lti-monitoring"]
  
  account_specific_namespace_rules = {
    auto_scaling = false
    opsworks     = false
  }

  depends_on = [
    aws_iam_role.datadog_integration_role,
    aws_iam_role_policy.datadog_integration_policy
  ]
}

# Datadog Dashboard for AWS Infrastructure Monitoring
resource "datadog_dashboard" "aws_infrastructure" {
  title       = "LTI AWS Infrastructure Monitoring"
  description = "Dashboard for monitoring LTI project AWS infrastructure including EC2, RDS, and application metrics"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "EC2 CPU Utilization"
      request {
        q = "avg:aws.ec2.cpuutilization{env:production} by {host}"
        display_type = "line"
        style {
          palette = "dog_classic"
        }
      }
      yaxis {
        min = "0"
        max = "100"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "EC2 Memory Utilization"
      request {
        q = "avg:system.mem.pct_usable{env:production} by {host}"
        display_type = "line"
        style {
          palette = "dog_classic"
        }
      }
      yaxis {
        min = "0"
        max = "100"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Network In/Out"
      request {
        q = "avg:aws.ec2.network_in{env:production} by {host}"
        display_type = "line"
        style {
          palette = "blue"
        }
      }
      request {
        q = "avg:aws.ec2.network_out{env:production} by {host}"
        display_type = "line"
        style {
          palette = "orange"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Disk I/O"
      request {
        q = "avg:system.io.r_s{env:production} by {host}"
        display_type = "line"
        style {
          palette = "green"
        }
      }
      request {
        q = "avg:system.io.w_s{env:production} by {host}"
        display_type = "line"
        style {
          palette = "red"
        }
      }
    }
  }

  widget {
    query_value_definition {
      title = "Total EC2 Instances"
      request {
        q = "count:aws.ec2.host{env:production}"
        aggregator = "last"
      }
      autoscale = true
    }
  }

  widget {
    toplist_definition {
      title = "Top EC2 Instances by CPU"
      request {
        q = "top(avg:aws.ec2.cpuutilization{env:production} by {host}, 10, 'mean', 'desc')"
      }
    }
  }

  tags = ["env:production", "project:lti-monitoring", "created-by:terraform"]
}

# Datadog Monitor for High CPU Usage
resource "datadog_monitor" "high_cpu" {
  name    = "LTI High CPU Usage Alert"
  type    = "metric alert"
  message = "CPU usage is above 80% on {{host.name}} @slack-alerts"

  query = "avg(last_5m):avg:aws.ec2.cpuutilization{env:production} by {host} > 80"

  monitor_thresholds {
    warning  = 70
    critical = 80
  }

  notify_audit = false
  timeout_h    = 60
  include_tags = true

  tags = ["env:production", "project:lti-monitoring", "alert:cpu"]
}

# Datadog Monitor for High Memory Usage
resource "datadog_monitor" "high_memory" {
  name    = "LTI High Memory Usage Alert"
  type    = "metric alert"
  message = "Memory usage is above 85% on {{host.name}} @slack-alerts"

  query = "avg(last_5m):avg:system.mem.pct_usable{env:production} by {host} < 15"

  monitor_thresholds {
    warning  = 20
    critical = 15
  }

  notify_audit = false
  timeout_h    = 60
  include_tags = true

  tags = ["env:production", "project:lti-monitoring", "alert:memory"]
}

# Output important values
output "datadog_external_id" {
  description = "External ID for Datadog AWS integration"
  value       = var.datadog_external_id
}

output "datadog_role_arn" {
  description = "ARN of the Datadog integration role"
  value       = aws_iam_role.datadog_integration_role.arn
}

output "datadog_dashboard_url" {
  description = "URL of the Datadog dashboard"
  value       = "https://app.datadoghq.com/dashboard/${datadog_dashboard.aws_infrastructure.id}"
}