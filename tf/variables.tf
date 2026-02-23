# Variables de Configuración AWS
variable "aws_region" {
  description = "Región de AWS donde se crearán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "lti-project"
}

# Variables de Datadog
variable "datadog_api_key" {
  description = "API Key de Datadog (usar variable de entorno TF_VAR_datadog_api_key)"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "App Key de Datadog (usar variable de entorno TF_VAR_datadog_app_key)"
  type        = string
  sensitive   = true
}

variable "datadog_api_url" {
  description = "URL de la API de Datadog según la región"
  type        = string
  default     = "https://api.datadoghq.com" # Cambiar a https://api.datadoghq.eu para EU
}

variable "datadog_site" {
  description = "Sitio de Datadog (datadoghq.com o datadoghq.eu)"
  type        = string
  default     = "datadoghq.com"
}

# Variables de Configuración EC2
variable "backend_instance_type" {
  description = "Tipo de instancia para el servidor backend"
  type        = string
  default     = "t2.micro"
}

variable "frontend_instance_type" {
  description = "Tipo de instancia para el servidor frontend"
  type        = string
  default     = "t2.medium"
}

variable "enable_datadog_monitoring" {
  description = "Habilitar monitoreo con Datadog"
  type        = bool
  default     = true
}

# Variables de Integración AWS-Datadog
variable "aws_account_id" {
  description = "ID de la cuenta AWS"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^\\d{12}$", var.aws_account_id))
    error_message = "aws_account_id debe ser un número de 12 dígitos."
  }
}

variable "datadog_external_id" {
  description = "External ID de Datadog para la integración segura"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.datadog_external_id) > 0
    error_message = "datadog_external_id no debe estar vacío."
  }
}

variable "enable_aws_integration" {
  description = "Habilitar integración entre AWS y Datadog"
  type        = bool
  default     = true
}
