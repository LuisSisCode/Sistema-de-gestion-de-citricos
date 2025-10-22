# utils/validators.py
"""
Utilidades de validación para AgroIchilo
"""

import re
from typing import Tuple


def validar_email(email: str) -> Tuple[bool, str]:
    """
    Valida formato de email.
    
    Args:
        email: Email a validar
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if not email:
        return False, "Email requerido"
    
    # Patrón regex para email
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    if not re.match(pattern, email):
        return False, "Formato de email inválido"
    
    return True, "OK"


def validar_identificacion(identificacion: str) -> Tuple[bool, str]:
    """
    Valida identificación (CI/NIT) para Bolivia.
    
    Args:
        identificacion: Número de identificación
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if not identificacion:
        return False, "Identificación requerida"
    
    # Remover espacios y guiones
    identificacion = identificacion.replace(' ', '').replace('-', '')
    
    # Validar que sea numérico
    if not identificacion.isdigit():
        return False, "Identificación debe ser numérica"
    
    # Validar longitud (Bolivia: 6-12 dígitos)
    if len(identificacion) < 6 or len(identificacion) > 12:
        return False, "Identificación debe tener entre 6 y 12 dígitos"
    
    return True, "OK"


def validar_telefono(telefono: str) -> Tuple[bool, str]:
    """
    Valida teléfono boliviano.
    
    Args:
        telefono: Número de teléfono
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if not telefono:
        return True, "OK"  # Teléfono es opcional
    
    # Remover espacios, guiones y paréntesis
    telefono_limpio = re.sub(r'[\s\-\(\)]', '', telefono)
    
    # Debe ser numérico
    if not telefono_limpio.isdigit():
        return False, "Teléfono debe contener solo números"
    
    # Longitud típica en Bolivia: 7-10 dígitos
    if len(telefono_limpio) < 7 or len(telefono_limpio) > 10:
        return False, "Teléfono debe tener entre 7 y 10 dígitos"
    
    return True, "OK"


def validar_area(area: float, min_val: float = 0.01, max_val: float = 10000.0) -> Tuple[bool, str]:
    """
    Valida área de parcela en hectáreas.
    
    Args:
        area: Área en hectáreas
        min_val: Valor mínimo permitido
        max_val: Valor máximo permitido
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if area <= 0:
        return False, "Área debe ser mayor a 0"
    
    if area < min_val:
        return False, f"Área mínima: {min_val} ha"
    
    if area > max_val:
        return False, f"Área máxima: {max_val} ha"
    
    return True, "OK"


def validar_precio(precio: float) -> Tuple[bool, str]:
    """
    Valida precio/monto.
    
    Args:
        precio: Precio a validar
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if precio < 0:
        return False, "Precio no puede ser negativo"
    
    # Validar que no tenga más de 2 decimales
    if round(precio, 2) != precio:
        return False, "Precio no puede tener más de 2 decimales"
    
    return True, "OK"


def validar_password(password: str, min_length: int = 6) -> Tuple[bool, str]:
    """
    Valida contraseña.
    
    Args:
        password: Contraseña a validar
        min_length: Longitud mínima
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if not password:
        return False, "Contraseña requerida"
    
    if len(password) < min_length:
        return False, f"Contraseña debe tener al menos {min_length} caracteres"
    
    # Validaciones opcionales de complejidad
    # if not any(c.isdigit() for c in password):
    #     return False, "Contraseña debe contener al menos un número"
    # if not any(c.isupper() for c in password):
    #     return False, "Contraseña debe contener al menos una mayúscula"
    
    return True, "OK"


def validar_username(username: str, min_length: int = 3) -> Tuple[bool, str]:
    """
    Valida nombre de usuario.
    
    Args:
        username: Nombre de usuario
        min_length: Longitud mínima
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if not username:
        return False, "Usuario requerido"
    
    if len(username) < min_length:
        return False, f"Usuario debe tener al menos {min_length} caracteres"
    
    # Solo alfanuméricos y guión bajo
    if not re.match(r'^[a-zA-Z0-9_]+$', username):
        return False, "Usuario solo puede contener letras, números y guión bajo"
    
    return True, "OK"


def validar_cantidad(cantidad: int, min_val: int = 1) -> Tuple[bool, str]:
    """
    Valida una cantidad (debe ser entero positivo).
    
    Args:
        cantidad: Cantidad a validar
        min_val: Valor mínimo permitido
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if not isinstance(cantidad, int):
        return False, "Cantidad debe ser un número entero"
    
    if cantidad < min_val:
        return False, f"Cantidad mínima: {min_val}"
    
    return True, "OK"


def validar_texto_requerido(texto: str, campo: str = "Campo") -> Tuple[bool, str]:
    """
    Valida que un texto no esté vacío.
    
    Args:
        texto: Texto a validar
        campo: Nombre del campo (para mensaje de error)
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if not texto or not texto.strip():
        return False, f"{campo} requerido"
    
    return True, "OK"


def validar_rango_fecha(fecha_inicio, fecha_fin) -> Tuple[bool, str]:
    """
    Valida que un rango de fechas sea válido.
    
    Args:
        fecha_inicio: Fecha de inicio
        fecha_fin: Fecha de fin
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if not fecha_inicio:
        return False, "Fecha de inicio requerida"
    
    if not fecha_fin:
        return False, "Fecha de fin requerida"
    
    if fecha_inicio > fecha_fin:
        return False, "Fecha de inicio debe ser anterior a fecha de fin"
    
    return True, "OK"


def validar_coordenadas_gps(coordenadas: str) -> Tuple[bool, str]:
    """
    Valida formato de coordenadas GPS (latitude, longitude).
    Formato esperado: "lat,long" o "lat, long"
    
    Args:
        coordenadas: Coordenadas en formato texto
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if not coordenadas:
        return True, "OK"  # Coordenadas opcionales
    
    # Limpiar espacios
    coordenadas = coordenadas.strip()
    
    # Verificar formato básico
    if ',' not in coordenadas:
        return False, "Formato inválido. Use: latitud,longitud"
    
    try:
        # Separar y convertir a float
        partes = coordenadas.split(',')
        
        if len(partes) != 2:
            return False, "Debe contener exactamente latitud y longitud"
        
        lat = float(partes[0].strip())
        lng = float(partes[1].strip())
        
        # Validar rangos
        if not (-90 <= lat <= 90):
            return False, "Latitud debe estar entre -90 y 90"
        
        if not (-180 <= lng <= 180):
            return False, "Longitud debe estar entre -180 y 180"
        
        return True, "OK"
        
    except ValueError:
        return False, "Coordenadas deben ser números válidos"


def validar_porcentaje(porcentaje: float) -> Tuple[bool, str]:
    """
    Valida un porcentaje (0-100).
    
    Args:
        porcentaje: Porcentaje a validar
        
    Returns:
        tuple: (válido: bool, mensaje: str)
    """
    if porcentaje < 0 or porcentaje > 100:
        return False, "Porcentaje debe estar entre 0 y 100"
    
    return True, "OK"