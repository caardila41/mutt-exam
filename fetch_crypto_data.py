import click
import requests
import json
import logging
import os
from datetime import datetime
from logging.handlers import RotatingFileHandler

# Intentar cargar variables de entorno desde archivo .env si python-dotenv está disponible
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    # python-dotenv no está instalado, continuar sin él
    pass

# URL base para la API de CoinGecko v3
BASE_URL = "https://api.coingecko.com/api/v3"

# API Key de CoinGecko - Leer desde variable de entorno
API_KEY = os.getenv('API_KEY_GECKO')

# Monedas a procesar
COIN_LIST = ["bitcoin", "ethereum", "cardano"]
# Directorio para guardar los archivos de datos
OUTPUT_DIR = "crypto_data"
# Nombre del archivo de registro
LOG_FILE = "crypto_fetch.log"


def setup_logging():
    """Configura un sistema de registro dual: consola y archivo rotativo."""
    # Crear el logger principal
    logger = logging.getLogger('crypto_fetcher')
    logger.setLevel(logging.DEBUG)  # Nivel más bajo para capturar todos los mensajes

    # Evitar duplicación de handlers
    if logger.handlers:
        return logger

    # Crear un formateador consistente
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

    # 1. Handler para la consola (muestra mensajes de INFO y superiores)
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

    # 2. Handler para el archivo de registro (guarda mensajes de DEBUG y superiores)
    # Rota el archivo cuando alcanza 5MB y mantiene hasta 3 archivos de respaldo
    file_handler = RotatingFileHandler(LOG_FILE, maxBytes=5*1024*1024, backupCount=3)
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

    return logger


def ensure_output_directory():
    """Asegura que el directorio de salida existe."""
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
        logger.info(f"Directorio de salida creado: {OUTPUT_DIR}")


def validate_api_key():
    """
    Valida que la API key esté configurada.
    
    Returns:
        bool: True si la API key está configurada, False en caso contrario
    """
    if not API_KEY:
        logger.error("API_KEY_GECKO no está configurada en las variables de entorno")
        return False
    return True


def download_crypto_data(coin_id, iso_date, verbose=False):
    """
    Función principal para descargar datos históricos de una criptomoneda.
    
    Args:
        coin_id (str): Identificador de la moneda (p. ej., 'bitcoin', 'ethereum').
        iso_date (str): La fecha en formato ISO 8601 (YYYY-MM-DD).
        verbose (bool): Si es True, habilita logging detallado.
    
    Returns:
        bool: True si la descarga fue exitosa, False en caso contrario.
    """
    # Configurar logging
    global logger
    logger = setup_logging()
    
    # Validar API key
    if not validate_api_key():
        return False
    
    # Ajustar nivel de logging si se especifica verbose
    if verbose:
        for handler in logger.handlers:
            if isinstance(handler, logging.StreamHandler) and not isinstance(handler, logging.FileHandler):
                handler.setLevel(logging.DEBUG)
    
    # Asegurar que el directorio de salida existe
    ensure_output_directory()
    
    logger.info(f"Iniciando descarga de datos para '{coin_id}' en la fecha '{iso_date}'")

    # 1. Validar y convertir el formato de la fecha.
    # La API de CoinGecko requiere el formato 'dd-mm-yyyy'.
    try:
        date_object = datetime.strptime(iso_date, '%Y-%m-%d')
        api_date_format = date_object.strftime('%d-%m-%Y')
        logger.debug(f"Fecha convertida de '{iso_date}' a formato API: '{api_date_format}'")
    except ValueError:
        error_msg = f"Error: Formato de fecha no válido. Por favor, utiliza 'YYYY-MM-DD'."
        logger.error(error_msg)
        return False

    # 2. Construir la URL del punto final de la API con la API key como parámetro de query.
    # El punto final para datos históricos en una fecha específica es /coins/{id}/history.
    api_url = f"{BASE_URL}/coins/{coin_id}/history?date={api_date_format}&x_cg_demo_api_key={API_KEY}"
    logger.info(f"Contactando al endpoint de la API: {api_url}")

    # 3. Realizar la solicitud a la API y manejar posibles errores.
    try:
        logger.debug("Iniciando solicitud HTTP a la API")
        response = requests.get(api_url)
        logger.debug(f"Respuesta recibida - Status Code: {response.status_code}")
        
        # Esto lanzará una excepción para respuestas de error (p. ej., 404, 429).
        response.raise_for_status()
        logger.info("Solicitud HTTP exitosa")
        
    except requests.exceptions.HTTPError as http_err:
        error_msg = f"Error HTTP: {http_err}"
        logger.error(f"{error_msg} - Respuesta: {response.text}")
        return False
    except requests.exceptions.RequestException as req_err:
        error_msg = f"Error de red o de solicitud: {req_err}"
        logger.error(error_msg)
        return False

    # 4. Guardar la respuesta JSON en un archivo local.
    # El formato JSON es ideal ya que preserva la estructura original de la respuesta de la API.
    file_name = os.path.join(OUTPUT_DIR, f"{coin_id}_{iso_date}.json")
    try:
        # Obtener los datos JSON de la respuesta.
        logger.debug("Decodificando respuesta JSON")
        data = response.json()
        logger.debug(f"Datos JSON decodificados exitosamente - Tamaño: {len(str(data))} caracteres")
        
        with open(file_name, 'w', encoding='utf-8') as f:
            # json.dump escribe los datos en el archivo con un formato legible.
            json.dump(data, f, ensure_ascii=False, indent=4)
        
        success_msg = f"¡Éxito! Los datos se han guardado en '{file_name}'"
        logger.info(success_msg)
        return True
        
    except json.JSONDecodeError as json_err:
        error_msg = f"Error: No se pudo decodificar la respuesta JSON de la API: {json_err}"
        logger.error(error_msg)
        return False
    except IOError as io_err:
        error_msg = f"Error al escribir en el archivo '{file_name}': {io_err}"
        logger.error(error_msg)
        return False


@click.command()
@click.argument('coin_id', type=str)
@click.argument('iso_date', type=str)
@click.option('--verbose', '-v', is_flag=True, help='Habilitar logging detallado')
def download_historical_data(coin_id, iso_date, verbose):
    """
    Descarga los datos históricos de una criptomoneda para una fecha específica
    desde la API de CoinGecko y los guarda en un archivo JSON local.

    COIN_ID: El identificador de la moneda (p. ej., 'bitcoin', 'ethereum').
    ISO_DATE: La fecha en formato ISO 8601 (YYYY-MM-DD) para la que se obtendrán los datos.
    """
    download_crypto_data(coin_id, iso_date, verbose)


if __name__ == '__main__':
    download_historical_data()