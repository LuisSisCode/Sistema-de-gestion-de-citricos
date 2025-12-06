# bd_conecciones/repositorios/productor_repositorio.py

import logging
from datetime import datetime
from ...core.repositorio_base import RepositorioBase
from ...core.excepciones_bd import RegistroNoEncontrado, RegistroYaExiste, ErrorValidacion
from ...core.cache_system import CacheManager
from ...core.cache_system import cacheable, cache_invalidator, get_ttl
import re

logger = logging.getLogger(__name__)

class ProductorRepositorio(RepositorioBase):
    def __init__(self, server=None, database=None, trusted_connection=None):
        super().__init__(server, database, trusted_connection)
        self.re = re
        self.cache_sistem= CacheManager()
    """Repositorio para operaciones CRUD de productores con funcionalidades extendidas."""

    @cacheable('productores', key_func=lambda: 'todos_activos', ttl=1800)  # 30 min
    def obtener_todos(self):
        """
        Obtiene todos los productores activos.
        
        Returns:
            list: Lista de diccionarios con información de productores.
        """
        query = """
        SELECT id_productor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               activo
        FROM Productores
        ORDER BY nombre, apellido
        """
        
        rows = self._ejecutar_consulta(query)
        productores = []
        
        for row in rows:
            productor = self._construir_objeto_productor(row)
            productores.append(productor)
        
        logger.info(f"Se obtuvieron {len(productores)} productores")
        return productores

    @cacheable('productores', key_func=lambda id_prod: f"id_{id_prod}", ttl=3600)  # 1 hora
    def obtener_por_id(self, id_productor):
        """
        Obtiene un productor por su ID.
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            dict: Información del productor.
            
        Raises:
            RegistroNoEncontrado: Si el productor no existe.
        """
        query = """
        SELECT id_productor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               activo
        FROM Productores
        WHERE id_productor = ?
        """
        
        rows = self._ejecutar_consulta(query, (id_productor,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Productor con ID {id_productor} no encontrado")
        
        return self._construir_objeto_productor(rows[0])

    @cacheable('productores', key_func=lambda pagina, por_pagina=10: f"pagina_{pagina}_{por_pagina}", ttl=1200)  # 20 min
    def obtener_paginado(self, pagina, por_pagina=10):
        """
        Obtiene productores con paginación.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Productores, total_registros, total_paginas, pagina_actual.
        """
        pagina, por_pagina, offset = self._validar_parametros_paginacion(pagina, por_pagina)
        
        # Contar total de registros activos
        total_registros = self._contar_registros_cached()
        
        # Obtener registros paginados
        query = """
        SELECT id_productor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               activo
        FROM Productores
        ORDER BY id_productor DESC
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        
        rows = self._ejecutar_consulta(query, (offset, por_pagina))
        productores = []
        
        for row in rows:
            productor = self._construir_objeto_productor(row)
            productores.append(productor)
        
        total_paginas = self._calcular_total_paginas(total_registros, por_pagina)
        
        resultado = {
            'productores': productores,
            'total_registros': total_registros,
            'total_paginas': total_paginas,
            'pagina_actual': pagina
        }
        
        logger.info(f"Página {pagina}: {len(productores)} productores de {total_registros} totales")
        return resultado

    @cacheable('productores', key_func=lambda texto: f"buscar_{texto.lower().replace(' ', '_')}", ttl=900)  # 15 min
    def buscar_por_nombre(self, texto_busqueda):
        """
        Busca productores por nombre o apellido.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de productores que coinciden.
        """
        query = """
        SELECT id_productor, nombre, apellido, identificacion, 
               telefono, correo, direccion, fecha_registro, 
               activo
        FROM Productores
        WHERE (nombre LIKE ? OR apellido LIKE ? OR CONCAT(nombre, ' ', apellido) LIKE ?)
        ORDER BY id_productor DESC
        """
        
        patron = f"%{texto_busqueda}%"
        rows = self._ejecutar_consulta(query, (patron, patron, patron))
        
        productores = []
        for row in rows:
            productor = self._construir_objeto_productor(row)
            productores.append(productor)
        
        logger.info(f"Búsqueda '{texto_busqueda}': {len(productores)} resultados")
        return productores

    @cacheable('productores', key_func=lambda id_prod: f"parcelas_count_{id_prod}", ttl=1800)  # 30 min
    def contar_parcelas_por_productor(self, id_productor):
        """
        Cuenta las parcelas activas de un productor específico.
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            int: Número de parcelas activas del productor.
        """
        count = self._contar_registros(
            "Parcelas", 
            "id_productor = ? AND activo = 1", 
            (id_productor,)
        )
        
        logger.info(f"Productor {id_productor} tiene {count} parcelas activas")
        return count

    @cacheable('productores', key_func=lambda id_prod: f"dependencias_{id_prod}", ttl=1200)  # 20 min
    def verificar_dependencias_productor(self, id_productor):
        """
        Verifica todas las dependencias de un productor antes de eliminarlo.
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            dict: Información detallada de dependencias.
            
        Raises:
            RegistroTieneDependencias: Si tiene dependencias que impiden la eliminación.
        """
        from ...core.excepciones_bd import RegistroTieneDependencias
        
        # Contar parcelas (ahora cacheado)
        parcelas = self.contar_parcelas_por_productor(id_productor)
        
        dependencias = {
            'parcelas': parcelas,
            'total_dependencias': parcelas,
            'puede_eliminar': parcelas == 0
        }
        
        if not dependencias['puede_eliminar']:
            mensaje = f"No se puede eliminar el productor. Tiene {parcelas} parcelas asociadas."
            raise RegistroTieneDependencias(mensaje, parcelas)
        
        logger.info(f"Productor {id_productor} puede ser eliminado - sin dependencias")
        return dependencias

    @cacheable('estadisticas', key_func=lambda: 'distribucion_parcelas', ttl=2400)  # 40 min
    def obtener_distribucion_parcelas_por_productor(self):
        """
        Obtiene la distribución de parcelas por productor.
        
        Returns:
            list: Lista con productores y cantidad de parcelas.
        """
        query = """
        SELECT 
            p.id_productor,
            p.nombre + ' ' + p.apellido as nombre_productor,
            COUNT(par.id_parcela) as cantidad_parcelas,
            COALESCE(SUM(par.area_total), 0) as area_total
        FROM Productores p
        LEFT JOIN Parcelas par ON p.id_productor = par.id_productor AND par.activo = 1
        GROUP BY p.id_productor, p.nombre, p.apellido
        ORDER BY cantidad_parcelas DESC, area_total DESC
        """
        
        rows = self._ejecutar_consulta(query)
        distribucion = []
        
        for row in rows:
            item = {
                'id_productor': row.id_productor,
                'nombre_productor': row.nombre_productor,
                'cantidad_parcelas': row.cantidad_parcelas,
                'area_total': float(row.area_total)
            }
            distribucion.append(item)
        
        logger.info(f"Distribución calculada para {len(distribucion)} productores")
        return distribucion

    @cacheable('productores', key_func=lambda texto: f"con_parcelas_{texto.lower().replace(' ', '_')}", ttl=900)  # 15 min
    def buscar_productores_con_parcelas(self, texto_busqueda):
        """
        Busca productores que tengan parcelas, incluyendo información de sus propiedades.
        
        Args:
            texto_busqueda (str): Texto a buscar en nombre o apellido.
            
        Returns:
            list: Lista de productores con información de sus parcelas.
        """
        query = """
        SELECT 
            p.id_productor,
            p.nombre,
            p.apellido,
            p.identificacion,
            COUNT(par.id_parcela) as cantidad_parcelas,
            COALESCE(SUM(par.area_total), 0) as area_total,
            p.activo  -- Incluimos el estado del productor
        FROM Productores p
        LEFT JOIN Parcelas par ON p.id_productor = par.id_productor AND par.activo = 1
        WHERE (p.nombre LIKE ? OR p.apellido LIKE ? OR CONCAT(p.nombre, ' ', p.apellido) LIKE ?)
        GROUP BY p.id_productor, p.nombre, p.apellido, p.identificacion, p.activo
        HAVING COUNT(par.id_parcela) > 0
        ORDER BY p.activo DESC, p.nombre, p.apellido
        """
        
        patron = f"%{texto_busqueda}%"
        rows = self._ejecutar_consulta(query, (patron, patron, patron))
        
        productores = []
        for row in rows:
            productor = {
                'id_productor': row.id_productor,
                'nombre': row.nombre,
                'apellido': row.apellido,
                'identificacion': row.identificacion,
                'cantidad_parcelas': row.cantidad_parcelas,
                'area_total': float(row.area_total)
            }
            productores.append(productor)
        
        logger.info(f"Búsqueda '{texto_busqueda}' con parcelas: {len(productores)} resultados")
        return productores

    @cacheable('reportes', key_func=lambda: 'productores_parcelas_completo', ttl=3600)  # 1 hora
    def obtener_reporte_productores_parcelas(self):
        """
        Genera un reporte completo de productores y sus parcelas.
        
        Returns:
            list: Reporte detallado por productor.
        """
        query = """
        SELECT 
            p.id_productor,
            p.nombre + ' ' + p.apellido as nombre_productor,
            p.identificacion,
            p.telefono,
            p.correo,
            COUNT(par.id_parcela) as total_parcelas,
            COALESCE(SUM(par.area_total), 0) as area_total,
            COALESCE(AVG(par.area_total), 0) as area_promedio,
            MIN(par.fecha_adquisicion) as primera_adquisicion,
            MAX(par.fecha_adquisicion) as ultima_adquisicion
        FROM Productores p
        LEFT JOIN Parcelas par ON p.id_productor = par.id_productor AND par.activo = 1
        GROUP BY p.id_productor, p.nombre, p.apellido, p.identificacion, p.telefono, p.correo
        ORDER BY area_total DESC
        """
        
        rows = self._ejecutar_consulta(query)
        reporte = []
        
        for row in rows:
            item = {
                'id_productor': row.id_productor,
                'nombre_productor': row.nombre_productor,
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
        
        logger.info(f"Reporte generado para {len(reporte)} productores")
        return reporte

    @cacheable('ranking', key_func=lambda limite=10: f"top_productores_{limite}", ttl=2400)  # 40 min
    def obtener_top_productores_por_area(self, limite=10):
        """
        Obtiene los top productores por área total.
        
        Args:
            limite (int): Número máximo de productores a retornar.
            
        Returns:
            list: Lista de top productores.
        """
        query = """
        SELECT TOP (?)
            p.id_productor,
            p.nombre + ' ' + p.apellido as nombre_productor,
            COUNT(par.id_parcela) as total_parcelas,
            COALESCE(SUM(par.area_total), 0) as area_total
        FROM Productores p
        JOIN Parcelas par ON p.id_productor = par.id_productor AND par.activo = 1
        GROUP BY p.id_productor, p.nombre, p.apellido
        ORDER BY area_total DESC
        """
        
        rows = self._ejecutar_consulta(query, (limite,))
        top_productores = []
        
        for i, row in enumerate(rows, 1):
            productor = {
                'ranking': i,
                'id_productor': row.id_productor,
                'nombre_productor': row.nombre_productor,
                'total_parcelas': row.total_parcelas,
                'area_total': float(row.area_total)
            }
            top_productores.append(productor)
        
        logger.info(f"Top {len(top_productores)} productores por área calculado")
        return top_productores

    # ==================== MÉTODOS DE ESCRITURA CON INVALIDACIÓN OPTIMIZADA ====================

    @cache_invalidator('productores', key='todos_activos')  # Invalidar lista completa
    @cache_invalidator('productores', pattern='pagina_')    # Invalidar paginación
    @cache_invalidator('estadisticas')                      # Invalidar estadísticas
    @cache_invalidator('reportes')                          # Invalidar reportes
    @cache_invalidator('ranking')                           # Invalidar rankings
    def crear(self, datos_productor):
        """
        Crea un nuevo productor.
        
        Args:
            datos_productor (dict): Datos del productor.
            
        Returns:
            tuple: (True, id_productor) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
            RegistroYaExiste: Si la identificación ya existe.
        """
        try:
            print(f"🎯 REPOSITORIO CREAR - Datos recibidos: {datos_productor}")
            self._validar_datos_productor(datos_productor)
            
            # Verificar si la identificación ya existe
            if self._existe_identificacion(datos_productor['identificacion']):
                raise RegistroYaExiste(f"Ya existe un productor con identificación {datos_productor['identificacion']}")
            
            query = """
            INSERT INTO Productores (nombre, apellido, identificacion, telefono, 
                                correo, direccion, fecha_registro, activo)
            OUTPUT INSERTED.id_productor
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """
            
            fecha_actual = datetime.now().date().strftime('%Y-%m-%d')
            valores = (
                datos_productor['nombre'],
                datos_productor['apellido'],
                datos_productor['identificacion'],
                datos_productor.get('telefono'),
                datos_productor.get('correo'),
                datos_productor.get('direccion'),
                fecha_actual,
                1  # activo por defecto
            )
            
            resultado = self._ejecutar_consulta(query, valores, obtener_resultado=True)
            id_productor = resultado[0][0] if resultado and len(resultado) > 0 else None
            
            logger.info(f"Productor creado con ID: {id_productor}")
            print(f"✅ REPOSITORIO CREAR - Productor creado con ID: {id_productor}")
            return True, id_productor
        except Exception as e:
            logger.error(f"Error al crear productor: {e}")
            print(f"❌ REPOSITORIO CREAR - Error al crear productor: {  e}")
        

    @cache_invalidator('productores', pattern='id_')        # Invalidar caché específico
    @cache_invalidator('productores', key='todos_activos')  # Invalidar lista completa
    @cache_invalidator('productores', pattern='pagina_')    # Invalidar paginación
    @cache_invalidator('estadisticas')                      # Invalidar estadísticas
    @cache_invalidator('reportes')                          # Invalidar reportes
    @cache_invalidator('ranking')                           # Invalidar rankings
    def actualizar(self, id_productor, datos_productor):
        """
        Actualiza un productor existente.
        
        Args:
            id_productor (int): ID del productor.
            datos_productor (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el productor no existe.
            ErrorValidacion: Si los datos no son válidos.
        """
        # Verificar que el productor existe
        productor_actual = self.obtener_por_id(id_productor)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        if 'nombre' in datos_productor:
            campos_actualizar.append("nombre = ?")
            valores.append(datos_productor['nombre'])
            
        if 'apellido' in datos_productor:
            campos_actualizar.append("apellido = ?")
            valores.append(datos_productor['apellido'])
            
        if 'identificacion' in datos_productor:
            # Verificar que la nueva identificación no exista (excluyendo el registro actual)
            if self._existe_identificacion_excepto(datos_productor['identificacion'], id_productor):
                raise RegistroYaExiste(f"Ya existe otro productor con identificación {datos_productor['identificacion']}")
            campos_actualizar.append("identificacion = ?")
            valores.append(datos_productor['identificacion'])
            
        if 'telefono' in datos_productor:
            campos_actualizar.append("telefono = ?")
            valores.append(datos_productor['telefono'])
            
        if 'correo' in datos_productor:
            campos_actualizar.append("correo = ?")
            valores.append(datos_productor['correo'])
            
        if 'direccion' in datos_productor:
            campos_actualizar.append("direccion = ?")
            valores.append(datos_productor['direccion'])

        if 'activo' in datos_productor:
            campos_actualizar.append("activo = ?")
            valores.append(1 if datos_productor['activo'] else 0)
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        query = f"UPDATE Productores SET {', '.join(campos_actualizar)} WHERE id_productor = ?"
        valores.append(id_productor)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)

        return filas_afectadas > 0

    @cache_invalidator('productores', pattern='id_')        # Invalidar caché específico
    @cache_invalidator('productores', key='todos_activos')  # Invalidar lista completa
    @cache_invalidator('productores', pattern='pagina_')    # Invalidar paginación
    @cache_invalidator('estadisticas')                      # Invalidar estadísticas
    @cache_invalidator('reportes')                          # Invalidar reportes
    @cache_invalidator('ranking')                           # Invalidar rankings
    def desactivar(self, id_productor):
        """
        Desactiva un productor (eliminación lógica).
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            bool: True si se desactivó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el productor no existe.
        """
        # Verificar que el productor existe
        self.obtener_por_id(id_productor)
        
        query = "UPDATE Productores SET activo = 0 WHERE id_productor = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_productor,), obtener_resultado=False)
        
        logger.info(f"Productor {id_productor} desactivado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0
    
    # metodo eliminar

    @cache_invalidator('productores', pattern='id_')        # Invalidar caché específico
    @cache_invalidator('productores', key='todos_activos')  # Invalidar lista completa
    @cache_invalidator('productores', pattern='pagina_')    # Invalidar paginación
    @cache_invalidator('estadisticas')                      # Invalidar estadísticas
    @cache_invalidator('reportes')                          # Invalidar reportes
    @cache_invalidator('ranking')                           # Invalidar rankings
    def eliminar_fisico(self, id_productor):
        """
        Elimina físicamente un productor de la base de datos (ADMIN ONLY).
        
        Args:
            id_productor (int): ID del productor.
            
        Returns:
            bool: True si se eliminó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el productor no existe.
            ErrorValidacion: Si el productor tiene dependencias activas.
        """
        try:
            # 1. Verificar que el productor existe
            productor = self.obtener_por_id(id_productor)
            
            # 2. Verificar que NO tenga parcelas activas
            parcelas_activas = self.contar_parcelas_por_productor(id_productor)
            
            if parcelas_activas > 0:
                raise ErrorValidacion(
                    f"No se puede eliminar físicamente al productor {productor['nombre']} {productor['apellido']}. "
                    f"Tiene {parcelas_activas} parcelas asociadas. "
                    f"Debe transferir o eliminar las parcelas primero."
                )
            
            # 3. Ejecutar eliminación física
            query = "DELETE FROM Productores WHERE id_productor = ?"
            filas_afectadas = self._ejecutar_consulta(query, (id_productor,), obtener_resultado=False)
            
            if filas_afectadas > 0:
                logger.warning(f"⚠️ ELIMINACIÓN FÍSICA: Productor {id_productor} ({productor['nombre']} {productor['apellido']}) eliminado permanentemente")
                
                # 4. Invalidar cachés específicas del productor eliminado
                self._invalidar_cache_productor(id_productor)
                
                return True
            else:
                logger.error(f"Error: No se pudo eliminar físicamente el productor {id_productor}")
                return False
                
        except RegistroNoEncontrado as e:
            logger.error(f"Productor no encontrado para eliminación física: {str(e)}")
            raise
        except ErrorValidacion as e:
            logger.error(f"Validación fallida para eliminación física: {str(e)}")
            raise
        except Exception as e:
            logger.error(f"Error inesperado en eliminación física: {str(e)}")
            raise ErrorValidacion(f"Error interno al eliminar productor: {str(e)}")

    def _invalidar_cache_productor(self, id_productor):
        """Invalidar todas las cachés relacionadas con un productor específico."""
        # Estas claves deben coincidir con las usadas en cacheable
        claves_invalidar = [
            f"id_{id_productor}",
            f"parcelas_count_{id_productor}",
            f"dependencias_{id_productor}",
            f"puede_eliminar_{id_productor}"
        ]
        
        
        logger.debug(f"Cachés invalidadas para productor {id_productor}")

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _construir_objeto_productor(self, row):
        """
        Construye un objeto productor a partir de una fila de la base de datos.
        Ahora incluye información de estado.
        
        Args:
            row: Fila de la consulta.
            
        Returns:
            dict: Objeto productor estructurado con información de estado.
        """
        productor = {
            'id_productor': row.id_productor,
            'id': row.id_productor,
            'nombre': row.nombre,
            'apellido': row.apellido,
            'identificacion': row.identificacion,
            'telefono': row.telefono,
            'correo': row.correo,
            'direccion': row.direccion,
            'fecha_registro': self._formatear_fecha(row.fecha_registro),
            'activo': bool(row.activo),
            'nombre_completo': f"{row.nombre} {row.apellido}",
            'estado': 'Activo' if row.activo else 'Inactivo',
            'estado_color': 'green' if row.activo else 'gray'
        }
        
        return productor
    
    def _validar_datos_productor(self, datos):
        """
        Valida los datos del productor.
        
        Args:
            datos (dict): Datos a validar.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        if not datos.get('nombre') or not datos.get('nombre').strip():
            raise ErrorValidacion("El nombre es obligatorio")
            
        if not datos.get('apellido') or not datos.get('apellido').strip():
            raise ErrorValidacion("El apellido es obligatorio")
            
        if not datos.get('identificacion') or not datos.get('identificacion').strip():
            raise ErrorValidacion("La identificación es obligatoria")
        
        # Validar formato de correo si se proporciona
        if datos.get('correo'):
            email_regex = r'\w+([-+.\']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*'
            if not self.re.match(email_regex, datos['correo']):
                raise ErrorValidacion("El formato del correo electrónico no es válido")
    
    def _contar_registros_cached(self):
        """
        Cuenta total de productores activos (versión cacheada).
        Mantenemos este método para compatibilidad con código existente.
        
        Returns:
            int: Número total de productores activos.
        """
        return self._contar_registros("Productores", "activo = 1")
    
    def _existe_identificacion(self, identificacion):
        """
        Verifica si una identificación ya existe.
        
        Args:
            identificacion (str): Identificación a verificar.
            
        Returns:
            bool: True si existe.
        """
        count = self._contar_registros("Productores", "identificacion = ? AND activo = 1", (identificacion,))
        return count > 0
    
    def _existe_identificacion_excepto(self, identificacion, id_excluir):
        """
        Verifica si una identificación ya existe excluyendo un ID específico.
        
        Args:
            identificacion (str): Identificación a verificar.
            id_excluir (int): ID a excluir de la búsqueda.
            
        Returns:
            bool: True si existe.
        """
        count = self._contar_registros(
            "Productores", 
            "identificacion = ? AND activo = 1 AND id_productor != ?", 
            (identificacion, id_excluir)
        )
        return count > 0
    @cacheable('conteos', key_func=lambda: 'total_productores_todos', ttl=1800)  # 30 min
    def _contar_registros_cached_todos(self):
        """
        Cuenta total de productores (activos e inactivos) - versión cacheada.
        
        Returns:
            int: Número total de productores.
        """
        return self._contar_registros("Productores", "1=1")  # Sin filtro de activo