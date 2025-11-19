# backend/core/repositorio_base.py

from abc import ABC, abstractmethod
from backend.core.database import DatabaseConnection
from backend.core.config import Config
from backend.core.excepciones_bd import (
    ErrorConexion,
    ErrorConsulta,
    RegistroNoEncontrado,
    RegistroTieneDependencias
)
from backend.core.cache_system import cache_manager, cacheable, cache_invalidator, get_ttl


class RepositorioBase(ABC):
    """Clase base para todos los repositorios."""
    
    def __init__(self, server=None, database=None, trusted_connection=None):
        """
        Inicializa la conexión a la base de datos.
        """
        try:
            # Usar Config para valores por defecto
            if server is None:
                server = Config.DB_SERVER
            if database is None:
                database = Config.DB_DATABASE
            if trusted_connection is None:
                trusted_connection = Config.DB_TRUSTED_CONNECTION.lower() in ['yes', 'true', '1']
            
            # Crear instancia de conexión (Singleton)
            self.db = DatabaseConnection(server, database, trusted_connection)
            
            # Configurar namespace de caché basado en el nombre de la clase
            class_name = self.__class__.__name__.lower()
            if 'repositorio' in class_name:
                self._cache_namespace = class_name.replace('repositorio', '')
            else:
                self._cache_namespace = class_name
            
            print(f"Conexión establecida en {self.__class__.__name__}")
            
        except Exception as e:
            print(f"Error al establecer conexión en {self.__class__.__name__}: {str(e)}")
            raise ErrorConexion(f"No se pudo conectar a la base de datos: {str(e)}")

    def get_connection(self):
        """
        Obtiene el objeto de conexión de la instancia de base de datos.
        Este método es crucial para que los repositorios hijos puedan usar 'with self.get_connection()'.
        """
        return self.db.get_connection()
    
    def _ejecutar_consulta(self, query, params=None, obtener_resultado=True):
        """
        Ejecuta una consulta de manera segura.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                if params:
                    cursor.execute(query, params)
                else:
                    cursor.execute(query)
                
                if obtener_resultado:
                    return cursor.fetchall()
                else:
                    conn.commit()
                    return cursor.rowcount
        except Exception as e:
            print(f"Error ejecutando consulta: {str(e)}")
            raise ErrorConsulta(f"Error en la consulta: {str(e)}")
    
    def _ejecutar_consulta_escalar(self, query, params=None):
        """
        Ejecuta una consulta que retorna un solo valor.
        """
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                
                if params:
                    cursor.execute(query, params)
                else:
                    cursor.execute(query)
                
                resultado = cursor.fetchone()
                return resultado[0] if resultado else None
        except Exception as e:
            print(f"Error ejecutando consulta escalar: {str(e)}")
            raise ErrorConsulta(f"Error en la consulta escalar: {str(e)}")
    
    def _obtener_ultimo_id(self):
        """Obtiene el último ID insertado."""
        resultado = self._ejecutar_consulta_escalar("SELECT SCOPE_IDENTITY() AS ID")
        return int(resultado) if resultado else None
    
    def _contar_registros(self, tabla, condicion=None, params=None):
        """Cuenta registros en una tabla con condición opcional."""
        query = f"SELECT COUNT(*) FROM {tabla}"
        if condicion:
            query += f" WHERE {condicion}"
        
        return self._ejecutar_consulta_escalar(query, params)
    
    def _formatear_fecha(self, fecha):
        """Formatea una fecha de la base de datos a string."""
        if not fecha:
            return None
            
        if isinstance(fecha, str):
            return fecha
        else:
            try:
                return fecha.strftime('%Y-%m-%d')
            except AttributeError:
                return str(fecha)
    
    def _validar_parametros_paginacion(self, pagina, por_pagina):
        """Valida parámetros de paginación."""
        pagina = max(1, pagina or 1)
        por_pagina = max(1, min(100, por_pagina or 10))
        offset = (pagina - 1) * por_pagina
        
        return pagina, por_pagina, offset
    
    def _calcular_total_paginas(self, total_registros, por_pagina):
        """Calcula el número total de páginas."""
        return (total_registros + por_pagina - 1) // por_pagina
    
    # Métodos de caché
    def cache_get(self, key: str):
        """Obtiene un valor del caché"""
        return cache_manager.get(self._cache_namespace, key)
    
    def cache_set(self, key: str, value, ttl: int = None):
        """Guarda un valor en el caché"""
        ttl = ttl or get_ttl(self._cache_namespace)
        cache_manager.set(self._cache_namespace, value, key, ttl)
    
    def cache_invalidate(self, key: str = None):
        """Invalida el caché"""
        cache_manager.invalidate(self._cache_namespace, key)


class RelacionRepositorio(RepositorioBase):
    """Repositorio para consultas que involucran múltiples tablas."""
    
    def obtener_todos(self):
        return []
    
    def obtener_por_id(self, id_registro):
        return {}
    
    def crear(self, datos):
        return True, None
    
    def actualizar(self, id_registro, datos):
        return True
    
    def desactivar(self, id_registro):
        return True
    
    # MÉTODOS REALES DE RELACIONES
    def contar_parcelas_por_productor(self, id_productor):
        count = self._contar_registros(
            "Parcelas", 
            "id_productor = ? AND activo = 1", 
            (id_productor,)
        )
        print(f"Agricultor {id_productor} tiene {count} parcelas activas")
        return count
    
    def verificar_dependencias_productor(self, id_productor):
        parcelas = self.contar_parcelas_por_productor(id_productor)
        
        dependencias = {
            'parcelas': parcelas,
            'total_dependencias': parcelas,
            'puede_eliminar': parcelas == 0
        }
        
        if not dependencias['puede_eliminar']:
            mensaje = f"No se puede eliminar el productor. Tiene {parcelas} parcelas asociadas."
            raise RegistroTieneDependencias(mensaje, parcelas)
        
        print(f"Agricultor {id_productor} puede ser eliminado - sin dependencias")
        return dependencias