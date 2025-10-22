# utils/formatters.py
"""
Utilidades de formateo para AgroIchilo
"""

from datetime import datetime, date
from typing import Optional, Union


def formatear_fecha(
    fecha: Union[date, datetime, str, None],
    formato: str = "%d/%m/%Y"
) -> str:
    """
    Formatea una fecha.
    
    Args:
        fecha: Fecha a formatear (date, datetime, string o None)
        formato: Formato deseado (default: dd/mm/yyyy)
        
    Returns:
        str: Fecha formateada
    """
    if fecha is None:
        return ""
    
    # Si ya es string, intentar parsearlo
    if isinstance(fecha, str):
        try:
            # Intentar parsear varios formatos comunes
            formatos_posibles = [
                "%Y-%m-%d",           # 2024-01-15
                "%d/%m/%Y",           # 15/01/2024
                "%Y-%m-%d %H:%M:%S",  # 2024-01-15 14:30:00
                "%d/%m/%Y %H:%M:%S",  # 15/01/2024 14:30:00
            ]
            
            for fmt in formatos_posibles:
                try:
                    fecha = datetime.strptime(fecha, fmt)
                    break
                except ValueError:
                    continue
            else:
                # Si no se pudo parsear, retornar string original
                return fecha
        except:
            return fecha
    
    # Formatear según tipo
    if isinstance(fecha, datetime):
        return fecha.strftime(formato)
    elif isinstance(fecha, date):
        return fecha.strftime(formato)
    
    return str(fecha)


def formatear_fecha_hora(
    fecha: Union[datetime, str, None],
    formato: str = "%d/%m/%Y %H:%M"
) -> str:
    """
    Formatea una fecha con hora.
    
    Args:
        fecha: Fecha/hora a formatear
        formato: Formato deseado
        
    Returns:
        str: Fecha y hora formateadas
    """
    return formatear_fecha(fecha, formato)


def formatear_moneda(
    monto: float,
    moneda: str = "Bs.",
    decimales: int = 2
) -> str:
    """
    Formatea un monto monetario.
    
    Args:
        monto: Monto a formatear
        moneda: Símbolo de moneda (default: Bs. bolivianos)
        decimales: Cantidad de decimales
        
    Returns:
        str: Monto formateado
    """
    if monto is None:
        return f"{moneda} 0.00"
    
    # Formatear con separador de miles y decimales
    formato = f"{{:,.{decimales}f}}"
    monto_formateado = formato.format(monto)
    
    return f"{moneda} {monto_formateado}"


def formatear_area(area: float, unidad: str = "ha") -> str:
    """
    Formatea área con unidad (hectáreas por defecto).
    
    Args:
        area: Área a formatear
        unidad: Unidad de medida (ha, m², etc.)
        
    Returns:
        str: Área formateada
    """
    if area is None:
        return f"0.00 {unidad}"
    
    return f"{area:,.2f} {unidad}"


def formatear_porcentaje(valor: float, decimales: int = 1) -> str:
    """
    Formatea un porcentaje.
    
    Args:
        valor: Valor del porcentaje
        decimales: Cantidad de decimales
        
    Returns:
        str: Porcentaje formateado
    """
    if valor is None:
        return "0%"
    
    return f"{valor:.{decimales}f}%"


def formatear_telefono(telefono: str) -> str:
    """
    Formatea teléfono boliviano.
    
    Ejemplos:
        71234567 -> 7123-4567
        3456789 -> 345-6789
    
    Args:
        telefono: Número de teléfono
        
    Returns:
        str: Teléfono formateado
    """
    if not telefono:
        return ""
    
    # Remover caracteres no numéricos
    telefono_limpio = ''.join(filter(str.isdigit, telefono))
    
    # Formatear según longitud
    if len(telefono_limpio) == 8:
        # Celular: 7123-4567
        return f"{telefono_limpio[:4]}-{telefono_limpio[4:]}"
    elif len(telefono_limpio) == 7:
        # Fijo: 345-6789
        return f"{telefono_limpio[:3]}-{telefono_limpio[3:]}"
    
    # Si no coincide con formatos conocidos, retornar como está
    return telefono


