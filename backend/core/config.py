# backend/core/config.py
"""
Configuración centralizada del sistema AgroIchilo
"""

import os
import sys
from pathlib import Path
from typing import Optional


class Config:
    """Configuración centralizada del sistema AgroIchilo"""
    
    # RUTAS BASE
    if getattr(sys, 'frozen', False):
        # Ejecutable (PyInstaller)
        BASE_DIR = Path(os.environ.get('APPDATA', '.')) / 'AgroIchilo'
        BASE_DIR.mkdir(parents=True, exist_ok=True)
    else:
        # Desarrollo
        BASE_DIR = Path(__file__).resolve().parent.parent.parent
    
    # ARCHIVOS
    ENV_FILE = BASE_DIR / ".env"
    
    # BASE DE DATOS (valores por defecto)
    DB_SERVER: str = "localhost\\SQLEXPRESS"
    DB_DATABASE: str = "Produccion_Agro"
    DB_TRUSTED_CONNECTION: str = "yes"
    DB_TIMEOUT: int = 30
    
    # APLICACIÓN
    APP_NAME: str = "AgroIchilo"
    APP_VERSION: str = "1.0.0"
    EMPRESA_NOMBRE: str = "AgroIchilo"
    EMPRESA_RUC: str = ""
    MONEDA: str = "BOB"
    
    # CONFIGURACIÓN DE ALERTAS
    DIAS_ALERTA_VENCIMIENTO_AGROQUIMICOS: int = 30
    STOCK_MINIMO_AGROQUIMICOS: int = 5
    
    # REPORTES
    REPORTS_DIR: str = "reportes"
    
    # SISTEMA
    FIRST_TIME_SETUP: bool = True
    SECRET_KEY: str = "agroichilo-secret-2025"
    LOG_LEVEL: str = "INFO"
    
    @classmethod
    def load_from_env(cls):
        """Carga la configuración desde el archivo .env"""
        if not cls.ENV_FILE.exists():
            print(f"⚠️  Archivo .env no encontrado en: {cls.ENV_FILE}")
            return False
        
        try:
            with open(cls.ENV_FILE, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    # Saltar líneas vacías, comentarios y secciones
                    if not line or line.startswith('#') or line.startswith('['):
                        continue
                    
                    if '=' in line:
                        key, value = line.split('=', 1)
                        key = key.strip()
                        value = value.strip()
                        
                        # Asignar valores según la clave
                        if key == "DB_SERVER":
                            cls.DB_SERVER = value
                        elif key == "DB_DATABASE":
                            cls.DB_DATABASE = value
                        elif key == "DB_TRUSTED_CONNECTION":
                            cls.DB_TRUSTED_CONNECTION = value
                        elif key == "DB_TIMEOUT":
                            cls.DB_TIMEOUT = int(value)
                        elif key == "EMPRESA_NOMBRE":
                            cls.EMPRESA_NOMBRE = value
                        elif key == "EMPRESA_RUC":
                            cls.EMPRESA_RUC = value
                        elif key == "MONEDA":
                            cls.MONEDA = value
                        elif key == "DIAS_ALERTA_VENCIMIENTO_AGROQUIMICOS":
                            cls.DIAS_ALERTA_VENCIMIENTO_AGROQUIMICOS = int(value)
                        elif key == "STOCK_MINIMO_AGROQUIMICOS":
                            cls.STOCK_MINIMO_AGROQUIMICOS = int(value)
                        elif key == "FIRST_TIME_SETUP":
                            cls.FIRST_TIME_SETUP = value.lower() in ['true', 'yes', '1']
                        elif key == "REPORTS_DIR":
                            cls.REPORTS_DIR = value
                        elif key == "LOG_LEVEL":
                            cls.LOG_LEVEL = value
                        elif key == "SECRET_KEY":
                            cls.SECRET_KEY = value
            
            print(f"✅ Configuración cargada desde: {cls.ENV_FILE}")
            return True
            
        except Exception as e:
            print(f"❌ Error cargando configuración: {e}")
            return False
    
    @classmethod
    def get_db_connection_string(cls) -> str:
        """Genera la cadena de conexión a SQL Server"""
        conn_str = f"DRIVER={{SQL Server}};SERVER={cls.DB_SERVER};DATABASE={cls.DB_DATABASE};"
        
        if cls.DB_TRUSTED_CONNECTION.lower() in ['yes', 'true', '1']:
            conn_str += "Trusted_Connection=yes;"
        
        return conn_str
    
    @classmethod
    def is_first_time(cls) -> bool:
        """Verifica si es la primera ejecución"""
        return not cls.ENV_FILE.exists() or cls.FIRST_TIME_SETUP
    
    @classmethod
    def get_reports_path(cls) -> Path:
        """Obtiene la ruta completa para reportes"""
        reports_path = cls.BASE_DIR / cls.REPORTS_DIR
        reports_path.mkdir(parents=True, exist_ok=True)
        return reports_path


# Cargar configuración al importar el módulo
Config.load_from_env()