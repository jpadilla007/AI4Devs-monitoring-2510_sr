# Integración de Datadog con AWS mediante Terraform

## 📋 Resumen de Cambios

Este documento describe la extensión del código Terraform para integrar **Datadog** con **AWS** y configurar monitoreo completo de la infraestructura, aplicaciones y logs.

### Cambios Realizados

#### 1. **Reorganización de Archivos Terraform**

Se ha reorganizado la configuración de Terraform para seguir las mejores prácticas:

- **`provider.tf`**: Configuración de proveedores (AWS y Datadog)
- **`variables.tf`**: Definición centralizada de todas las variables
- **`main.tf`**: Recursos principales y política IAM
- **`outputs.tf`**: Salidas de configuración
- **`datadog.tf`**: Recursos específicos de Datadog
- **`ec2.tf`**: Configuración de instancias EC2 (mejorada)
- **`security_groups.tf`**: Grupos de seguridad
- **`iam.tf`**: Configuración IAM
- **`dashboard.tf`**: Dashboards de Datadog
- **`s3.tf`**: Almacenamiento S3

#### 2. **Configuración del Proveedor Datadog**

```hcl
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
  validate = true
}
```

Se configura Datadog como proveedor oficial con validación habilitada.

#### 3. **Integración AWS-Datadog**

Se implementó la integración correcta entre AWS y Datadog:

- **Rol IAM**: Creación de un rol dedicado para Datadog con permisos específicos
- **External ID**: Uso de External ID para mayor seguridad
- **Política IAM**: Permisos completos para CloudWatch, Logs, EC2, etc.
- **Integración AWS**: Uso del recurso `datadog_integration_aws`

```hcl
resource "datadog_integration_aws" "aws_integration" {
  account_id = var.aws_account_id
  role_name  = aws_iam_role.datadog_integration_role.name
}
```

#### 4. **Instalación del Agente Datadog**

Se mejoró significativamente la instalación del agente en EC2:

**Cambios de Seguridad:**
- ✅ Eliminación de API keys hardcodeadas
- ✅ Uso de variables de entorno seguras desde Terraform
- ✅ Validación de archivos descargados
- ✅ Logging estructurado
- ✅ Manejo de errores mejorado

**Scripts Mejorados:**
- `scripts/backend_user_data.sh`: Instalación segura del agente en Backend
- `scripts/frontend_user_data.sh`: Instalación segura del agente en Frontend

#### 5. **Dashboards en Datadog**

Se crearon tres dashboards completos:

##### **A) Dashboard de Infraestructura**
- CPU Utilization (%)
- Network In (bytes/s)
- Network Out (bytes/s)
- Disk Read Operations
- Disk Write Operations
- Status Check Failed

##### **B) Dashboard de Aplicación**
- Backend Instance Status
- Frontend Instance Status
- Backend CPU Usage
- Frontend CPU Usage

##### **C) Dashboard de Logs**
- Visualización de logs de ambas instancias
- Filtrado por servicio
- Ordenamiento cronológico

#### 6. **Monitores (Alertas)**

Se configuraron tres monitores automáticos:

1. **Monitor de CPU Alto - Backend**
   - Threshold crítico: 80%
   - Threshold advertencia: 60%

2. **Monitor de CPU Alto - Frontend**
   - Threshold crítico: 80%
   - Threshold advertencia: 60%

3. **Monitor de Status Check Fallido**
   - Alertas inmediatas si fallan los checks de estado
   - Prioridad crítica

---

## 🔐 Seguridad

### Mejoras de Seguridad Implementadas

1. **Eliminación de Credenciales Hardcodeadas**
   ```bash
   # ❌ ANTES (INSEGURO)
   export DD_API_KEY='76cd5e07d41cec7b205a01ffbc26c5ae'
   
   # ✅ AHORA (SEGURO)
   export DD_API_KEY="${DD_API_KEY}"  # Variable de Terraform
   ```

2. **variables.tf - Uso de `sensitive = true`**
   ```hcl
   variable "datadog_api_key" {
     type      = string
     sensitive = true
   }
   ```

3. **External ID para Integración AWS-Datadog**
   ```hcl
   "Condition": {
     "StringEquals": {
       "sts:ExternalId": var.datadog_external_id
     }
   }
   ```

4. **IMDSv2 Obligatorio en EC2**
   ```hcl
   metadata_options {
     http_tokens = "required"
   }
   ```

---

## 📦 Requisitos

- Terraform >= 1.0
- AWS CLI configurado
- Cuenta en Datadog con API Key y App Key
- AWS Account ID

---

## 🚀 Cómo Desplegar

### 1. Configurar Variables de Entorno

```bash
export TF_VAR_datadog_api_key="tu-api-key-aqui"
export TF_VAR_datadog_app_key="tu-app-key-aqui"
export TF_VAR_aws_account_id="123456789012"
export TF_VAR_datadog_external_id="tu-external-id-aqui"  # Generado por Datadog
```

### 2. Inicializar Terraform

```bash
cd tf/
terraform init
```

### 3. Validar Configuración