def limpiar_texto(texto: Optional[str]) -> str:
    """
    Limpia y normaliza texto.
    
    Args:
        texto: Texto a limpiar
        
    Returns:
        str: Texto limpio
    """
    if not texto:
        return ""
    
    # Remover espacios extra
    texto = " ".join(texto.split())
    
    # Remover espacios al inicio y final
    return texto.strip()


def capitalizar_texto(texto: Optional[str]) -> str:
    """
    Capitaliza la primera letra de cada palabra.
    
    Args:
        texto: Texto a capitalizar
        
    Returns:
        str: Texto capitalizado
    """
    if not texto:
        return ""
    
    # Limpiar primero
    texto = limpiar_texto(texto)
    
    # Capitalizar cada palabra
    return texto.title()


def truncar_texto(texto: str, max_length: int = 50, suffix: str = "...") -> str:
    """
    Trunca texto si es muy largo.
    
    Args:
        texto: Texto a truncar
        max_length: Longitud máxima
        suffix: Sufijo a agregar (default: ...)
        
    Returns:
        str: Texto truncado
    """
    if not texto or len(texto) <= max_length:
        return texto
    
    return texto[:max_length - len(suffix)] + suffix


def formatear_numero(numero: Union[int, float], decimales: int = 0) -> str:
    """
    Formatea un número con separador de miles.
    
    Args:
        numero: Número a formatear
        decimales: Cantidad de decimales
        
    Returns:
        str: Número formateado
    """
    if numero is None:
        return "0"
    
    if decimales == 0:
        return f"{int(numero):,}"
    else:
        return f"{numero:,.{decimales}f}"


def formatear_coordenadas(coordenadas: str) -> str:
    """
    Formatea coordenadas GPS para visualización.
    
    Args:
        coordenadas: Coordenadas en formato "lat,long"
        
    Returns:
        str: Coordenadas formateadas
    """
    if not coordenadas:
        return "Sin coordenadas"
    
    try:
        partes = coordenadas.split(',')
        if len(partes) == 2:
            lat = float(partes[0].strip())
            lng = float(partes[1].strip())
            return f"{lat:.6f}, {lng:.6f}"
    except:
        pass
    
    return coordenadas


def formatear_ruc_nit(ruc: str) -> str:
    """
    Formatea RUC/NIT para visualización.
    
    Args:
        ruc: RUC/NIT a formatear
        
    Returns:
        str: RUC formateado
    """
    if not ruc:
        return ""
    
    # Remover caracteres no numéricos
    ruc_limpio = ''.join(filter(str.isdigit, ruc))
    
    # Formatear según longitud (ejemplo para Bolivia)
    if len(ruc_limpio) >= 7:
        # Formato: 1234567-0
        return f"{ruc_limpio[:-1]}-{ruc_limpio[-1]}"
    
    return ruc_limpio


def formatear_nombre_completo(nombre: str, apellido: str) -> str:
    """
    Formatea nombre completo.
    
    Args:
        nombre: Nombre(s)
        apellido: Apellido(s)
        
    Returns:
        str: Nombre completo formateado
    """
    partes = []
    
    if nombre:
        partes.append(capitalizar_texto(nombre))
    
    if apellido:
        partes.append(capitalizar_texto(apellido))
    
    return " ".join(partes)


def formatear_si_no(valor: bool) -> str:
    """
    Formatea un booleano a "Sí"/"No".
    
    Args:
        valor: Valor booleano
        
    Returns:
        str: "Sí" o "No"
    """
    return "Sí" if valor else "No"


def formatear_activo_inactivo(activo: bool) -> str:
    """
    Formatea estado activo/inactivo.
    
    Args:
        activo: Estado
        
    Returns:
        str: "Activo" o "Inactivo"
    """
    return "Activo" if activo else "Inactivo"


def formatear_tamanio_archivo(bytes: int) -> str:
    """
    Formatea tamaño de archivo en unidades legibles.
    
    Args:
        bytes: Tamaño en bytes
        
    Returns:
        str: Tamaño formateado (KB, MB, GB)
    """
    if bytes < 1024:
        return f"{bytes} B"
    elif bytes < 1024 * 1024:
        return f"{bytes / 1024:.2f} KB"
    elif bytes < 1024 * 1024 * 1024:
        return f"{bytes / (1024 * 1024):.2f} MB"
    else:
        return f"{bytes / (1024 * 1024 * 1024):.2f} GB"