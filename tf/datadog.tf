# ========================================
# Integración AWS-Datadog
# ========================================

# Crear un rol IAM para que Datadog pueda acceder a los recursos de AWS
resource "aws_iam_role" "datadog_integration_role" {
  count = var.enable_aws_integration ? 1 : 0
  
  name               = "${var.project_name}-datadog-integration-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:${data.aws_partition.current.partition}:iam::464622532012:root"
        },
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "sts:ExternalId": var.datadog_external_id
          }
        }
      }
    ]
  })
  
  description = "Rol para la integración entre AWS y Datadog"
  tags = {
    Name = "${var.project_name}-datadog-integration-role"
  }
}

# Crear una variable para el External ID de Datadog
variable "datadog_external_id" {
  description = "External ID de Datadog para la integración segura"
  type        = string
  sensitive   = true
  default     = ""
}

# Attachar la política de Datadog al rol
resource "aws_iam_role_policy_attachment" "datadog_policy_attachment" {
  count      = var.enable_aws_integration ? 1 : 0
  role       = aws_iam_role.datadog_integration_role[0].name
  policy_arn = aws_iam_policy.datadog_policy.arn
}

# Integración de AWS con Datadog usando el provider de Datadog
resource "datadog_integration_aws" "aws_integration" {
  count    = var.enable_aws_integration ? 1 : 0
  account_id = var.aws_account_id
  role_name  = aws_iam_role.datadog_integration_role[0].name
  
  depends_on = [aws_iam_role_policy_attachment.datadog_policy_attachment]
}

# Integración para Logs de AWS con Datadog
resource "datadog_integration_aws_log_collection" "aws_logs" {
  count   = var.enable_aws_integration ? 1 : 0
  enabled = true
}

# ========================================
# Dashboards en Datadog
# ========================================

# Dashboard Principal: Monitoreo de Infraestructura EC2
resource "datadog_dashboard" "infrastructure_dashboard" {
  count        = var.enable_datadog_monitoring ? 1 : 0
  title        = "${var.project_name} - Infrastructure Dashboard"
  description  = "Dashboard para monitorización de infraestructura AWS EC2, métricas de rendimiento y estado de instancias"
  layout_type  = "grid"
  is_read_only = false

  widget {
    widget_layout {
      height = 13
      width  = 47
      x      = 0
      y      = 0
    }

    timeseries_definition {
      title       = "CPU Utilization (%)"
      title_size  = "16"
      title_align = "left"
      show_legend = true
      legend_size = "0"

      request {
        display_type = "line"
        q            = "avg:aws.ec2.cpuutilization{*} by {instance_id}"
        style {
          line_width = "normal"
          palette    = "dog_classic"
        }
      }

      request {
        query = "avg:aws.ec2.cpuutilization{*} by {instance_id}"
      }

      yaxis {
        label = "CPU %"
        scale = "linear"
      }

      marker {
        display_type = "warning line"
        label        = "Warning"
        value        = "60"
      }

      marker {
        display_type = "error line"
        label        = "Critical"
        value        = "80"
      }
    }
  }

  widget {
    widget_layout {
      height = 13
      width  = 47
      x      = 48
      y      = 0
    }

    timeseries_definition {
      title       = "Network In (bytes/s)"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        display_type = "line"
        q            = "avg:aws.ec2.network_in{*} by {instance_id}"
        style {
          line_width = "normal"
          palette    = "cool"
        }
      }

      yaxis {
        label = "Bytes/s"
        scale = "linear"
      }
    }
  }

  widget {
    widget_layout {
      height = 13
      width  = 47
      x      = 0
      y      = 14
    }

    timeseries_definition {
      title       = "Network Out (bytes/s)"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        display_type = "line"
        q            = "avg:aws.ec2.network_out{*} by {instance_id}"
        style {
          line_width = "normal"
          palette    = "warm"
        }
      }

      yaxis {
        label = "Bytes/s"
        scale = "linear"
      }
    }
  }

  widget {
    widget_layout {
      height = 13
      width  = 47
      x      = 48
      y      = 14
    }

    timeseries_definition {
      title       = "Disk Read Operations"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        display_type = "line"
        q            = "avg:aws.ec2.disk_read_ops{*} by {instance_id}"
        style {
          line_width = "normal"
          palette    = "purple"
        }
      }

      yaxis {
        label = "Operations"
        scale = "linear"
      }
    }
  }

  widget {
    widget_layout {
      height = 13
      width  = 47
      x      = 0
      y      = 28
    }

    timeseries_definition {
      title       = "Disk Write Operations"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        display_type = "line"
        q            = "avg:aws.ec2.disk_write_ops{*} by {instance_id}"
        style {
          line_width = "normal"
          palette    = "orange"
        }
      }

      yaxis {
        label = "Operations"
        scale = "linear"
      }
    }
  }

  widget {
    widget_layout {
      height = 13
      width  = 47
      x      = 48
      y      = 28
    }

    timeseries_definition {
      title       = "Status Check Failed"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        display_type = "line"
        q            = "avg:aws.ec2.status_check_failed{*} by {instance_id}"
        style {
          line_width = "normal"
          palette    = "red"
        }
      }

      yaxis {
        label = "Failed Checks"
        scale = "linear"
      }
    }
  }
}