```bash
terraform validate
terraform plan
```

### 4. Aplicar Cambios

```bash
terraform apply
```

### 5. Verificar Despliegue

```bash
# Ver outputs
terraform output

# Verificar agente Datadog en instancias EC2
ssh ec2-user@<public-ip> "sudo systemctl status datadog-agent"
```

---

## 📊 Dashboards

### Dashboard de Infraestructura
Muestra métricas en tiempo real de las instancias EC2:
- Utilización de CPU
- Tráfico de red (entrada y salida)
- Operaciones de disco
- Estado de los checks de salud

**Acceso:** Datadog → Dashboards → "lti-project - Infrastructure Dashboard"

### Dashboard de Aplicación
Monitoreo específico de los servicios Backend y Frontend:
- Estado de instancias
- CPU Usage por servicio
- Correlación con eventos de Datadog

**Acceso:** Datadog → Dashboards → "lti-project - Application Dashboard"

### Dashboard de Logs
Visualización centralizada de logs:
- Logs de ambos servicios
- Filtrado automático
- Timeline de eventos

**Acceso:** Datadog → Dashboards → "lti-project - Logs Dashboard"

---

## 🚨 Monitores y Alertas

Los monitores se configuran automáticamente al desplegar:

### Alertas Configuradas

1. **High CPU - Backend**: Notificación cuando CPU > 80%
2. **High CPU - Frontend**: Notificación cuando CPU > 80%
3. **Status Check Failed**: Notificación inmediata si fallan checks de estado

**Para recibir notificaciones:**
1. Agrega tu correo o Slack a Datadog
2. Configura las integraciones en Datadog
3. Los mensajes incluyen `@oncall @slack-channel`

---

## 📝 Ejemplos de Configuración

### Archivo de Variables (terraform.tfvars)

```hcl
aws_region   = "us-east-1"
environment  = "production"
project_name = "lti-project"

datadog_api_url          = "https://api.datadoghq.com"
datadog_site             = "datadoghq.com"

backend_instance_type  = "t2.micro"
frontend_instance_type = "t2.medium"

enable_aws_integration    = true
enable_datadog_monitoring = true
```

### Instalar Dependencias de Terraform

```bash
terraform init -upgrade
terraform init
```

---

## 🔧 Solución de Problemas

### Problema: El agente Datadog no se instala
**Solución:**
```bash
# En la instancia EC2
sudo systemctl status datadog-agent
sudo tail -f /var/log/datadog/agent.log
```

### Problema: No aparecen métricas en Datadog
**Solución:**
1. Verificar que las variables de entorno se pasaron correctamente
2. Esperar 5-10 minutos para que aparezcan las métricas
3. Verificar que la política IAM tiene permisos correctos

### Problema: Error de integración AWS
**Solución:**
1. Verificar que el `aws_account_id` es correcto
2. Verificar que el `datadog_external_id` coincide con el de Datadog
3. Consultar logs de Terraform: `terraform show`

---

## 📚 Archivos Modificados

### Nuevos/Modificados

| Archivo | Cambios |
|---------|---------|
| `provider.tf` | ✅ CREADO - Configuración de proveedores |
| `variables.tf` | ✅ CREADO - Variables centralizadas |
| `main.tf` | ✅ MEJORADO - Política IAM y integración AWS |
| `outputs.tf` | ✅ CREADO - Salidas de configuración |
| `datadog.tf` | ✅ CREADO - Recursos de Datadog |
| `ec2.tf` | ✅ MEJORADO - Paso seguro de variables |
| `scripts/backend_user_data.sh` | ✅ MEJORADO - Seguridad y logging |
| `scripts/frontend_user_data.sh` | ✅ MEJORADO - Seguridad y logging |

---

## 🎯 Próximos Pasos (Recomendaciones)

1. **Terraform Remote State**: Configurar S3 + DynamoDB para estado remoto
2. **Automatización CI/CD**: Integrar con Jenkins/GitHub Actions
3. **Alertas Adicionales**: Agregar monitores para latencia, errores, etc.
4. **Logs Agregados**: Configurar APM y Logs en Datadog
5. **Backup de Dashboards**: Exportar configuración a código

---

## 📞 Contacto y Soporte

Para más información sobre:
- **Terraform**: https://registry.terraform.io/
- **Datadog AWS Integration**: https://docs.datadoghq.com/es/integrations/amazon-web-services/
- **Datadog Terraform Provider**: https://registry.terraform.io/providers/DataDog/datadog/latest/docs

---

## ✅ Checklist de Despliegue

- [ ] Variables de entorno configuradas
- [ ] AWS CLI funcional
- [ ] Datadog API Key y App Key disponibles
- [ ] `terraform init` ejecutado
- [ ] `terraform validate` sin errores
- [ ] `terraform plan` revisado
- [ ] `terraform apply` ejecutado
- [ ] Dashboards visibles en Datadog
- [ ] Agente Datadog ejecutándose en EC2
- [ ] Métricas apareciendo en Datadog

---

**Última actualización:** 2026
**Estado:** ✅ Completado y Documentado
