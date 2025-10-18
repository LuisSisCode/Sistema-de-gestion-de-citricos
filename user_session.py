import json
import os
import logging

# Configurar logging
logger = logging.getLogger('user_session')

def save_current_user(id_usuario, nombre, apellido, rol):
    """Guarda la información del usuario actual en un archivo"""
    try:
        user_data = {
            "id_usuario": id_usuario,
            "nombre": nombre,
            "apellido": apellido,
            "rol": rol
        }
        
        with open("current_user.json", "w") as f:
            json.dump(user_data, f)
            
        logger.info(f"Información del usuario guardada: ID={id_usuario}, Nombre={nombre} {apellido}")
    except Exception as e:
        logger.error(f"Error al guardar información del usuario: {e}")

def get_current_user_id():
    """Recupera el ID del usuario actual"""
    try:
        if os.path.exists("current_user.json"):
            with open("current_user.json", "r") as f:
                data = json.load(f)
                logger.info(f"ID de usuario recuperado: {data.get('id_usuario')}")
                return data.get("id_usuario")
    except Exception as e:
        logger.error(f"Error al obtener ID de usuario: {e}")
    
    # Si no se puede recuperar, se usa un valor por defecto
    logger.warning("Usando ID de usuario por defecto (22)")
    return 22  # ID de usuario por defecto (Luis)