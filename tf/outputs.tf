# ========================================
# Salidas (Outputs) de Terraform
# ========================================

# Backend Instance
output "backend_instance_id" {
  description = "ID de la instancia EC2 Backend"
  value       = aws_instance.backend.id
}

output "backend_instance_public_ip" {
  description = "IP pública de la instancia EC2 Backend"
  value       = aws_instance.backend.public_ip
}

output "backend_instance_private_ip" {
  description = "IP privada de la instancia EC2 Backend"
  value       = aws_instance.backend.private_ip
}

# Frontend Instance
output "frontend_instance_id" {
  description = "ID de la instancia EC2 Frontend"
  value       = aws_instance.frontend.id
}

output "frontend_instance_public_ip" {
  description = "IP pública de la instancia EC2 Frontend"
  value       = aws_instance.frontend.public_ip
}

output "frontend_instance_private_ip" {
  description = "IP privada de la instancia EC2 Frontend"
  value       = aws_instance.frontend.private_ip
}

# Datadog Integration
output "datadog_integration_enabled" {
  description = "¿Está habilitada la integración con Datadog?"
  value       = var.enable_aws_integration
}

output "datadog_integration_role_arn" {
  description = "ARN del rol IAM para la integración con Datadog"
  value       = var.enable_aws_integration ? aws_iam_role.datadog_integration_role[0].arn : null
}

output "datadog_integration_role_name" {
  description = "Nombre del rol IAM para la integración con Datadog"
  value       = var.enable_aws_integration ? aws_iam_role.datadog_integration_role[0].name : null
}

# Dashboards
output "infrastructure_dashboard_id" {
  description = "ID del dashboard de infraestructura en Datadog"
  value       = var.enable_datadog_monitoring ? datadog_dashboard.infrastructure_dashboard[0].id : null
}

output "application_dashboard_id" {
  description = "ID del dashboard de aplicación en Datadog"
  value       = var.enable_datadog_monitoring ? datadog_dashboard.application_dashboard[0].id : null
}

output "logs_dashboard_id" {
  description = "ID del dashboard de logs en Datadog"
  value       = var.enable_datadog_monitoring ? datadog_dashboard.logs_dashboard[0].id : null
}

# Monitores
output "high_cpu_backend_monitor_id" {
  description = "ID del monitor de CPU alto en Backend"
  value       = var.enable_datadog_monitoring ? datadog_monitor.high_cpu_backend[0].id : null
}

output "high_cpu_frontend_monitor_id" {
  description = "ID del monitor de CPU alto en Frontend"
  value       = var.enable_datadog_monitoring ? datadog_monitor.high_cpu_frontend[0].id : null
}

output "status_check_failed_monitor_id" {
  description = "ID del monitor de status check fallido"
  value       = var.enable_datadog_monitoring ? datadog_monitor.status_check_failed[0].id : null
}

# AWS Account Info
output "aws_account_id" {
  description = "ID de la cuenta AWS"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Región de AWS utilizada"
  value       = var.aws_region
}

# Datadog Policy
output "datadog_policy_arn" {
  description = "ARN de la política IAM de Datadog"
  value       = aws_iam_policy.datadog_policy.arn
}
