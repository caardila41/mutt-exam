# Crypto Data Fetcher

Script para descargar datos históricos de criptomonedas desde la API de CoinGecko.

## Características

- ✅ Descarga datos históricos de criptomonedas para fechas específicas
- ✅ Sistema de logging dual (consola + archivo rotativo)
- ✅ Manejo robusto de errores
- ✅ API key de CoinGecko integrada
- ✅ Organización automática de archivos de salida
- ✅ Modo verbose para debugging

## Instalación

1. Clona o descarga este repositorio
2. Instala las dependencias:
```bash
pip install click requests
```

## Uso

### Opción 1: Procesamiento Múltiple (Recomendado)
```bash
python main.py <fecha>
```

Este comando procesa automáticamente las 3 monedas definidas (bitcoin, ethereum, cardano) para la fecha especificada.

#### Ejemplos:
```bash
# Procesar todas las monedas para el 30 de diciembre de 2017
python main.py 2017-12-30

# Procesar todas las monedas para el 1 de enero de 2020
python main.py 2020-01-01

# Procesar solo Bitcoin para el 15 de marzo de 2021
python main.py 2021-03-15 --coin bitcoin

# Procesar todas las monedas con logging detallado
python main.py 2017-12-30 --verbose
```

### Opción 2: Uso Individual
```bash
python fetch_crypto_data.py <coin_id> <fecha>
```

### Ejemplos de Uso Individual
```bash
# Descargar datos de Bitcoin para el 30 de diciembre de 2017
python fetch_crypto_data.py bitcoin 2017-12-30

# Descargar datos de Ethereum para el 1 de enero de 2020
python fetch_crypto_data.py ethereum 2020-01-01

# Descargar datos de Cardano para el 15 de marzo de 2021
python fetch_crypto_data.py cardano 2021-03-15
```

### Modo Verbose
Para obtener información detallada de debugging:
```bash
python fetch_crypto_data.py bitcoin 2017-12-30 --verbose
```

## Parámetros

### main.py
- `fecha`: Fecha en formato ISO 8601 (YYYY-MM-DD) - **Obligatorio**
- `--coin, -c`: Moneda específica a procesar (opcional)
  - Opciones: bitcoin, ethereum, cardano
  - Si no se especifica, procesa todas las monedas
- `--verbose, -v`: Habilitar logging detallado (opcional)

### fetch_crypto_data.py
- `coin_id`: Identificador de la criptomoneda (ej: bitcoin, ethereum, cardano)
- `iso_date`: Fecha en formato ISO 8601 (YYYY-MM-DD)
- `--verbose, -v`: Habilitar logging detallado (opcional)

## Estructura de Archivos

El script crea automáticamente la siguiente estructura:

```
MuttExam/
├── main.py                   # Script principal para procesamiento múltiple
├── fetch_crypto_data.py      # Script individual para una moneda
├── crypto_data/              # Directorio de datos (creado automáticamente)
│   ├── bitcoin_2017-12-30.json
│   ├── ethereum_2017-12-30.json
│   ├── cardano_2017-12-30.json
│   └── ...
├── crypto_fetch.log          # Archivo de log principal
├── crypto_fetch.log.1        # Archivo de log rotado
├── crypto_fetch.log.2        # Archivo de log rotado
└── README.md                 # Este archivo
```

## Sistema de Logging

El script implementa un sistema de logging robusto con las siguientes características:

### Niveles de Log
- **INFO**: Información general del proceso
- **DEBUG**: Detalles técnicos (solo en modo verbose o archivo)
- **ERROR**: Errores y excepciones
- **WARNING**: Advertencias

### Destinos de Log
1. **Consola**: Muestra mensajes INFO y superiores
2. **Archivo**: Guarda todos los mensajes (DEBUG y superiores)

### Rotación de Logs
- Tamaño máximo: 5MB por archivo
- Archivos de respaldo: 3 archivos
- Nombres: `crypto_fetch.log`, `crypto_fetch.log.1`, etc.

## API Key

El script incluye una API key de CoinGecko configurada:
```
CG-kbwJNgHWSJWymkEj199gPaby
```

Esta key permite:
- Acceso a datos históricos más antiguos
- Mayor límite de solicitudes
- Mejor estabilidad de la API

