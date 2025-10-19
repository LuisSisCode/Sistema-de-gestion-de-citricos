import threading
import time
import logging
from flask import Flask
import socket
import sys
import os

# Importar el servicio Flask original
from recursos.mapa.mapa_service import app as flask_app

logger = logging.getLogger(__name__)

class MapaServiceIntegrado:
    """Clase para ejecutar el servicio Flask en un hilo separado dentro de la aplicación QML"""
    
    def __init__(self, host='127.0.0.1', port=5001):
        self.host = host
        self.port = port
        self.flask_thread = None
        self.running = False
        
    def verificar_puerto_disponible(self):
        """Verifica si el puerto está disponible"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex((self.host, self.port))
            sock.close()
            return result != 0  # True si el puerto está libre
        except:
            return True
    
    def iniciar_servicio(self):
        """Inicia el servicio Flask en un hilo separado"""
        if self.running:
            logger.info("🟢 Servicio de mapas ya está ejecutándose")
            return True
            
        if not self.verificar_puerto_disponible():
            logger.warning(f"⚠️ Puerto {self.port} ya está en uso. El servicio puede estar ejecutándose externamente.")
            return False
        
        try:
            # Configurar Flask para producción (sin debug en hilo)
            flask_app.config['DEBUG'] = False
            flask_app.config['TESTING'] = False
            
            # Crear y iniciar el hilo
            self.flask_thread = threading.Thread(
                target=self._ejecutar_flask,
                daemon=True,  # Se cierra cuando la aplicación principal se cierra
                name="MapaServiceThread"
            )
            
            self.flask_thread.start()
            
            # Esperar un poco para verificar que se inició correctamente
            time.sleep(2)
            
            if self._verificar_servicio_activo():
                self.running = True
                logger.info(f"✅ Servicio de mapas iniciado en http://{self.host}:{self.port}")
                return True
            else:
                logger.error("❌ Error: El servicio no se inició correctamente")
                return False
                
        except Exception as e:
            logger.error(f"❌ Error iniciando servicio de mapas: {str(e)}")
            return False
    
    def _ejecutar_flask(self):
        """Ejecuta Flask en el hilo separado"""
        try:
            # Suprimir logs de Flask para evitar spam en consola
            log = logging.getLogger('werkzeug')
            log.setLevel(logging.ERROR)
            
            # Ejecutar Flask
            flask_app.run(
                host=self.host,
                port=self.port,
                debug=False,
                use_reloader=False,  # Importante: deshabilitar reloader en hilos
                threaded=True
            )
        except Exception as e:
            logger.error(f"❌ Error en hilo Flask: {str(e)}")
    
    def _verificar_servicio_activo(self):
        """Verifica si el servicio está respondiendo"""
        try:
            import urllib.request
            url = f"http://{self.host}:{self.port}/api/health"
            
            # Intentar conectar con timeout corto
            with urllib.request.urlopen(url, timeout=5) as response:
                return response.status == 200
        except:
            return False
    
    def detener_servicio(self):
        """Detiene el servicio (en realidad solo marca como detenido)"""
        self.running = False
        logger.info("🛑 Servicio de mapas marcado para detener")
    
    def esta_activo(self):
        """Verifica si el servicio está activo"""
        if not self.running:
            return False
        return self._verificar_servicio_activo()
    
    def obtener_url_mapa(self):
        """Obtiene la URL del mapa web"""
        return f"http://{self.host}:{self.port}/mapa"
    
    def obtener_url_api(self):
        """Obtiene la URL base de la API"""
        return f"http://{self.host}:{self.port}/api"

# Instancia global del servicio
servicio_mapa = MapaServiceIntegrado()

def inicializar_servicio_mapa():
    """Función para inicializar el servicio desde la aplicación principal"""
    return servicio_mapa.iniciar_servicio()

def obtener_url_mapa():
    """Función para obtener la URL del mapa"""
    return servicio_mapa.obtener_url_mapa()

def verificar_servicio_activo():
    """Función para verificar si el servicio está activo"""
    return servicio_mapa.esta_activo()