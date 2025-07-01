#!/usr/bin/env python3
"""
Script principal para descargar datos históricos de múltiples criptomonedas.
Procesa las 3 monedas definidas: bitcoin, ethereum y cardano.
"""

import sys
import os
import argparse
from datetime import datetime, timedelta
from fetch_crypto_data import download_crypto_data, COIN_LIST, setup_logging

def validate_date(date_string):
    """
    Valida que la fecha tenga el formato correcto.
    
    Args:
        date_string (str): Fecha en formato YYYY-MM-DD
        
    Returns:
        str: Fecha validada
        
    Raises:
        argparse.ArgumentTypeError: Si la fecha no es válida
    """
    try:
        datetime.strptime(date_string, '%Y-%m-%d')
        return date_string
    except ValueError:
        raise argparse.ArgumentTypeError(f"Fecha inválida: {date_string}. Usa formato YYYY-MM-DD")

def main():
    """
    Función principal que descarga datos para todas las monedas definidas.
    """
    # Configurar argumentos de línea de comandos
    parser = argparse.ArgumentParser(
        description='Descarga datos históricos de criptomonedas desde CoinGecko API',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:
  python main.py 2017-12-30                    # Procesa todas las monedas para esa fecha
  python main.py 2020-01-01 --verbose          # Con logging detallado
  python main.py 2021-03-15 --coin bitcoin     # Solo bitcoin para esa fecha
        """
    )
    
    parser.add_argument(
        'date',
        type=validate_date,
        help='Fecha en formato YYYY-MM-DD (ej: 2017-12-30)'
    )
    
    parser.add_argument(
        '--coin', '-c',
        type=str,
        choices=COIN_LIST,
        help=f'Moneda específica a procesar. Opciones: {", ".join(COIN_LIST)}'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Habilitar logging detallado'
    )
    
    # Parsear argumentos
    args = parser.parse_args()
    
    # Configurar logging
    logger = setup_logging()
    logger.info("=== INICIANDO PROCESAMIENTO DE CRIPTMONEDAS ===")
    
    logger.info("Iniciando descarga de datos para criptomonedas...")
    
    # Determinar qué monedas procesar
    if args.coin:
        coins_to_process = [args.coin]
        logger.info(f"Procesando moneda específica: {args.coin}")
    else:
        coins_to_process = COIN_LIST
        logger.info(f"Procesando todas las monedas: {', '.join(COIN_LIST)}")
    
    logger.info(f"Fecha objetivo: {args.date}")
    logger.info("=" * 60)
    
    # Contadores para el resumen final
    successful_downloads = 0
    failed_downloads = 0
    
    # Procesar cada moneda
    for i, coin_id in enumerate(coins_to_process, 1):
        logger.info(f"Procesando moneda {i}/{len(coins_to_process)}: {coin_id.upper()}")
        logger.info("-" * 40)
        
        try:
            # Intentar descargar los datos
            success = download_crypto_data(coin_id, args.date, verbose=args.verbose)
            
            if success:
                successful_downloads += 1
                logger.info(f"{coin_id.upper()} - Descarga exitosa")
            else:
                failed_downloads += 1
                logger.error(f"{coin_id.upper()} - Descarga fallida")
                
        except Exception as e:
            failed_downloads += 1
            error_msg = f"Error inesperado procesando {coin_id}: {str(e)}"
            logger.error(error_msg)
    
    # Resumen final
    logger.info("=" * 60)
    logger.info("RESUMEN FINAL")
    logger.info("=" * 60)
    logger.info(f"Descargas exitosas: {successful_downloads}")
    logger.info(f"Descargas fallidas: {failed_downloads}")
    logger.info(f"Total de monedas procesadas: {len(coins_to_process)}")
    
    if successful_downloads == len(coins_to_process):
        logger.info("¡Todas las descargas fueron exitosas!")
    elif successful_downloads > 0:
        logger.warning("Algunas descargas fueron exitosas, otras fallaron.")
    else:
        logger.error("Todas las descargas fallaron. Revisa los logs para más detalles.")
    
    logger.info(f"Procesamiento completado - Exitosas: {successful_downloads}, Fallidas: {failed_downloads}")
    logger.info("Los archivos se han guardado en el directorio 'crypto_data/'")
    logger.info("Revisa 'crypto_fetch.log' para detalles técnicos")


if __name__ == "__main__":
    logger = setup_logging()
    logger.info("CRYPTO DATA FETCHER - PROCESAMIENTO MÚLTIPLE")
    logger.info("=" * 60)
    
    try:
        main()
    except KeyboardInterrupt:
        logger.info("¡Hasta luego!")
    except Exception as e:
        logger.error(f"Error inesperado: {str(e)}")
        logger.error(f"Error crítico en main: {str(e)}") 