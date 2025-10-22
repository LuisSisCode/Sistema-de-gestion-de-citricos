# backend/core/config_manager.py
"""
Gestor de configuración - Crea, lee y actualiza el archivo .env
"""

import os
import sys
from pathlib import Path
from typing import Dict, Optional, Tuple


class ConfigManager:
    """Gestor para crear y mantener el archivo .env de configuración"""
    
    def __init__(self):
        """Inicializa el gestor de configuración"""
        # Determinar ubicación del archivo .env
        if getattr(sys, 'frozen', False):
            # Ejecutable - usar APPDATA
            self.base_dir = Path(os.environ.get('APPDATA', '.')) / 'AgroIchilo'
            self.base_dir.mkdir(parents=True, exist_ok=True)
        else:
            # Desarrollo - usar raíz del proyecto
            self.base_dir = Path(__file__).resolve().parent.parent.parent
        
        self.env_file = self.base_dir / ".env"
        print(f"📁 Ubicación .env: {self.env_file}")
    
    def existe_configuracion(self) -> bool:
        """Verifica si el archivo .env existe"""
        return self.env_file.exists()
    
    def leer_configuracion(self) -> Dict[str, str]:
        """
        Lee la configuración actual del archivo .env
        
        Returns:
            dict: Diccionario con la configuración actual
        """
        configuracion = {}
        
        if not self.existe_configuracion():
            print("⚠️  Archivo .env no existe")
            return configuracion
        
        try:
            with open(self.env_file, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    # Saltar líneas vacías, comentarios y secciones
                    if not line or line.startswith('#') or line.startswith('['):
                        continue
                    
                    if '=' in line:
                        key, value = line.split('=', 1)
                        configuracion[key.strip()] = value.strip()
            
            print(f"✅ Configuración leída: {len(configuracion)} valores")
            return configuracion
            
        except Exception as e:
            print(f"❌ Error leyendo configuración: {e}")
            return {}
    
    def crear_configuracion(
        self,
        server: str = "localhost\\SQLEXPRESS",
        database: str = "Produccion_Agro",
        trusted_connection: str = "yes",
        empresa_nombre: str = "AgroIchilo",
        empresa_ruc: str = "",
        moneda: str = "BOB"
    ) -> Tuple[bool, str]:
        """
        Crea un nuevo archivo .env con la configuración proporcionada
        
        Args:
            server: Servidor SQL Server
            database: Nombre de la base de datos
            trusted_connection: Usar autenticación de Windows (yes/no)
            empresa_nombre: Nombre de la empresa
            empresa_ruc: RUC/NIT de la empresa
            moneda: Moneda (BOB, USD, etc.)
            
        Returns:
            tuple: (éxito: bool, mensaje: str)
        """
        try:
            template = f"""# ============================================
# CONFIGURACIÓN - SISTEMA AGROICHILO
# ============================================
# Archivo generado automáticamente por Setup Wizard
# Fecha de creación: {self._obtener_fecha_actual()}

# ============================================
# BASE DE DATOS
# ============================================
DB_SERVER={server}
DB_DATABASE={database}
DB_TRUSTED_CONNECTION={trusted_connection}
DB_TIMEOUT=30

# ============================================
# INFORMACIÓN DE LA EMPRESA
# ============================================
EMPRESA_NOMBRE={empresa_nombre}
EMPRESA_RUC={empresa_ruc}
MONEDA={moneda}

# ============================================
# CONFIGURACIÓN DE ALERTAS
# ============================================
# Días antes del vencimiento para alertar
DIAS_ALERTA_VENCIMIENTO_AGROQUIMICOS=30

# Stock mínimo antes de alertar
STOCK_MINIMO_AGROQUIMICOS=5

# ============================================
# APLICACIÓN
# ============================================
FIRST_TIME_SETUP=False
REPORTS_DIR=reportes
LOG_LEVEL=INFO

# ============================================
# SEGURIDAD
# ============================================
SECRET_KEY=agroichilo-secret-key-2025
"""
            
            with open(self.env_file, 'w', encoding='utf-8') as f:
                f.write(template)
            
            print(f"✅ Archivo .env creado exitosamente en: {self.env_file}")
            return True, "Configuración creada exitosamente"
            
        except Exception as e:
            error_msg = f"Error creando configuración: {e}"
            print(f"❌ {error_msg}")
            return False, error_msg
    
    def actualizar_configuracion(self, key: str, value: str) -> Tuple[bool, str]:
        """
        Actualiza un valor específico en el archivo .env
        
        Args:
            key: Clave a actualizar
            value: Nuevo valor
            
        Returns:
            tuple: (éxito: bool, mensaje: str)
        """
        if not self.existe_configuracion():
            return False, "Archivo .env no existe"
        
        try:
            # Leer configuración actual
            with open(self.env_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # Actualizar la línea correspondiente
            actualizado = False
            for i, line in enumerate(lines):
                line_strip = line.strip()
                
                # Saltar líneas vacías, comentarios y secciones
                if not line_strip or line_strip.startswith('#') or line_strip.startswith('['):
                    continue
                
                if '=' in line_strip:
                    current_key = line_strip.split('=', 1)[0].strip()
                    if current_key == key:
                        lines[i] = f"{key}={value}\n"
                        actualizado = True
                        break
            
            if not actualizado:
                # Si la clave no existe, agregarla al final
                lines.append(f"\n{key}={value}\n")
            
            # Escribir cambios
            with open(self.env_file, 'w', encoding='utf-8') as f:
                f.writelines(lines)
            
            print(f"✅ Configuración actualizada: {key}={value}")
            return True, f"Valor {key} actualizado"
            
        except Exception as e:
            error_msg = f"Error actualizando configuración: {e}"
            print(f"❌ {error_msg}")
            return False, error_msg
    
    def marcar_setup_completado(self) -> Tuple[bool, str]:
        """
        Marca el setup inicial como completado (FIRST_TIME_SETUP=False)
        
        Returns:
            tuple: (éxito: bool, mensaje: str)
        """
        return self.actualizar_configuracion("FIRST_TIME_SETUP", "False")
    
    def es_primera_vez(self) -> bool:
        """
        Detecta si es la primera ejecución del sistema
        
        Returns:
            bool: True si es primera vez, False si ya está configurado
        """
        if not self.existe_configuracion():
            return True
        
        config = self.leer_configuracion()
        first_time = config.get("FIRST_TIME_SETUP", "True")
        
        return first_time.lower() in ['true', 'yes', '1']
    
    def obtener_valor(self, key: str, default: str = "") -> str:
        """
        Obtiene un valor específico de la configuración
        
        Args:
            key: Clave a buscar
            default: Valor por defecto si no existe
            
        Returns:
            str: Valor de la configuración
        """
        config = self.leer_configuracion()
        return config.get(key, default)
    
    def validar_configuracion_bd(self) -> Tuple[bool, str]:
        """
        Valida que la configuración de base de datos sea correcta
        
        Returns:
            tuple: (válido: bool, mensaje: str)
        """
        if not self.existe_configuracion():
            return False, "Archivo .env no existe"
        
        config = self.leer_configuracion()
        
        # Verificar campos obligatorios
        campos_requeridos = ["DB_SERVER", "DB_DATABASE"]
        faltantes = [campo for campo in campos_requeridos if campo not in config]
        
        if faltantes:
            return False, f"Faltan campos: {', '.join(faltantes)}"
        
        # Verificar que no estén vacíos
        vacios = [campo for campo in campos_requeridos if not config[campo]]
        
        if vacios:
            return False, f"Campos vacíos: {', '.join(vacios)}"
        
        return True, "Configuración válida"
    
    def _obtener_fecha_actual(self) -> str:
        """Obtiene la fecha actual formateada"""
        from datetime import datetime
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    def mostrar_configuracion(self):
        """Muestra la configuración actual de manera legible"""
        print("\n" + "="*50)
        print("📋 CONFIGURACIÓN ACTUAL")
        print("="*50)
        
        config = self.leer_configuracion()
        
        if not config:
            print("⚠️  Sin configuración")
            return
        
        # Agrupar por secciones
        secciones = {
            "BASE DE DATOS": ["DB_SERVER", "DB_DATABASE", "DB_TRUSTED_CONNECTION", "DB_TIMEOUT"],
            "EMPRESA": ["EMPRESA_NOMBRE", "EMPRESA_RUC", "MONEDA"],
            "ALERTAS": ["DIAS_ALERTA_VENCIMIENTO_AGROQUIMICOS", "STOCK_MINIMO_AGROQUIMICOS"],
            "APLICACIÓN": ["FIRST_TIME_SETUP", "REPORTS_DIR", "LOG_LEVEL"],
        }
        
        for seccion, keys in secciones.items():
            print(f"\n{seccion}:")
            print("-" * 40)
            for key in keys:
                value = config.get(key, "No configurado")
                # Ocultar SECRET_KEY por seguridad
                if key == "SECRET_KEY":
                    value = "***" + value[-4:] if len(value) > 4 else "****"
                print(f"  {key:40} = {value}")
        
        print("\n" + "="*50)


# Función de conveniencia para uso rápido
def crear_configuracion_inicial(**kwargs):
    """
    Crea una configuración inicial de manera sencilla
    
    Args:
        **kwargs: Parámetros de configuración
        
    Returns:
        ConfigManager: Instancia del gestor
    """
    manager = ConfigManager()
    
    if not manager.existe_configuracion():
        exito, mensaje = manager.crear_configuracion(**kwargs)
        if exito:
            print("✅ Configuración inicial creada")
        else:
            print(f"❌ Error: {mensaje}")
    else:
        print("ℹ️  La configuración ya existe")
    
    return manager