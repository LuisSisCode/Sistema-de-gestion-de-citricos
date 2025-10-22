# backend/core/repositorio_base.py

from abc import ABC, abstractmethod
from backend.core.database import DatabaseConnection
from backend.core.config import Config  # ✅ IMPORTAR Config
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
        
        Args:
            server (str, optional): Nombre del servidor SQL Server.
            database (str, optional): Nombre de la base de datos.
            trusted_connection (bool, optional): Usar autenticación de Windows.
        """
        try:
            # ✅ USAR Config PARA VALORES POR DEFECTO (desde .env)
            if server is None:
                server = Config.DB_SERVER
            if database is None:
                database = Config.DB_DATABASE
            if trusted_connection is None:
                trusted_connection = Config.DB_TRUSTED_CONNECTION.lower() in ['yes', 'true', '1']
            
            # Crear conexión
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
    
    def _ejecutar_consulta(self, query, params=None, obtener_resultado=True):
        """
        Ejecuta una consulta de manera segura.
        
        Args:
            query (str): Consulta SQL a ejecutar.
            params (tuple, optional): Parámetros para la consulta.
            obtener_resultado (bool): Si debe retornar resultados.
            
        Returns:
            list o int: Resultados de la consulta o número de filas afectadas.
        """
        try:
            with self.db.get_connection() as conn:
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
        
        Args:
            query (str): Consulta SQL a ejecutar.
            params (tuple, optional): Parámetros para la consulta.
            
        Returns:
            any: Valor único retornado por la consulta.
        """
        try:
            with self.db.get_connection() as conn:
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
        """
        Obtiene el último ID insertado.
        
        Returns:
            int: ID del último registro insertado.
        """
        return self._ejecutar_consulta_escalar("SELECT @@IDENTITY AS ID")
    
    def _contar_registros(self, tabla, condicion=None, params=None):
        """
        Cuenta registros en una tabla con condición opcional.
        
        Args:
            tabla (str): Nombre de la tabla.
            condicion (str, optional): Condición WHERE.
            params (tuple, optional): Parámetros para la condición.
            
        Returns:
            int: Número de registros.
        """
        query = f"SELECT COUNT(*) FROM {tabla}"
        if condicion:
            query += f" WHERE {condicion}"
        
        return self._ejecutar_consulta_escalar(query, params)
    
    def _formatear_fecha(self, fecha):
        """
        Formatea una fecha de la base de datos a string.
        
        Args:
            fecha: Fecha de la base de datos.
            
        Returns:
            str: Fecha formateada como string.
        """
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
        """
        Valida parámetros de paginación.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            tuple: (pagina_validada, por_pagina_validada, offset)
        """
        pagina = max(1, pagina or 1)
        por_pagina = max(1, min(100, por_pagina or 10))
        offset = (pagina - 1) * por_pagina
        
        return pagina, por_pagina, offset
    
    def _calcular_total_paginas(self, total_registros, por_pagina):
        """
        Calcula el número total de páginas.
        
        Args:
            total_registros (int): Total de registros.
            por_pagina (int): Registros por página.
            
        Returns:
            int: Número total de páginas.
        """
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
    
    # IMPLEMENTAR MÉTODOS ABSTRACTOS (aunque no los usemos)
    def obtener_todos(self):
        """No aplicable para RelacionRepositorio."""
        return []
    
    def obtener_por_id(self, id_registro):
        """No aplicable para RelacionRepositorio."""
        return {}
    
    def crear(self, datos):
        """No aplicable para RelacionRepositorio."""
        return True, None
    
    def actualizar(self, id_registro, datos):
        """No aplicable para RelacionRepositorio."""
        return True
    
    def desactivar(self, id_registro):
        """No aplicable para RelacionRepositorio."""
        return True
    
    # MÉTODOS REALES DE RELACIONES
    def contar_parcelas_por_agricultor(self, id_agricultor):
        """
        Cuenta las parcelas activas de un agricultor específico.
        
        Args:
            id_agricultor (int): ID del agricultor.
            
        Returns:
            int: Número de parcelas activas del agricultor.
        """
        count = self._contar_registros(
            "Parcelas", 
            "id_agricultor = ? AND activo = 1", 
            (id_agricultor,)
        )
        
        print(f"Agricultor {id_agricultor} tiene {count} parcelas activas")
        return count
    
    def verificar_dependencias_agricultor(self, id_agricultor):
        """
        Verifica todas las dependencias de un agricultor antes de eliminarlo.
        
        Args:
            id_agricultor (int): ID del agricultor.
            
        Returns:
            dict: Información detallada de dependencias.
            
        Raises:
            RegistroTieneDependencias: Si tiene dependencias que impiden la eliminación.
        """
        # Contar parcelas
        parcelas = self.contar_parcelas_por_agricultor(id_agricultor)
        
        dependencias = {
            'parcelas': parcelas,
            'total_dependencias': parcelas,
            'puede_eliminar': parcelas == 0
        }
        
        if not dependencias['puede_eliminar']:
            mensaje = f"No se puede eliminar el agricultor. Tiene {parcelas} parcelas asociadas."
            raise RegistroTieneDependencias(mensaje, parcelas)
        
        print(f"Agricultor {id_agricultor} puede ser eliminado - sin dependencias")
        return dependencias