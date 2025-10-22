# backend/utils/password_utils.py
"""
Utilidades para manejo seguro de contraseñas
"""

import hashlib
import secrets
import hmac
import string
import random
from typing import Tuple


class PasswordUtils:
    """Utilidades para manejo seguro de contraseñas"""
    
    @staticmethod
    def hash_password(password: str, salt: str = None) -> Tuple[str, str]:
        """
        Genera hash de contraseña con salt usando PBKDF2
        
        Args:
            password: Contraseña en texto plano
            salt: Salt opcional (si no se provee, se genera uno nuevo)
            
        Returns:
            tuple: (hash, salt)
        """
        if salt is None:
            # Generar salt aleatorio de 64 caracteres
            salt = secrets.token_hex(32)
        
        # Usar PBKDF2 con SHA256 y 100k iteraciones
        password_hash = hashlib.pbkdf2_hmac(
            'sha256',
            password.encode('utf-8'),
            salt.encode('utf-8'),
            100000  # 100k iteraciones para mayor seguridad
        )
        
        return password_hash.hex(), salt
    
    @staticmethod
    def verify_password(password: str, hash: str, salt: str) -> bool:
        """
        Verifica si una contraseña coincide con su hash
        
        Args:
            password: Contraseña en texto plano
            hash: Hash almacenado
            salt: Salt usado al generar el hash
            
        Returns:
            bool: True si la contraseña es correcta
        """
        new_hash, _ = PasswordUtils.hash_password(password, salt)
        
        # Usar comparación segura para evitar timing attacks
        return hmac.compare_digest(new_hash, hash)
    
    @staticmethod
    def hash_password_simple(password: str) -> str:
        """
        Hash simple SHA256 (para compatibilidad con datos existentes)
        
        Args:
            password: Contraseña en texto plano
            
        Returns:
            str: Hash SHA256
        """
        return hashlib.sha256(password.encode()).hexdigest()
    
    @staticmethod
    def verify_password_simple(password: str, hash: str) -> bool:
        """
        Verifica contraseña con hash simple SHA256
        
        Args:
            password: Contraseña en texto plano
            hash: Hash SHA256 almacenado
            
        Returns:
            bool: True si coincide
        """
        calculated_hash = PasswordUtils.hash_password_simple(password)
        return hmac.compare_digest(calculated_hash, hash)
    
    @staticmethod
    def generar_password_temporal(length: int = 12) -> str:
        """
        Genera una contraseña temporal segura
        
        Args:
            length: Longitud de la contraseña (mínimo 8, default 12)
            
        Returns:
            str: Contraseña temporal
        """
        if length < 8:
            length = 8
        
        # Caracteres permitidos
        caracteres = string.ascii_letters + string.digits + "!@#$%&"
        
        # Asegurar que tenga al menos:
        # - 1 mayúscula
        # - 1 minúscula
        # - 1 número
        # - 1 símbolo
        password = [
            random.choice(string.ascii_uppercase),
            random.choice(string.ascii_lowercase),
            random.choice(string.digits),
            random.choice("!@#$%&")
        ]
        
        # Completar con caracteres aleatorios
        for _ in range(length - 4):
            password.append(random.choice(caracteres))
        
        # Mezclar aleatoriamente
        random.shuffle(password)
        
        return ''.join(password)
    
    @staticmethod
    def validar_fortaleza_password(password: str) -> Tuple[bool, str, int]:
        """
        Valida la fortaleza de una contraseña
        
        Args:
            password: Contraseña a validar
            
        Returns:
            tuple: (es_fuerte: bool, mensaje: str, puntuacion: int (0-100))
        """
        puntuacion = 0
        problemas = []
        
        # Longitud
        if len(password) < 6:
            problemas.append("muy corta (mínimo 6 caracteres)")
        elif len(password) >= 8:
            puntuacion += 20
        elif len(password) >= 12:
            puntuacion += 30
        
        # Tiene mayúsculas
        if any(c.isupper() for c in password):
            puntuacion += 20
        else:
            problemas.append("sin mayúsculas")
        
        # Tiene minúsculas
        if any(c.islower() for c in password):
            puntuacion += 20
        else:
            problemas.append("sin minúsculas")
        
        # Tiene números
        if any(c.isdigit() for c in password):
            puntuacion += 20
        else:
            problemas.append("sin números")
        
        # Tiene símbolos
        if any(c in "!@#$%^&*()_+-=[]{}|;:,.<>?" for c in password):
            puntuacion += 20
        else:
            problemas.append("sin símbolos")
        
        # Determinar fortaleza
        if puntuacion >= 80:
            nivel = "Fuerte"
            es_fuerte = True
        elif puntuacion >= 60:
            nivel = "Media"
            es_fuerte = True
        else:
            nivel = "Débil"
            es_fuerte = False
        
        if problemas:
            mensaje = f"{nivel}: {', '.join(problemas)}"
        else:
            mensaje = f"{nivel}: Contraseña segura"
        
        return es_fuerte, mensaje, puntuacion


# Funciones de conveniencia
def hash_password(password: str) -> Tuple[str, str]:
    """Función de conveniencia para hash de contraseña"""
    return PasswordUtils.hash_password(password)


def verify_password(password: str, hash: str, salt: str) -> bool:
    """Función de conveniencia para verificar contraseña"""
    return PasswordUtils.verify_password(password, hash, salt)


def generar_password() -> str:
    """Función de conveniencia para generar password temporal"""
    return PasswordUtils.generar_password_temporal()