# bd_conecciones/repositorios/tipo_cultivo_repositorio.py

import logging
from datetime import datetime
from ...nucleo.repositorio_base import RepositorioBase
from ...nucleo.excepciones_bd import RegistroNoEncontrado, RegistroYaExiste, ErrorValidacion
from ...nucleo.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class TipoCultivoRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de tipos de cultivo con caché optimizado."""

    @cacheable('tipos_cultivo', key_func=lambda: 'todos_activos', ttl=1800)  # 30 min
    def obtener_todos(self):
        """
        Obtiene todos los tipos de cultivo activos.
        
        Returns:
            list: Lista de diccionarios con información de tipos de cultivo.
        """
        query = """
        SELECT id_tipo_cultivo, nombre, nombre_cientifico, descripcion, 
               tiempo_cosecha_min, tiempo_cosecha_max, activo
        FROM TiposCultivo
        WHERE activo = 1
        ORDER BY nombre
        """
        
        rows = self._ejecutar_consulta(query)
        tipos_cultivo = []
        
        for row in rows:
            tipo = self._construir_objeto_tipo_cultivo(row)
            tipos_cultivo.append(tipo)
        
        logger.info(f"Se obtuvieron {len(tipos_cultivo)} tipos de cultivo")
        return tipos_cultivo

    @cacheable('tipos_cultivo', key_func=lambda id_tipo: f"id_{id_tipo}", ttl=3600)  # 1 hora
    def obtener_por_id(self, id_tipo_cultivo):
        """
        Obtiene un tipo de cultivo por su ID.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            dict: Información del tipo de cultivo.
            
        Raises:
            RegistroNoEncontrado: Si el tipo de cultivo no existe.
        """
        query = """
        SELECT id_tipo_cultivo, nombre, nombre_cientifico, descripcion, 
               tiempo_cosecha_min, tiempo_cosecha_max, activo
        FROM TiposCultivo
        WHERE id_tipo_cultivo = ? AND activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (id_tipo_cultivo,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Tipo de cultivo con ID {id_tipo_cultivo} no encontrado")
        
        return self._construir_objeto_tipo_cultivo(rows[0])

    @cacheable('tipos_cultivo', key_func=lambda pagina, por_pagina=10: f"pagina_{pagina}_{por_pagina}", ttl=1200)  # 20 min
    def obtener_paginado(self, pagina, por_pagina=10):
        """
        Obtiene tipos de cultivo con paginación.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Tipos de cultivo, total_registros, total_paginas, pagina_actual.
        """
        pagina, por_pagina, offset = self._validar_parametros_paginacion(pagina, por_pagina)
        
        # Contar total de registros activos
        total_registros = self._contar_registros_cached()
        
        # Obtener registros paginados
        query = """
        SELECT id_tipo_cultivo, nombre, nombre_cientifico, descripcion, 
               tiempo_cosecha_min, tiempo_cosecha_max, activo
        FROM TiposCultivo
        WHERE activo = 1
        ORDER BY nombre
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        
        rows = self._ejecutar_consulta(query, (offset, por_pagina))
        tipos_cultivo = []
        
        for row in rows:
            tipo = self._construir_objeto_tipo_cultivo(row)
            tipos_cultivo.append(tipo)
        
        total_paginas = self._calcular_total_paginas(total_registros, por_pagina)
        
        resultado = {
            'tipos_cultivo': tipos_cultivo,
            'total_registros': total_registros,
            'total_paginas': total_paginas,
            'pagina_actual': pagina
        }
        
        logger.info(f"Página {pagina}: {len(tipos_cultivo)} tipos de cultivo de {total_registros} totales")
        return resultado

    @cacheable('tipos_cultivo', key_func=lambda texto: f"buscar_{texto.lower().replace(' ', '_')}", ttl=900)  # 15 min
    def buscar_por_nombre(self, texto_busqueda):
        """
        Busca tipos de cultivo por nombre o nombre científico.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de tipos de cultivo que coinciden.
        """
        query = """
        SELECT id_tipo_cultivo, nombre, nombre_cientifico, descripcion, 
               tiempo_cosecha_min, tiempo_cosecha_max, activo
        FROM TiposCultivo
        WHERE activo = 1 
        AND (nombre LIKE ? OR nombre_cientifico LIKE ? OR descripcion LIKE ?)
        ORDER BY nombre
        """
        
        patron = f"%{texto_busqueda}%"
        rows = self._ejecutar_consulta(query, (patron, patron, patron))
        
        tipos_cultivo = []
        for row in rows:
            tipo = self._construir_objeto_tipo_cultivo(row)
            tipos_cultivo.append(tipo)
        
        logger.info(f"Búsqueda '{texto_busqueda}': {len(tipos_cultivo)} resultados")
        return tipos_cultivo

    @cacheable('estadisticas_tipos', key_func=lambda: 'conteo_total', ttl=1800)  # 30 min
    def _contar_registros_cached(self):
        """
        Cuenta total de tipos de cultivo activos (versión cacheada).
        
        Returns:
            int: Número total de tipos de cultivo activos.
        """
        return self._contar_registros("TiposCultivo", "activo = 1")

    @cacheable('estadisticas_tipos', key_func=lambda: 'estadisticas_basicas', ttl=1800)  # 30 min
    def obtener_estadisticas(self):
        """
        Obtiene estadísticas básicas de tipos de cultivo.
        
        Returns:
            dict: Estadísticas de tipos de cultivo.
        """
        query = """
        SELECT 
            COUNT(*) as total_tipos,
            COUNT(CASE WHEN tiempo_cosecha_min IS NOT NULL AND tiempo_cosecha_max IS NOT NULL THEN 1 END) as con_tiempo_cosecha,
            AVG(CASE WHEN tiempo_cosecha_min IS NOT NULL AND tiempo_cosecha_max IS NOT NULL 
                THEN (tiempo_cosecha_min + tiempo_cosecha_max) / 2.0 END) as tiempo_promedio
        FROM TiposCultivo
        WHERE activo = 1
        """
        
        rows = self._ejecutar_consulta(query)
        if rows:
            row = rows[0]
            stats = {
                'total_tipos': row.total_tipos,
                'con_tiempo_cosecha': row.con_tiempo_cosecha,
                'tiempo_promedio_cosecha': float(row.tiempo_promedio) if row.tiempo_promedio else 0
            }
        else:
            stats = {'total_tipos': 0, 'con_tiempo_cosecha': 0, 'tiempo_promedio_cosecha': 0}
        
        logger.info(f"Estadísticas tipos de cultivo: {stats}")
        return stats

    @cacheable('tipos_cultivo', key_func=lambda: 'por_tiempo_cosecha', ttl=1800)  # 30 min
    def obtener_por_tiempo_cosecha(self, tiempo_min=None, tiempo_max=None):
        """
        Obtiene tipos de cultivo filtrados por tiempo de cosecha.
        
        Args:
            tiempo_min (int, optional): Tiempo mínimo de cosecha.
            tiempo_max (int, optional): Tiempo máximo de cosecha.
            
        Returns:
            list: Lista de tipos de cultivo que coinciden con el criterio.
        """
        where_clauses = ["activo = 1"]
        params = []
        
        if tiempo_min is not None:
            where_clauses.append("tiempo_cosecha_min >= ?")
            params.append(tiempo_min)
            
        if tiempo_max is not None:
            where_clauses.append("tiempo_cosecha_max <= ?")
            params.append(tiempo_max)
        
        query = f"""
        SELECT id_tipo_cultivo, nombre, nombre_cientifico, descripcion, 
               tiempo_cosecha_min, tiempo_cosecha_max, activo
        FROM TiposCultivo
        WHERE {' AND '.join(where_clauses)}
        ORDER BY tiempo_cosecha_min, nombre
        """
        
        rows = self._ejecutar_consulta(query, params)
        tipos_cultivo = []
        
        for row in rows:
            tipo = self._construir_objeto_tipo_cultivo(row)
            tipos_cultivo.append(tipo)
        
        logger.info(f"Filtro por tiempo cosecha: {len(tipos_cultivo)} resultados")
        return tipos_cultivo

    # ==================== MÉTODOS DE ESCRITURA CON INVALIDACIÓN OPTIMIZADA ====================

    @cache_invalidator('tipos_cultivo', key='todos_activos')     # Lista completa
    @cache_invalidator('tipos_cultivo', pattern='pagina_')       # Paginación
    @cache_invalidator('tipos_cultivo', pattern='buscar_')       # Búsquedas
    @cache_invalidator('estadisticas_tipos')                     # Estadísticas
    def crear(self, datos_tipo_cultivo):
        """
        Crea un nuevo tipo de cultivo.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            datos_tipo_cultivo (dict): Datos del tipo de cultivo.
            
        Returns:
            tuple: (True, id_tipo_cultivo) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
            RegistroYaExiste: Si el nombre ya existe.
        """
        self._validar_datos_tipo_cultivo(datos_tipo_cultivo)
        
        # Verificar si el nombre ya existe
        if self._existe_nombre(datos_tipo_cultivo['nombre']):
            raise RegistroYaExiste(f"Ya existe un tipo de cultivo con el nombre '{datos_tipo_cultivo['nombre']}'")
        
        query = """
        INSERT INTO TiposCultivo (nombre, nombre_cientifico, descripcion, 
                               tiempo_cosecha_min, tiempo_cosecha_max, activo)
        VALUES (?, ?, ?, ?, ?, ?)
        """
        
        valores = (
            datos_tipo_cultivo['nombre'],
            datos_tipo_cultivo.get('nombre_cientifico'),
            datos_tipo_cultivo.get('descripcion'),
            datos_tipo_cultivo.get('tiempo_cosecha_min'),
            datos_tipo_cultivo.get('tiempo_cosecha_max'),
            1  # activo por defecto
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_tipo_cultivo = self._obtener_ultimo_id()
        
        logger.info(f"Tipo de cultivo creado con ID: {id_tipo_cultivo}")
        return True, id_tipo_cultivo

    @cache_invalidator('tipos_cultivo', pattern='id_')           # Específico
    @cache_invalidator('tipos_cultivo', key='todos_activos')     # Lista completa
    @cache_invalidator('tipos_cultivo', pattern='pagina_')       # Paginación
    @cache_invalidator('tipos_cultivo', pattern='buscar_')       # Búsquedas
    @cache_invalidator('estadisticas_tipos')                     # Estadísticas
    def actualizar(self, id_tipo_cultivo, datos_tipo_cultivo):
        """
        Actualiza un tipo de cultivo existente.
        OPTIMIZADO: Invalidación específica y general.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            datos_tipo_cultivo (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el tipo de cultivo no existe.
            ErrorValidacion: Si los datos no son válidos.
        """
        # Verificar que el tipo de cultivo existe
        tipo_actual = self.obtener_por_id(id_tipo_cultivo)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        if 'nombre' in datos_tipo_cultivo:
            # Verificar que el nuevo nombre no exista (excluyendo el registro actual)
            if self._existe_nombre_excepto(datos_tipo_cultivo['nombre'], id_tipo_cultivo):
                raise RegistroYaExiste(f"Ya existe otro tipo de cultivo con el nombre '{datos_tipo_cultivo['nombre']}'")
            campos_actualizar.append("nombre = ?")
            valores.append(datos_tipo_cultivo['nombre'])
            
        if 'nombre_cientifico' in datos_tipo_cultivo:
            campos_actualizar.append("nombre_cientifico = ?")
            valores.append(datos_tipo_cultivo['nombre_cientifico'])
            
        if 'descripcion' in datos_tipo_cultivo:
            campos_actualizar.append("descripcion = ?")
            valores.append(datos_tipo_cultivo['descripcion'])
            
        if 'tiempo_cosecha_min' in datos_tipo_cultivo:
            campos_actualizar.append("tiempo_cosecha_min = ?")
            valores.append(datos_tipo_cultivo['tiempo_cosecha_min'])
            
        if 'tiempo_cosecha_max' in datos_tipo_cultivo:
            campos_actualizar.append("tiempo_cosecha_max = ?")
            valores.append(datos_tipo_cultivo['tiempo_cosecha_max'])
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        # Validar datos antes de actualizar
        datos_para_validar = tipo_actual.copy()
        datos_para_validar.update(datos_tipo_cultivo)
        self._validar_datos_tipo_cultivo(datos_para_validar)
        
        query = f"UPDATE TiposCultivo SET {', '.join(campos_actualizar)} WHERE id_tipo_cultivo = ?"
        valores.append(id_tipo_cultivo)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Tipo de cultivo {id_tipo_cultivo} actualizado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('tipos_cultivo', pattern='id_')           # Específico
    @cache_invalidator('tipos_cultivo', key='todos_activos')     # Lista completa
    @cache_invalidator('tipos_cultivo', pattern='pagina_')       # Paginación
    @cache_invalidator('tipos_cultivo', pattern='buscar_')       # Búsquedas
    @cache_invalidator('estadisticas_tipos')                     # Estadísticas
    def desactivar(self, id_tipo_cultivo):
        """
        Desactiva un tipo de cultivo (eliminación lógica).
        OPTIMIZADO: Invalidación completa ya que afecta todas las listas.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            bool: True si se desactivó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el tipo de cultivo no existe.
        """
        # Verificar que el tipo de cultivo existe
        self.obtener_por_id(id_tipo_cultivo)
        
        query = "UPDATE TiposCultivo SET activo = 0 WHERE id_tipo_cultivo = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_tipo_cultivo,), obtener_resultado=False)
        
        logger.info(f"Tipo de cultivo {id_tipo_cultivo} desactivado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _construir_objeto_tipo_cultivo(self, row):
        """
        Construye un objeto tipo de cultivo a partir de una fila de la base de datos.
        
        Args:
            row: Fila de la consulta.
            
        Returns:
            dict: Objeto tipo de cultivo estructurado.
        """
        return {
            'id_tipo_cultivo': row.id_tipo_cultivo,
            'id': row.id_tipo_cultivo,  # Alias para compatibilidad
            'nombre': row.nombre or '',
            'nombre_cientifico': row.nombre_cientifico or '',
            'descripcion': row.descripcion or '',
            'tiempo_cosecha_min': row.tiempo_cosecha_min,
            'tiempo_cosecha_max': row.tiempo_cosecha_max,
            'tiempo_cosecha_rango': self._formatear_tiempo_cosecha(
                row.tiempo_cosecha_min, 
                row.tiempo_cosecha_max
            ),
            'activo': bool(row.activo),
            
            # Campos calculados
            'tiene_tiempo_cosecha': bool(row.tiempo_cosecha_min and row.tiempo_cosecha_max),
            'tiempo_promedio': self._calcular_tiempo_promedio(
                row.tiempo_cosecha_min, 
                row.tiempo_cosecha_max
            )
        }
    
    def _validar_datos_tipo_cultivo(self, datos):
        """
        Valida los datos del tipo de cultivo.
        
        Args:
            datos (dict): Datos a validar.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        if not datos.get('nombre') or not datos.get('nombre').strip():
            raise ErrorValidacion("El nombre del tipo de cultivo es obligatorio")
        
        # Validar tiempos de cosecha
        tiempo_min = datos.get('tiempo_cosecha_min')
        tiempo_max = datos.get('tiempo_cosecha_max')
        
        if tiempo_min is not None and tiempo_min < 0:
            raise ErrorValidacion("El tiempo mínimo de cosecha debe ser positivo")
            
        if tiempo_max is not None and tiempo_max < 0:
            raise ErrorValidacion("El tiempo máximo de cosecha debe ser positivo")
            
        if (tiempo_min is not None and tiempo_max is not None and 
            tiempo_min > tiempo_max):
            raise ErrorValidacion("El tiempo mínimo no puede ser mayor al tiempo máximo de cosecha")
        
        # Validar longitud de campos
        if len(datos.get('nombre', '')) > 100:
            raise ErrorValidacion("El nombre no puede exceder 100 caracteres")
            
        if datos.get('nombre_cientifico') and len(datos['nombre_cientifico']) > 150:
            raise ErrorValidacion("El nombre científico no puede exceder 150 caracteres")
    
    def _existe_nombre(self, nombre):
        """
        Verifica si un nombre ya existe.
        
        Args:
            nombre (str): Nombre a verificar.
            
        Returns:
            bool: True si existe.
        """
        count = self._contar_registros("TiposCultivo", "nombre = ? AND activo = 1", (nombre,))
        return count > 0
    
    def _existe_nombre_excepto(self, nombre, id_excluir):
        """
        Verifica si un nombre ya existe excluyendo un ID específico.
        
        Args:
            nombre (str): Nombre a verificar.
            id_excluir (int): ID a excluir de la búsqueda.
            
        Returns:
            bool: True si existe.
        """
        count = self._contar_registros(
            "TiposCultivo", 
            "nombre = ? AND activo = 1 AND id_tipo_cultivo != ?", 
            (nombre, id_excluir)
        )
        return count > 0
    
    def _formatear_tiempo_cosecha(self, tiempo_min, tiempo_max):
        """
        Formatea el rango de tiempo de cosecha.
        
        Args:
            tiempo_min (int): Tiempo mínimo en días.
            tiempo_max (int): Tiempo máximo en días.
            
        Returns:
            str: Rango formateado.
        """
        if not tiempo_min and not tiempo_max:
            return "No especificado"
        elif tiempo_min and tiempo_max:
            if tiempo_min == tiempo_max:
                return f"{tiempo_min} días"
            else:
                return f"{tiempo_min}-{tiempo_max} días"
        elif tiempo_min:
            return f"Mín. {tiempo_min} días"
        else:
            return f"Máx. {tiempo_max} días"
    
    def _calcular_tiempo_promedio(self, tiempo_min, tiempo_max):
        """
        Calcula el tiempo promedio de cosecha.
        
        Args:
            tiempo_min (int): Tiempo mínimo en días.
            tiempo_max (int): Tiempo máximo en días.
            
        Returns:
            float: Tiempo promedio o None si no hay datos.
        """
        if tiempo_min and tiempo_max:
            return round((tiempo_min + tiempo_max) / 2.0, 1)
        elif tiempo_min:
            return float(tiempo_min)
        elif tiempo_max:
            return float(tiempo_max)
        else:
            return None