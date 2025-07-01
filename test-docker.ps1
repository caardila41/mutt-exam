# Script de prueba para Docker en Windows PowerShell
# Crypto Data Fetcher - Docker Test

param(
    [string]$Command = "help"
)

# Colores para output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

# Función para mostrar ayuda
function Show-Help {
    Write-Host "Crypto Data Fetcher - Docker Test Script" -ForegroundColor $Blue
    Write-Host ""
    Write-Host "Uso: .\test-docker.ps1 [COMANDO]"
    Write-Host ""
    Write-Host "Comandos disponibles:"
    Write-Host "  check     - Verificar instalación de Docker"
    Write-Host "  build     - Construir imagen Docker"
    Write-Host "  test      - Ejecutar prueba rápida"
    Write-Host "  dev       - Iniciar modo desarrollo"
    Write-Host "  logs      - Ver logs"
    Write-Host "  stop      - Detener contenedor"
    Write-Host "  clean     - Limpiar contenedores"
    Write-Host "  help      - Mostrar esta ayuda"
    Write-Host ""
    Write-Host "Ejemplos:"
    Write-Host "  .\test-docker.ps1 check"
    Write-Host "  .\test-docker.ps1 build"
    Write-Host "  .\test-docker.ps1 test"
}

# Función para verificar Docker
function Test-DockerInstallation {
    Write-Host "🔍 Verificando instalación de Docker..." -ForegroundColor $Blue
    
    try {
        $dockerVersion = docker --version 2>$null
        if ($dockerVersion) {
            Write-Host "✅ Docker instalado: $dockerVersion" -ForegroundColor $Green
        } else {
            Write-Host "❌ Docker no está instalado" -ForegroundColor $Red
            Write-Host "💡 Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop" -ForegroundColor $Yellow
            return $false
        }
    } catch {
        Write-Host "❌ Error al verificar Docker" -ForegroundColor $Red
        return $false
    }
    
    try {
        $composeVersion = docker-compose --version 2>$null
        if ($composeVersion) {
            Write-Host "✅ Docker Compose instalado: $composeVersion" -ForegroundColor $Green
        } else {
            Write-Host "❌ Docker Compose no está instalado" -ForegroundColor $Red
            return $false
        }
    } catch {
        Write-Host "❌ Error al verificar Docker Compose" -ForegroundColor $Red
        return $false
    }
    
    return $true
}

# Función para verificar API key
function Test-ApiKey {
    $apiKey = $env:API_KEY_GECKO
    if (-not $apiKey) {
        Write-Host "⚠️  API_KEY_GECKO no está configurada" -ForegroundColor $Yellow
        Write-Host "💡 Configura la variable de entorno:" -ForegroundColor $Yellow
        Write-Host "   `$env:API_KEY_GECKO = 'tu-api-key-aqui'" -ForegroundColor $Yellow
        return $false
    }
    Write-Host "✅ API Key configurada correctamente" -ForegroundColor $Green
    return $true
}

# Función para construir imagen
function Build-DockerImage {
    Write-Host "🔨 Construyendo imagen Docker..." -ForegroundColor $Blue
    try {
        docker-compose build
        Write-Host "✅ Imagen construida exitosamente" -ForegroundColor $Green
        return $true
    } catch {
        Write-Host "❌ Error al construir imagen" -ForegroundColor $Red
        return $false
    }
}

# Función para ejecutar prueba rápida
function Test-Container {
    Write-Host "🧪 Ejecutando prueba rápida..." -ForegroundColor $Blue
    
    if (-not (Test-ApiKey)) {
        return $false
    }
    
    # Obtener fecha de ayer
    $yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")
    
    Write-Host "📅 Probando con fecha: $yesterday" -ForegroundColor $Blue
    
    try {
        # Ejecutar contenedor en modo prueba
        docker-compose -f docker-compose.yml -f docker-compose.override.yml run --rm crypto-fetcher python main.py $yesterday --verbose
        
        Write-Host "✅ Prueba completada exitosamente" -ForegroundColor $Green
        return $true
    } catch {
        Write-Host "❌ Error en la prueba" -ForegroundColor $Red
        return $false
    }
}

# Función para iniciar modo desarrollo
function Start-Development {
    Write-Host "🔧 Iniciando modo desarrollo..." -ForegroundColor $Blue
    
    if (-not (Test-ApiKey)) {
        return $false
    }
    
    try {
        docker-compose -f docker-compose.yml -f docker-compose.override.yml up
    } catch {
        Write-Host "❌ Error al iniciar modo desarrollo" -ForegroundColor $Red
        return $false
    }
}

# Función para ver logs
function Show-Logs {
    Write-Host "📊 Mostrando logs..." -ForegroundColor $Blue
    try {
        docker-compose logs -f
    } catch {
        Write-Host "❌ Error al mostrar logs" -ForegroundColor $Red
    }
}

# Función para detener contenedor
function Stop-Container {
    Write-Host "🛑 Deteniendo contenedor..." -ForegroundColor $Blue
    try {
        docker-compose down
        Write-Host "✅ Contenedor detenido" -ForegroundColor $Green
    } catch {
        Write-Host "❌ Error al detener contenedor" -ForegroundColor $Red
    }
}

# Función para limpiar
function Clean-Docker {
    Write-Host "🧹 Limpiando contenedores..." -ForegroundColor $Blue
    try {
        docker-compose down --rmi all --volumes --remove-orphans
        Write-Host "✅ Limpieza completada" -ForegroundColor $Green
    } catch {
        Write-Host "❌ Error en la limpieza" -ForegroundColor $Red
    }
}

# Procesar comandos
switch ($Command.ToLower()) {
    "check" {
        Test-DockerInstallation
    }
    "build" {
        if (Test-DockerInstallation) {
            Build-DockerImage
        }
    }
    "test" {
        if (Test-DockerInstallation) {
            Test-Container
        }
    }
    "dev" {
        if (Test-DockerInstallation) {
            Start-Development
        }
    }
    "logs" {
        Show-Logs
    }
    "stop" {
        Stop-Container
    }
    "clean" {
        Clean-Docker
    }
    "help" {
        Show-Help
    }
    default {
        Write-Host "❌ Comando no válido: $Command" -ForegroundColor $Red
        Show-Help
    }
} 