## Manejo de Errores

El script maneja los siguientes tipos de errores:

- **Errores de formato de fecha**: Validación de formato ISO 8601
- **Errores HTTP**: Códigos de estado 4xx/5xx de la API
- **Errores de red**: Problemas de conectividad
- **Errores JSON**: Respuestas malformadas de la API
- **Errores de archivo**: Problemas de escritura en disco

## Ejemplo de Salida

```
2024-01-15 10:30:15,123 - crypto_fetcher - INFO - CRYPTO DATA FETCHER - PROCESAMIENTO MÚLTIPLE
2024-01-15 10:30:15,124 - crypto_fetcher - INFO - ============================================================
2024-01-15 10:30:15,125 - crypto_fetcher - INFO - === INICIANDO PROCESAMIENTO DE CRIPTMONEDAS ===
2024-01-15 10:30:15,126 - crypto_fetcher - INFO - Iniciando descarga de datos para criptomonedas...
2024-01-15 10:30:15,127 - crypto_fetcher - INFO - Procesando todas las monedas: bitcoin, ethereum, cardano
2024-01-15 10:30:15,457 - crypto_fetcher - INFO - Fecha objetivo: 2017-12-30
2024-01-15 10:30:15,458 - crypto_fetcher - INFO - ============================================================
2024-01-15 10:30:15,459 - crypto_fetcher - INFO - Procesando moneda 1/3: BITCOIN
2024-01-15 10:30:15,460 - crypto_fetcher - INFO - ----------------------------------------
2024-01-15 10:30:15,461 - crypto_fetcher - INFO - Iniciando descarga de datos para 'bitcoin' en la fecha '2017-12-30'
2024-01-15 10:30:15,462 - crypto_fetcher - DEBUG - Fecha convertida de '2017-12-30' a formato API: '30-12-2017'
2024-01-15 10:30:15,463 - crypto_fetcher - INFO - Contactando al endpoint de la API: https://api.coingecko.com/api/v3/coins/bitcoin/history?date=30-12-2017&x_cg_demo_api_key=CG-kbwJNgHWSJWymkEj199gPaby
2024-01-15 10:30:16,789 - crypto_fetcher - INFO - Solicitud HTTP exitosa
2024-01-15 10:30:16,890 - crypto_fetcher - DEBUG - Datos JSON decodificados exitosamente - Tamaño: 1234 caracteres
2024-01-15 10:30:16,891 - crypto_fetcher - INFO - ¡Éxito! Los datos se han guardado en 'crypto_data/bitcoin_2017-12-30.json'
2024-01-15 10:30:16,892 - crypto_fetcher - INFO - BITCOIN - Descarga exitosa
2024-01-15 10:30:16,893 - crypto_fetcher - INFO - ============================================================
2024-01-15 10:30:16,894 - crypto_fetcher - INFO - RESUMEN FINAL
2024-01-15 10:30:16,895 - crypto_fetcher - INFO - ============================================================
2024-01-15 10:30:16,896 - crypto_fetcher - INFO - Descargas exitosas: 3
2024-01-15 10:30:16,897 - crypto_fetcher - INFO - Descargas fallidas: 0
2024-01-15 10:30:16,898 - crypto_fetcher - INFO - Total de monedas procesadas: 3
2024-01-15 10:30:16,899 - crypto_fetcher - INFO - ¡Todas las descargas fueron exitosas!
```

## Monedas Soportadas

El script puede descargar datos de cualquier criptomoneda disponible en CoinGecko. Algunas populares:

- `bitcoin` (BTC)
- `ethereum` (ETH)
- `cardano` (ADA)
- `binancecoin` (BNB)
- `solana` (SOL)
- `ripple` (XRP)

## Dependencias

- `click`: Manejo de interfaz de línea de comandos
- `requests`: Solicitudes HTTP
- `logging`: Sistema de logging (incluido en Python)
- `json`: Manejo de datos JSON (incluido en Python)
- `datetime`: Manejo de fechas (incluido en Python)
- `os`: Operaciones del sistema (incluido en Python)

## Licencia

Este proyecto es de uso libre para fines educativos y de investigación.
