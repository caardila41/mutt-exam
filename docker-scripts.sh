#!/bin/bash

# Script de utilidad para gestionar el contenedor Crypto Data Fetcher

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Crypto Data Fetcher - Docker Management Script${NC}"
    echo ""
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponibles:"
    echo "  build     - Construir la imagen Docker"
    echo "  start     - Iniciar el contenedor (producción)"
    echo "  dev       - Iniciar en modo desarrollo"
    echo "  stop      - Detener el contenedor"
    echo "  restart   - Reiniciar el contenedor"
    echo "  logs      - Ver logs en tiempo real"
    echo "  status    - Ver estado del contenedor"
    echo "  shell     - Abrir shell en el contenedor"
    echo "  test      - Ejecutar prueba manual"
    echo "  clean     - Limpiar contenedores e imágenes"
    echo "  help      - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 build"
    echo "  $0 start"
    echo "  $0 logs"
}

# Función para verificar si Docker está instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker no está instalado${NC}"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose no está instalado${NC}"
        exit 1
    fi
}

# Función para verificar API key
check_api_key() {
    if [ -z "$API_KEY_GECKO" ]; then
        echo -e "${YELLOW}⚠️  API_KEY_GECKO no está configurada${NC}"
        echo "Configura la variable de entorno o crea un archivo .env"
        echo "Ejemplo: export API_KEY_GECKO='tu-api-key-aqui'"
        return 1
    fi
    return 0
}

# Función para construir imagen
build_image() {
    echo -e "${BLUE}🔨 Construyendo imagen Docker...${NC}"
    docker-compose build
    echo -e "${GREEN}✅ Imagen construida exitosamente${NC}"
}

# Función para iniciar en producción
start_production() {
    echo -e "${BLUE}🚀 Iniciando contenedor en modo producción...${NC}"
    if check_api_key; then
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
        echo -e "${GREEN}✅ Contenedor iniciado en modo producción${NC}"
        echo "📊 Para ver logs: $0 logs"
        echo "📁 Datos guardados en: ./crypto_data/"
    else
        echo -e "${RED}❌ No se pudo iniciar el contenedor${NC}"
        exit 1
    fi
}

# Función para iniciar en desarrollo
start_development() {
    echo -e "${BLUE}🔧 Iniciando contenedor en modo desarrollo...${NC}"
    docker-compose -f docker-compose.yml -f docker-compose.override.yml up
}

# Función para detener
stop_container() {
    echo -e "${BLUE}🛑 Deteniendo contenedor...${NC}"
    docker-compose down
    echo -e "${GREEN}✅ Contenedor detenido${NC}"
}

# Función para reiniciar
restart_container() {
    echo -e "${BLUE}🔄 Reiniciando contenedor...${NC}"
    docker-compose restart
    echo -e "${GREEN}✅ Contenedor reiniciado${NC}"
}

# Función para ver logs
show_logs() {
    echo -e "${BLUE}📊 Mostrando logs en tiempo real...${NC}"
    echo "Presiona Ctrl+C para salir"
    docker-compose logs -f
}

# Función para ver estado
show_status() {
    echo -e "${BLUE}📋 Estado del contenedor:${NC}"
    docker-compose ps
    echo ""
    echo -e "${BLUE}📊 Health check:${NC}"
    docker-compose exec crypto-fetcher pgrep cron || echo "Cron no está ejecutándose"
}

# Función para abrir shell
open_shell() {
    echo -e "${BLUE}🐚 Abriendo shell en el contenedor...${NC}"
    docker-compose exec crypto-fetcher bash
}

# Función para ejecutar prueba manual
run_test() {
    echo -e "${BLUE}🧪 Ejecutando prueba manual...${NC}"
    if check_api_key; then
        docker-compose exec crypto-fetcher python main.py $(date -d 'yesterday' +%Y-%m-%d) --verbose
    else
        echo -e "${RED}❌ No se pudo ejecutar la prueba${NC}"
        exit 1
    fi
}

# Función para limpiar
clean_docker() {
    echo -e "${YELLOW}🧹 Limpiando contenedores e imágenes...${NC}"
    docker-compose down --rmi all --volumes --remove-orphans
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

# Verificar Docker al inicio
check_docker

# Procesar comandos
case "$1" in
    build)
        build_image
        ;;
    start)
        start_production
        ;;
    dev)
        start_development
        ;;
    stop)
        stop_container
        ;;
    restart)
        restart_container
        ;;
    logs)
        show_logs
        ;;
    status)
        show_status
        ;;
    shell)
        open_shell
        ;;
    test)
        run_test
        ;;
    clean)
        clean_docker
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Comando no válido: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac 