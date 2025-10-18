# bd_capa/nucleo/repositorio_base.py

from abc import ABC, abstractmethod
from .bd_connection import DatabaseConnection
from .excepciones_bd import ErrorConexion, ErrorConsulta,RegistroNoEncontrado, RegistroTieneDependencias
# AGREGAR ESTA LÍNEA después de los imports existentes
from .cache_system import cache_manager, cacheable, cache_invalidator, get_ttl

class RepositorioBase(ABC):
    """Clase base para todos los repositorios."""
    
    def __init__(self, server=None, database=None, trusted_connection=True):
        """
        Inicializa la conexión a la base de datos.
        
        Args:
            server (str): Nombre del servidor SQL Server.
            database (str): Nombre de la base de datos.
            trusted_connection (bool): Usar autenticación de Windows.
        """
        try:
            if server and database:
                self.db = DatabaseConnection(server, database, trusted_connection)
            else:
                self.db = DatabaseConnection("DESKTOP-NVQ729A", "Producto_Citricos")
                
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
        
        # En futuras versiones podríamos verificar otras dependencias:
        # - Cultivos asociados
        # - Transacciones de ventas
        # - Contratos
        
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
    
    def obtener_propietarios_activos(self):
        """
        Obtiene la lista de agricultores que son propietarios activos.
        
        Returns:
            list: Lista de propietarios con formato {id, nombre}.
        """
        query = """
        SELECT id_agricultor, nombre, apellido
        FROM Agricultores
        WHERE es_propietario = 1 AND activo = 1
        ORDER BY nombre, apellido
        """
        
        rows = self._ejecutar_consulta(query)
        propietarios = []
        
        for row in rows:
            propietario = {
                'id': row.id_agricultor,
                'nombre': f"{row.nombre} {row.apellido}"
            }
            propietarios.append(propietario)
        
        print(f"Se obtuvieron {len(propietarios)} propietarios activos")
        return propietarios
    
    def obtener_estadisticas_generales(self):
        """
        Obtiene estadísticas generales del sistema.
        
        Returns:
            dict: Estadísticas completas del sistema.
        """
        query = """
        SELECT 
            (SELECT COUNT(*) FROM Agricultores WHERE activo = 1) as total_agricultores,
            (SELECT COUNT(*) FROM Agricultores WHERE es_propietario = 1 AND activo = 1) as total_propietarios,
            (SELECT COUNT(*) FROM Parcelas WHERE activo = 1) as total_parcelas,
            (SELECT COALESCE(SUM(area_total), 0) FROM Parcelas WHERE activo = 1) as area_total,
            (SELECT COALESCE(AVG(area_total), 0) FROM Parcelas WHERE activo = 1) as area_promedio
        """
        
        row = self._ejecutar_consulta(query)[0]
        
        estadisticas = {
            'agricultores': {
                'total': row.total_agricultores,
                'propietarios': row.total_propietarios,
                'trabajadores': row.total_agricultores - row.total_propietarios
            },
            'parcelas': {
                'total': row.total_parcelas,
                'area_total': float(row.area_total),
                'area_promedio': float(row.area_promedio)
            }
        }
        
        print(f"Estadísticas generales calculadas: {estadisticas}")
        return estadisticas
    
    def obtener_distribución_parcelas_por_propietario(self):
        """
        Obtiene la distribución de parcelas por propietario.
        
        Returns:
            list: Lista con propietarios y cantidad de parcelas.
        """
        query = """
        SELECT 
            a.id_agricultor,
            a.nombre + ' ' + a.apellido as nombre_propietario,
            COUNT(p.id_parcela) as cantidad_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total
        FROM Agricultores a
        LEFT JOIN Parcelas p ON a.id_agricultor = p.id_agricultor AND p.activo = 1
        WHERE a.es_propietario = 1 AND a.activo = 1
        GROUP BY a.id_agricultor, a.nombre, a.apellido
        ORDER BY cantidad_parcelas DESC, area_total DESC
        """
        
        rows = self._ejecutar_consulta(query)
        distribución = []
        
        for row in rows:
            item = {
                'id_agricultor': row.id_agricultor,
                'nombre_propietario': row.nombre_propietario,
                'cantidad_parcelas': row.cantidad_parcelas,
                'area_total': float(row.area_total)
            }
            distribución.append(item)
        
        print(f"Distribución calculada para {len(distribución)} propietarios")
        return distribución
    
    def obtener_parcelas_sin_coordenadas(self):
        """
        Obtiene parcelas que no tienen coordenadas GPS registradas.
        
        Returns:
            list: Lista de parcelas sin coordenadas.
        """
        query = """
        SELECT 
            p.id_parcela,
            p.nombre,
            p.ubicacion,
            a.nombre + ' ' + a.apellido as propietario
        FROM Parcelas p
        JOIN Agricultores a ON p.id_agricultor = a.id_agricultor
        WHERE p.activo = 1 
        AND a.activo = 1
        AND (p.coordenadas_gps IS NULL OR p.coordenadas_gps = '')
        ORDER BY p.nombre
        """
        
        rows = self._ejecutar_consulta(query)
        parcelas_sin_coords = []
        
        for row in rows:
            parcela = {
                'id_parcela': row.id_parcela,
                'nombre': row.nombre,
                'ubicacion': row.ubicacion,
                'propietario': row.propietario
            }
            parcelas_sin_coords.append(parcela)
        
        print(f"Se encontraron {len(parcelas_sin_coords)} parcelas sin coordenadas")
        return parcelas_sin_coords
    
    def buscar_agricultores_con_parcelas(self, texto_busqueda):
        """
        Busca agricultores que tengan parcelas, incluyendo información de sus propiedades.
        
        Args:
            texto_busqueda (str): Texto a buscar en nombre o apellido.
            
        Returns:
            list: Lista de agricultores con información de sus parcelas.
        """
        query = """
        SELECT 
            a.id_agricultor,
            a.nombre,
            a.apellido,
            a.identificacion,
            COUNT(p.id_parcela) as cantidad_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total
        FROM Agricultores a
        LEFT JOIN Parcelas p ON a.id_agricultor = p.id_agricultor AND p.activo = 1
        WHERE a.activo = 1 
        AND (a.nombre LIKE ? OR a.apellido LIKE ? OR CONCAT(a.nombre, ' ', a.apellido) LIKE ?)
        GROUP BY a.id_agricultor, a.nombre, a.apellido, a.identificacion
        HAVING COUNT(p.id_parcela) > 0
        ORDER BY a.nombre, a.apellido
        """
        
        patron = f"%{texto_busqueda}%"
        rows = self._ejecutar_consulta(query, (patron, patron, patron))
        
        agricultores = []
        for row in rows:
            agricultor = {
                'id_agricultor': row.id_agricultor,
                'nombre': row.nombre,
                'apellido': row.apellido,
                'identificacion': row.identificacion,
                'cantidad_parcelas': row.cantidad_parcelas,
                'area_total': float(row.area_total)
            }
            agricultores.append(agricultor)
        
        print(f"Búsqueda '{texto_busqueda}' con parcelas: {len(agricultores)} resultados")
        return agricultores
    
    def obtener_reporte_propietarios_parcelas(self):
        """
        Genera un reporte completo de propietarios y sus parcelas.
        
        Returns:
            list: Reporte detallado por propietario.
        """
        query = """
        SELECT 
            a.id_agricultor,
            a.nombre + ' ' + a.apellido as nombre_propietario,
            a.identificacion,
            a.telefono,
            a.correo,
            COUNT(p.id_parcela) as total_parcelas,
            COALESCE(SUM(p.area_total), 0) as area_total,
            COALESCE(AVG(p.area_total), 0) as area_promedio,
            MIN(p.fecha_adquisicion) as primera_adquisicion,
            MAX(p.fecha_adquisicion) as ultima_adquisicion
        FROM Agricultores a
        LEFT JOIN Parcelas p ON a.id_agricultor = p.id_agricultor AND p.activo = 1
        WHERE a.es_propietario = 1 AND a.activo = 1
        GROUP BY a.id_agricultor, a.nombre, a.apellido, a.identificacion, a.telefono, a.correo
        ORDER BY area_total DESC
        """
        
        rows = self._ejecutar_consulta(query)
        reporte = []
        
        for row in rows:
            item = {
                'id_agricultor': row.id_agricultor,
                'nombre_propietario': row.nombre_propietario,
                'identificacion': row.identificacion,
                'telefono': row.telefono,
                'correo': row.correo,
                'total_parcelas': row.total_parcelas,
                'area_total': float(row.area_total),
                'area_promedio': float(row.area_promedio) if row.area_promedio else 0,
                'primera_adquisicion': self._formatear_fecha(row.primera_adquisicion),
                'ultima_adquisicion': self._formatear_fecha(row.ultima_adquisicion)
            }
            reporte.append(item)
        
        print(f"Reporte generado para {len(reporte)} propietarios")
        return reporte
    
    def validar_transferencia_parcela(self, id_parcela, nuevo_propietario_id):
        """
        Valida si se puede transferir una parcela a un nuevo propietario.
        
        Args:
            id_parcela (int): ID de la parcela.
            nuevo_propietario_id (int): ID del nuevo propietario.
            
        Returns:
            dict: Información de validación.
            
        Raises:
            RegistroNoEncontrado: Si la parcela o propietario no existen.
        """
        # Verificar que la parcela existe y está activa
        parcela_query = "SELECT id_agricultor, nombre FROM Parcelas WHERE id_parcela = ? AND activo = 1"
        parcela_rows = self._ejecutar_consulta(parcela_query, (id_parcela,))
        
        if not parcela_rows:
            raise RegistroNoEncontrado(f"Parcela con ID {id_parcela} no encontrada")
        
        propietario_actual_id = parcela_rows[0].id_agricultor
        nombre_parcela = parcela_rows[0].nombre
        
        # Verificar que el nuevo propietario existe y es propietario activo
        propietario_query = """
        SELECT nombre, apellido 
        FROM Agricultores 
        WHERE id_agricultor = ? AND es_propietario = 1 AND activo = 1
        """
        propietario_rows = self._ejecutar_consulta(propietario_query, (nuevo_propietario_id,))
        
        if not propietario_rows:
            raise RegistroNoEncontrado(f"Propietario con ID {nuevo_propietario_id} no encontrado o no es propietario activo")
        
        nuevo_propietario_nombre = f"{propietario_rows[0].nombre} {propietario_rows[0].apellido}"
        
        # Obtener información del propietario actual
        propietario_actual_query = """
        SELECT nombre, apellido 
        FROM Agricultores 
        WHERE id_agricultor = ?
        """
        propietario_actual_rows = self._ejecutar_consulta(propietario_actual_query, (propietario_actual_id,))
        propietario_actual_nombre = f"{propietario_actual_rows[0].nombre} {propietario_actual_rows[0].apellido}"
        
        validacion = {
            'puede_transferir': propietario_actual_id != nuevo_propietario_id,
            'parcela_nombre': nombre_parcela,
            'propietario_actual': {
                'id': propietario_actual_id,
                'nombre': propietario_actual_nombre
            },
            'nuevo_propietario': {
                'id': nuevo_propietario_id,
                'nombre': nuevo_propietario_nombre
            }
        }
        
        if not validacion['puede_transferir']:
            print(f"Intento de transferir parcela {id_parcela} al mismo propietario")
        else:
            print(f"Transferencia validada: parcela {id_parcela} puede pasar de {propietario_actual_nombre} a {nuevo_propietario_nombre}")
        
        return validacion
    
    def ejecutar_transferencia_parcela(self, id_parcela, nuevo_propietario_id):
        """
        Ejecuta la transferencia de una parcela a un nuevo propietario.
        
        Args:
            id_parcela (int): ID de la parcela.
            nuevo_propietario_id (int): ID del nuevo propietario.
            
        Returns:
            bool: True si la transferencia fue exitosa.
        """
        # Validar la transferencia primero
        validacion = self.validar_transferencia_parcela(id_parcela, nuevo_propietario_id)
        
        if not validacion['puede_transferir']:
            print("Transferencia no válida")
            return False
        
        # Ejecutar la transferencia
        query = "UPDATE Parcelas SET id_agricultor = ? WHERE id_parcela = ?"
        filas_afectadas = self._ejecutar_consulta(query, (nuevo_propietario_id, id_parcela), obtener_resultado=False)
        
        if filas_afectadas > 0:
            print(f"Parcela {id_parcela} transferida exitosamente al propietario {nuevo_propietario_id}")
            return True
        else:
            print(f"Error en la transferencia de parcela {id_parcela}")
        
        return validacion
    # AGREGAR estos métodos AL FINAL de la clase RepositorioBase (antes del último paréntesis)

    def __init__(self, server=None, database=None, trusted_connection=True):
        """Inicializa la conexión a la base de datos y el sistema de caché."""
        try:
            if server and database:
                self.db = DatabaseConnection(server, database, trusted_connection)
            else:
                self.db = DatabaseConnection("DESKTOP-NVQ729A", "Producto_Citricos")
                
            # AGREGAR ESTAS LÍNEAS NUEVAS:
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
    
    # AGREGAR estos métodos nuevos al final de la clase:
    
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