# 🔗 Datadog-AWS Prompts Utilizados

**Fecha:** Febrero 2026
**Proyecto:** AI4Devs Monitoring
**Objetivo:** Documentar los prompts utilizados para generar la integración Datadog-AWS en Terraform

---

## 📋 Tabla de Contenidos

1. [Prompts de Configuración](#prompts-de-configuración)
2. [Prompts de Integración](#prompts-de-integración)
3. [Prompts de Dashboards](#prompts-de-dashboards)
4. [Prompts de Monitoreo](#prompts-de-monitoreo)
5. [Prompts de Seguridad](#prompts-de-seguridad)
6. [Lecciones Aprendidas](#lecciones-aprendidas)

---

## Prompts de Configuración

### 1. Configuración del Proveedor Datadog

**Prompt:**
```
Crea una configuración de Terraform para el proveedor Datadog con:
- API Key y App Key desde variables
- Soporte para diferentes regiones (US y EU)
- Validación habilitada
- Configuración segura sin hardcodeo de credenciales
- Sigue las mejores prácticas de Terraform
```

**Resultado:**
```hcl
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
  validate = true
}
```

### 2. Variables Centralizadas

**Prompt:**
```
Genera todas las variables de Terraform necesarias para:
- AWS (región, entorno, proyecto)
- Datadog (API key, App key, site)
- EC2 (tipos de instancia)
- Integración AWS-Datadog

Incluye:
- Descripciones claras
- Valores por defecto sensatos
- Marcas de sensitive donde sea necesario
- Validaciones de tipos
```

**Resultado:**
Archivo `variables.tf` con 15+ variables bien organizadas.

---

## Prompts de Integración

### 3. Integración AWS-Datadog

**Prompt:**
```
Crea la integración AWS-Datadog en Terraform con:
- Rol IAM dedicado para Datadog
- External ID para seguridad
- Política IAM con permisos mínimos necesarios para:
  * CloudWatch
  * EC2
  * Logs
  * AutoScaling
  * DynamoDB
  * RDS
  * S3
- Integración usando datadog_integration_aws
- Integración de logs usando datadog_integration_aws_log_collection

Sigue la documentación oficial de AWS-Datadog:
https://docs.datadoghq.com/es/integrations/amazon-web-services/
```

**Resultado:**
Archivo `datadog.tf` con:
- Rol IAM: `aws_iam_role` + `aws_iam_role_policy_attachment`
- Integración: `datadog_integration_aws`
- Logs: `datadog_integration_aws_log_collection`

**Detalle de Políticas IAM Generadas:**
```
- autoscaling:Describe*
- cloudformation:*
- cloudtrail:LookupEvents
- cloudwatch:GetMetricData
- cloudwatch:ListMetrics
- directconnect:Describe*
- dynamodb:*
- ec2:Describe*
- ecs:Describe*
- elasticache:Describe*
- elasticloadbalancing:Describe*
- kinesis:List*
- lambda:List*
- logs:*
- rds:Describe*
- route53:*
- s3:*
- sns:List*
- sqs:ListQueues
- tag:Get*
```

---

## Prompts de Dashboards

### 4. Dashboard de Infraestructura

**Prompt:**
```
Crea un dashboard en Datadog usando Terraform que muestre:
- Utilización de CPU (por instance_id)
- Tráfico de red entrante (bytes/s)
- Tráfico de red saliente (bytes/s)
- Operaciones de lectura en disco
- Operaciones de escritura en disco
- Status checks fallidos

Características:
- Título: "{project_name} - Infrastructure Dashboard"
- Tipo de layout: grid
- 6 widgets con timeseries
- Marcadores de advertencia en CPU (60%) y crítico (80%)
- Colores distinguibles (paleta dog_classic y custom)
- Leyendas visibles
```

**Resultado:**
Dashboard con 6 widgets timeseries, cada uno con:
- Consulta MQL correcta
- Estilos de línea apropiados
- Ejes Y etiquetados
- Marcadores de umbral

### 5. Dashboard de Aplicación

**Prompt:**
```
Crea un segundo dashboard en Datadog que muestre:
- Estado de Backend (status check)
- Estado de Frontend (status check)
- Uso de CPU del Backend
- Uso de CPU del Frontend

Características:
- Widgets de estado (status_definition)
- Widgets de tiempo real (timeseries)
- Filtrado por tags: aws_tag:name:lti-project-backend/frontend
- Colores diferenciados por servicio
```

**Resultado:**
Dashboard con:
- 2 widgets de estado
- 2 widgets de timeseries
- Filtering por tags de AWS

### 6. Dashboard de Logs

**Prompt:**
```
Crea un tercer dashboard para visualizar logs:
- Log stream que muestre logs de backend y frontend
- Consulta: service:backend OR service:frontend
- Ordenamiento: descendiente por timestamp
- Título: "{project_name} - Logs Dashboard"
```

**Resultado:**
Widget de `log_stream_definition` con consulta MQL y ordenamiento.

---

## Prompts de Monitoreo

### 7. Monitores de Alerta

**Prompt:**
```
Crea tres monitores (alertas) en Datadog usando Terraform:

1. CPU Alto - Backend:
   - Métrica: aws.ec2.cpuutilization
   - Filtro: aws_tag:name:lti-project-backend
   - Ventana: últimos 5 minutos
   - Threshold crítico: 80%
   - Threshold advertencia: 60%

2. CPU Alto - Frontend:
   - Métrica: aws.ec2.cpuutilization
   - Filtro: aws_tag:name:lti-project-frontend
   - Ventana: últimos 5 minutos
   - Threshold crítico: 80%
   - Threshold advertencia: 60%

3. Status Check Fallido:
   - Métrica: aws.ec2.status_check_failed
   - Condition: > 0
   - Relación: any
   - Prioridad: crítica

Mensajes:
- Incluir información contexual (instance_id, valor actual)
- Menciones: @oncall @slack-channel
- Tags por aplicación
```

**Resultado:**
Tres recursos `datadog_monitor` con:
- Tipos de alerta: `metric alert`
- Umbrales críticos y de advertencia
- Mensajes templated
- Tags organizacionales

---

## Prompts de Seguridad

### 8. Eliminación de Credenciales Hardcodeadas

**Prompt:**
```
Actualiza los scripts de usuario EC2 para:
- Remover las API keys hardcodeadas
- Usar variables de entorno desde Terraform
- Implementar logging estructurado
- Agregar manejo de errores
- Validar descarga de archivos
- Mostrar timestamps en logs

Cambios específicos:
- De: export DD_API_KEY='76cd5e07d41cec7b205a01ffbc26c5ae'
- A: export DD_API_KEY="${DD_API_KEY}"

Mantener:
- Instalación del agente Datadog
- Instalación de Docker
- Despliegue de aplicaciones
- Timestamp para forzar actualizaciones
```

**Resultado:**
Scripts mejorados:
- `scripts/backend_user_data.sh`
- `scripts/frontend_user_data.sh`

Con:
- Logging con timestamps
- Uso de variables de entorno
- `set -e` para error handling
- Comentarios explicativos
- Esperas entre operaciones

### 9. Paso Seguro de Variables a EC2

**Prompt:**
```
Actualiza el recurso aws_instance en Terraform para:
- Pasar variables de Datadog de forma segura
- Usar templatefile() correctamente
- Codificar user_data en base64
- Usar path.module para rutas relativas
- Habilitar monitoreo detallado (detailed monitoring)
- Usar IMDSv2 (metadata_options)
- Identificar instancias por tags
- Agregar depends_on para IAM

Formato:
user_data = base64encode(templatefile("${path.module}/scripts/backend_user_data.sh", {
  timestamp  = timestamp()
  DD_API_KEY = var.datadog_api_key
  DD_SITE    = var.datadog_site
  DD_ENV     = var.environment
}))
```

**Resultado:**
`ec2.tf` actualizado con:
- `base64encode()` + `templatefile()`
- Variables interpoladas correctamente
- IMDSv2 forzado
- Monitoring habilitado
- Tags informativos

---

## Prompts de Documentación

### 10. README Completo

**Prompt:**
```
Genera un README.md completo que incluya:
- Resumen de cambios realizados
- Explicación de cada mejora
- Archivos modificados/creados
- Instrucciones de despliegue paso a paso
- Variables de entorno requeridasjemplos de configuración
- Dashboards y monitores
- Solución de problemas
- Mejoras de seguridad
- Checklist de despliegue

Estructura profesional con:
- Headings organizados
- Tablas
- Bloques de código con highlighting
- Emojis para claridad visual
- Enlaces a documentación
- Notas de seguridad
```

**Resultado:**
`tf/README.md` de 350+ líneas con documentación completa.

### 11. Documentación de Prompts

**Prompt:**
```
Crea un archivo datadog-aws-prompts.md que documente:
- Cada prompt utilizado
- El contexto y objetivo
- El resultado generado
- Fragmentos de código relevantes
- Lecciones aprendidas
- Referencias a documentación

Organiza por categorías:
- Configuración
- Integración
- Dashboards
- Monitoreo
- Seguridad
- Documentación
```

**Resultado:**
Este archivo con 11 prompts documentados.

---

## Lecciones Aprendidas

### ✅ Lo que Funcionó Bien

1. **Especificidad en los Prompts**
   - Incluir requisitos exactos
   - Mencionar versiones de Terraform
   - Referenciar documentación oficial
   - Ej: `version = "~> 3.0"` produce Terraform más compatible

2. **Desglose en Pasos**
   - En lugar de: "crea toda la integración"
   - Mejor: "crea el rol IAM", "crea la política", "crea la integración"

3. **Variables Sensitivas**
   - Usar `sensitive = true` para credenciales
   - Documentar uso de variables de entorno
   - Nunca hardcodear en el código

4. **Estructura de Archivos**
   - Separar por funcionalidad (`provider.tf`, `datadog.tf`, etc.)
   - Facilita mantenimiento
   - Sigue convenciones de Terraform

5. **Documentación Completa**
   - Incluir `README.md` en la carpeta `tf/`
   - Documentar cambios de seguridad
   - Proporcionar ejemplos runnable

### ⚠️ Desafíos Encontrados

1. **Cambio de Estructura Terraform**
   - El código original tenía todo en `main.tf`
   - Reorganizar requirió cuidado con dependencias
   - **Solución:** Usar `depends_on` explícito en recursos EC2

2. **Integración AWS-Datadog External ID**
   - Datadog genera un External ID único
   - Debe coincidir con la variable en Terraform
   - **Solución:** Documentar el proceso en README

3. **Pass-through de Variables a User Data**
   - Inicialmente había conflicto entre Bash y Terraform
   - Variables de Datadog no se interpolaban correctamente
   - **Solución:** Usar `templatefile()` + `base64encode()` + variables explícitas

4. **Monitoreo de Logs**
   - Los logs de EC2 no aparecen inmediatamente
   - Necesita integración de logs configurada
   - **Solución:** Agregar `datadog_integration_aws_log_collection`

5. **IAM Permissions**
   - Demasiados permisos: problemas de seguridad
   - Muy pocos permisos: métricas faltantes
   - **Solución:** Basarse en guía oficial de AWS

### 🎯 Recomendaciones para Futuro

1. **Terraform State Management**
   ```hcl
   terraform {
     backend "s3" {
       bucket = "lti-project-tfstate"
       key    = "prod/terraform.tfstate"
       dynamodb_table = "terraform-locks"
     }
   }
   ```

2. **CI/CD Integration**
   - `terraform validate` en pre-commit
   - `terraform plan` en PR
   - `terraform apply` en merge a main

3. **Alertas Adicionales**
   - Networking issues
   - Disk space
   - Memory usage
   - Application latency

4. **APM Integration**
   - Datadog APM para Backend
   - Synthetics para Frontend
   - RUM (Real User Monitoring)

5. **Cost Optimization**
   - Monitoreo de costos AWS con Datadog
   - Alertas si costos exceden presupuesto

---

## 🔗 Referencias Utilizadas

1. **Terraform AWS Provider**
   - https://registry.terraform.io/providers/hashicorp/aws/latest/docs

2. **Datadog Provider**
   - https://registry.terraform.io/providers/DataDog/datadog/latest/docs

3. **AWS-Datadog Integration**
   - https://docs.datadoghq.com/es/integrations/amazon-web-services/

4. **Terraform AWS Setup**
   - https://docs.datadoghq.com/es/integrations/guide/aws-terraform-setup/

5. **Managing Datadog with Terraform**
   - https://www.datadoghq.com/blog/managing-datadog-with-terraform/

---

## 📊 Métricas de Éxito

✅ **Implementadas:**
- [x] 3 Dashboards funcionales
- [x] 3 Monitores/Alertas configurados
- [x] Integración AWS-Datadog segura
- [x] Agente Datadog en ambas instancias
- [x] Eliminación total de credenciales hardcodeadas
- [x] Documentación completa
- [x] Mejoras de seguridad aplicadas

📈 **Resultados:**
- Monitoreo completo de infraestructura AWS
- Alertas automáticas en caso de anomalías
- Visualización unificada de logs y métricas
- Seguridad mejorada en gestión de credenciales

---

**Versión:** 1.0
**Última actualización:** Febrero 2026
**Estado:** ✅ Completado y Documentado