# Dashboard de Aplicación: Backend y Frontend
resource "datadog_dashboard" "application_dashboard" {
  count        = var.enable_datadog_monitoring ? 1 : 0
  title        = "${var.project_name} - Application Dashboard"
  description  = "Dashboard para monitorización de la aplicación, estado de servicios y logs"
  layout_type  = "grid"
  is_read_only = false

  widget {
    widget_layout {
      height = 10
      width  = 30
      x      = 0
      y      = 0
    }

    status_definition {
      title       = "Backend Instance Status"
      title_size  = "16"
      title_align = "left"
      show_label  = true

      request {
        q = "avg:aws.ec2.instance_state{aws_tag:name:lti-project-backend}"
      }

      color_preference = "background"
    }
  }

  widget {
    widget_layout {
      height = 10
      width  = 30
      x      = 31
      y      = 0
    }

    status_definition {
      title       = "Frontend Instance Status"
      title_size  = "16"
      title_align = "left"
      show_label  = true

      request {
        q = "avg:aws.ec2.instance_state{aws_tag:name:lti-project-frontend}"
      }

      color_preference = "background"
    }
  }

  widget {
    widget_layout {
      height = 13
      width  = 62
      x      = 0
      y      = 11
    }

    timeseries_definition {
      title       = "Backend Instance CPU Usage"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        display_type = "line"
        q            = "avg:aws.ec2.cpuutilization{aws_tag:name:lti-project-backend} by {instance_id}"
        style {
          line_width = "normal"
          palette    = "blue"
        }
      }

      yaxis {
        label = "CPU %"
        scale = "linear"
      }
    }
  }

  widget {
    widget_layout {
      height = 13
      width  = 62
      x      = 0
      y      = 25
    }

    timeseries_definition {
      title       = "Frontend Instance CPU Usage"
      title_size  = "16"
      title_align = "left"
      show_legend = true

      request {
        display_type = "line"
        q            = "avg:aws.ec2.cpuutilization{aws_tag:name:lti-project-frontend} by {instance_id}"
        style {
          line_width = "normal"
          palette    = "green"
        }
      }

      yaxis {
        label = "CPU %"
        scale = "linear"
      }
    }
  }
}

# Dashboard de Logs: Monitoreo de Logs de Aplicación
resource "datadog_dashboard" "logs_dashboard" {
  count        = var.enable_datadog_monitoring ? 1 : 0
  title        = "${var.project_name} - Logs Dashboard"
  description  = "Dashboard para visualización y análisis de logs de la aplicación"
  layout_type  = "ordered"
  is_read_only = false

  widget {
    log_stream_definition {
      title       = "Application Logs"
      title_size  = "16"
      title_align = "left"
      query       = "service:backend OR service:frontend"
      indexes     = ["*"]
      sort {
        column = "timestamp"
        order  = "desc"
      }
    }
  }
}

# ========================================
# Monitores (Alertas) en Datadog
# ========================================

# Monitor para CPU elevada en Backend
resource "datadog_monitor" "high_cpu_backend" {
  count   = var.enable_datadog_monitoring ? 1 : 0
  name    = "${var.project_name}: Backend - CPU usage is high"
  type    = "metric alert"
  message = "El uso de CPU en la instancia Backend es muy alto.\nInstancia: {{instance_id.name}}\nCPU actual: {{value}}%\n\n@oncall @slack-channel"

  query = "avg(last_5m):avg:aws.ec2.cpuutilization{aws_tag:name:lti-project-backend} by {instance_id} > 80"

  thresholds {
    critical = 80
    warning  = 60
  }

  tags = [
    "environment:${var.environment}",
    "application:backend",
    "service:monitoring"
  ]

  priority = 2
}

# Monitor para CPU elevada en Frontend
resource "datadog_monitor" "high_cpu_frontend" {
  count   = var.enable_datadog_monitoring ? 1 : 0
  name    = "${var.project_name}: Frontend - CPU usage is high"
  type    = "metric alert"
  message = "El uso de CPU en la instancia Frontend es muy alto.\nInstancia: {{instance_id.name}}\nCPU actual: {{value}}%\n\n@oncall @slack-channel"

  query = "avg(last_5m):avg:aws.ec2.cpuutilization{aws_tag:name:lti-project-frontend} by {instance_id} > 80"

  thresholds {
    critical = 80
    warning  = 60
  }

  tags = [
    "environment:${var.environment}",
    "application:frontend",
    "service:monitoring"
  ]

  priority = 2
}

# Monitor para Status Check Failed
resource "datadog_monitor" "status_check_failed" {
  count   = var.enable_datadog_monitoring ? 1 : 0
  name    = "${var.project_name}: EC2 Instance - Status check failed"
  type    = "metric alert"
  message = "Status check ha fallado en la instancia: {{instance_id.name}}\n\n@oncall @slack-channel"

  query = "avg(last_5m):avg:aws.ec2.status_check_failed{*} by {instance_id} > 0"

  thresholds {
    critical = 0
  }

  tags = [
    "environment:${var.environment}",
    "service:monitoring"
  ]

  priority = 1
}
