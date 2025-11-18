"""
Módulo de formateadores de datos.
Contiene funciones para estandarizar la salida de datos a la interfaz (QML).
"""

import logging
from datetime import date, datetime
from typing import Union, Optional

logger = logging.getLogger('formatters')

def date_to_iso(fecha: Union[date, datetime, str, None]) -> Optional[str]:
    """
    Convierte un objeto date, datetime, o un string de fecha 
    al formato ISO 8601 (YYYY-MM-DD).

    Este formato es crucial para que QML/JavaScript maneje las fechas correctamente.

    Args:
        fecha: Objeto date, datetime, o un string que representa una fecha.

    Returns:
        Optional[str]: La fecha formateada en 'YYYY-MM-DD' o None si el input es inválido/None.
    """
    if fecha is None:
        return None
        
    try:
        # Si ya es un objeto date o datetime, lo formateamos directamente
        if isinstance(fecha, (date, datetime)):
            return fecha.strftime('%Y-%m-%d')
        
        # Si es un string (ej. '2025-11-18T10:30:00'), intentamos parsearlo primero
        if isinstance(fecha, str):
            # Intentar parsear el string. Si es solo fecha, funcionará. Si es datetime, también.
            fecha_obj = datetime.fromisoformat(fecha)
            return fecha_obj.strftime('%Y-%m-%d')

        # Si el tipo no es manejado, lo registramos
        logger.warning(f"Tipo de dato inesperado para formateo a ISO: {type(fecha)}")
        return None
        
    except ValueError as e:
        logger.error(f"Error al parsear la fecha '{fecha}' a ISO 8601: {e}")
        return None