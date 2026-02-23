#!/bin/bash
set -e

# ========================================
# Script de Usuario para Frontend con Datadog
# ========================================

echo "[$(date)] Iniciando configuración de Frontend con Datadog..."

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
export DD_SERVICE="frontend"
export DD_HOSTNAME="$(hostname)"
export DD_TAGS="service:frontend,environment:${DD_ENV},version:1.0"

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
# Configuración de la Aplicación Frontend
# ========================================

echo "[$(date)] Descargando código del frontend desde S3..."

# Descargar y descomprimir el código frontend
aws s3 cp s3://lti-project-code-bucket/frontend.zip /home/ec2-user/frontend.zip || echo "[WARNING] No se pudo descargar frontend.zip"
if [ -f /home/ec2-user/frontend.zip ]; then
    unzip /home/ec2-user/frontend.zip -d /home/ec2-user/
fi

# Construir la imagen Docker
echo "[$(date)] Construyendo imagen Docker para Frontend..."
if [ -d /home/ec2-user/frontend ]; then
    cd /home/ec2-user/frontend
    docker build -t lti-frontend .
    
    # Ejecutar el contenedor con variables de entorno
    echo "[$(date)] Ejecutando contenedor Frontend..."
    docker run -d \
        -p 3000:3000 \
        -e DD_API_KEY="${DD_API_KEY}" \
        -e DD_SITE="${DD_SITE}" \
        -e DD_ENV="${DD_ENV}" \
        -e DD_SERVICE="frontend" \
        --name frontend-service \
        lti-frontend
fi

echo "[$(date)] Configuración de Frontend completada"

# Timestamp para forzar actualización
