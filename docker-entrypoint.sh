#!/bin/bash

# Script de entrada para Docker
# Inicia cron y mantiene el contenedor ejecutándose

echo "🚀 Iniciando Crypto Data Fetcher Container..."
echo "📅 Cron job configurado para ejecutarse todos los días a las 3:00 AM"
echo "📊 Procesando monedas: bitcoin, ethereum, cardano"
echo "📁 Datos guardados en: /app/crypto_data/"
echo "📝 Logs en: /app/crypto_fetch.log"

# Verificar que la API key esté configurada
if [ -z "$API_KEY_GECKO" ]; then
    echo "❌ ERROR: API_KEY_GECKO no está configurada"
    echo "💡 Configura la variable de entorno API_KEY_GECKO"
    exit 1
fi

echo "✅ API Key configurada correctamente"

# Crear directorio de datos si no existe
mkdir -p /app/crypto_data

# Iniciar el servicio cron
echo "🕐 Iniciando servicio cron..."
service cron start

# Ejecutar una prueba inicial (opcional)
echo "🧪 Ejecutando prueba inicial..."
python main.py $(date -d 'yesterday' +%Y-%m-%d) --verbose

# Mantener el contenedor ejecutándose
echo "🔄 Contenedor ejecutándose. Presiona Ctrl+C para detener."
echo "📊 Para ver logs en tiempo real: docker logs -f <container_name>"

# Mantener el script ejecutándose
tail -f /app/crypto_fetch.log 