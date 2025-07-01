# Usar Python 3.11 slim como base
FROM python:3.11-slim

# Establecer directorio de trabajo
WORKDIR /app

# Instalar cron y otras dependencias del sistema
RUN apt-get update && apt-get install -y \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Copiar archivos de dependencias
COPY requirements.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código del proyecto
COPY fetch_crypto_data.py .
COPY main.py .


# Crear directorio para datos
RUN mkdir -p crypto_data

# Crear script de cron
RUN echo "0 3 * * * cd /app && python main.py \$(date -d 'yesterday' +%Y-%m-%d) >> /app/crypto_fetch.log 2>&1" > /etc/cron.d/crypto-fetch

# Dar permisos de ejecución al archivo de cron
RUN chmod 0644 /etc/cron.d/crypto-fetch

# Crear archivo de log si no existe
RUN touch /app/crypto_fetch.log

# Aplicar el archivo de cron
RUN crontab /etc/cron.d/crypto-fetch

# Script de inicio
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Exponer puerto (opcional, para monitoreo)
EXPOSE 8000

# Comando por defecto
ENTRYPOINT ["docker-entrypoint.sh"] 