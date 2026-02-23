#!/bin/bash
set -e

# ========================================
# Script de Usuario para Backend con Datadog
# ========================================

echo "[$(date)] Iniciando configuración de Backend con Datadog..."

# Actualizar el sistema
echo "[$(date)] Actualizando sistema..."
yum update -y
yum install -y docker curl wget

# Habilitar e iniciar Docker
echo "[$(date)] Iniciando Docker..."
systemctl enable docker
systemctl start docker

# ========================================
# Instalación del Agente Datadog
# ========================================

echo "[$(date)] Instalando agente Datadog..."

# Configurar variables de entorno para Datadog
export DD_AGENT_MAJOR_VERSION=7
export DD_API_KEY="${DD_API_KEY}"
export DD_SITE="${DD_SITE}"
export DD_ENV="${DD_ENV}"
export DD_SERVICE="backend"
export DD_HOSTNAME="$(hostname)"
export DD_TAGS="service:backend,environment:${DD_ENV},version:1.0"

# Descargar e instalar el agente Datadog
bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Esperar a que el agente se instale correctamente
sleep 10

# Iniciar el agente Datadog
echo "[$(date)] Iniciando servicio Datadog Agent..."
systemctl enable datadog-agent
systemctl start datadog-agent

# Verificar estado del agente
sleep 5
systemctl status datadog-agent || echo "[WARNING] Estado del agente verificado"

# ========================================
# Configuración de la Aplicación Backend
# ========================================

echo "[$(date)] Descargando código del backend desde S3..."

# Descargar y descomprimir el código backend
aws s3 cp s3://lti-project-code-bucket/backend.zip /home/ec2-user/backend.zip || echo "[WARNING] No se pudo descargar backend.zip"
if [ -f /home/ec2-user/backend.zip ]; then
    unzip /home/ec2-user/backend.zip -d /home/ec2-user/
fi

# Construir la imagen Docker
echo "[$(date)] Construyendo imagen Docker para Backend..."
if [ -d /home/ec2-user/backend ]; then
    cd /home/ec2-user/backend
    docker build -t lti-backend .
    
    # Ejecutar el contenedor con variables de entorno
    echo "[$(date)] Ejecutando contenedor Backend..."
    docker run -d \
        -p 8080:8080 \
        -e DD_API_KEY="${DD_API_KEY}" \
        -e DD_SITE="${DD_SITE}" \
        -e DD_ENV="${DD_ENV}" \
        -e DD_SERVICE="backend" \
        --name backend-service \
        lti-backend
fi

echo "[$(date)] Configuración de Backend completada"

# Timestamp para forzar actualización
