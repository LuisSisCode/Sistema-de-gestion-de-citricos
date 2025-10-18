# bd_conecciones/repositorios/variedad_cultivo_repositorio.py

import logging
from datetime import datetime
from ...nucleo.repositorio_base import RepositorioBase
from ...nucleo.excepciones_bd import RegistroNoEncontrado, RegistroYaExiste, ErrorValidacion
from ...nucleo.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class VariedadCultivoRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de variedades de cultivo con caché optimizado."""

    @cacheable('variedades_cultivo', key_func=lambda *args: 'todas_activas', ttl=1800)  # 30 min
    def obtener_todas(self):
        """
        Obtiene todas las variedades de cultivo activas con información de tipos.
        
        Returns:
            list: Lista de diccionarios con información de variedades de cultivo.
        """
        query = """
        SELECT v.id_variedad, v.id_tipo_cultivo, v.nombre, v.tiempo_produccion, 
               v.rendimiento_esperado, v.resistencia_zona, v.activo,
               t.nombre AS nombre_tipo_cultivo, t.nombre_cientifico AS nombre_cientifico_tipo
        FROM VariedadesCultivo v
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE v.activo = 1 AND t.activo = 1
        ORDER BY t.nombre, v.nombre
        """
        
        rows = self._ejecutar_consulta(query)
        variedades = []
        
        for row in rows:
            variedad = self._construir_objeto_variedad_cultivo(row)
            variedades.append(variedad)
        
        logger.info(f"Se obtuvieron {len(variedades)} variedades de cultivo")
        return variedades

    @cacheable('variedades_cultivo', key_func=lambda id_variedad: f"id_{id_variedad}", ttl=3600)  # 1 hora
    def obtener_por_id(self, id_variedad):
        """
        Obtiene una variedad de cultivo por su ID.
        
        Args:
            id_variedad (int): ID de la variedad de cultivo.
            
        Returns:
            dict: Información de la variedad de cultivo.
            
        Raises:
            RegistroNoEncontrado: Si la variedad no existe.
        """
        query = """
        SELECT v.id_variedad, v.id_tipo_cultivo, v.nombre, v.tiempo_produccion, 
               v.rendimiento_esperado, v.resistencia_zona, v.activo,
               t.nombre AS nombre_tipo_cultivo, t.nombre_cientifico AS nombre_cientifico_tipo
        FROM VariedadesCultivo v
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE v.id_variedad = ? AND v.activo = 1 AND t.activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (id_variedad,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Variedad de cultivo con ID {id_variedad} no encontrada")
        
        return self._construir_objeto_variedad_cultivo(rows[0])

    @cacheable('variedades_cultivo', key_func=lambda id_tipo: f"tipo_{id_tipo}", ttl=1200)  # 20 min
    def obtener_por_tipo_cultivo(self, id_tipo_cultivo):
        """
        Obtiene variedades de un tipo de cultivo específico.
        
        Args:
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            list: Lista de variedades del tipo de cultivo.
        """
        query = """
        SELECT v.id_variedad, v.id_tipo_cultivo, v.nombre, v.tiempo_produccion, 
               v.rendimiento_esperado, v.resistencia_zona, v.activo,
               t.nombre AS nombre_tipo_cultivo, t.nombre_cientifico AS nombre_cientifico_tipo
        FROM VariedadesCultivo v
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE v.id_tipo_cultivo = ? AND v.activo = 1 AND t.activo = 1
        ORDER BY v.nombre
        """
        
        rows = self._ejecutar_consulta(query, (id_tipo_cultivo,))
        variedades = []
        
        for row in rows:
            variedad = self._construir_objeto_variedad_cultivo(row)
            variedades.append(variedad)
        
        logger.info(f"Se obtuvieron {len(variedades)} variedades del tipo de cultivo {id_tipo_cultivo}")
        return variedades

    @cacheable('variedades_cultivo', key_func=lambda pagina, por_pagina=10, tipo_id=None: f"pag_{pagina}_{por_pagina}_{tipo_id or 'all'}", ttl=1200)  # 20 min
    def obtener_paginado(self, pagina, por_pagina=10, id_tipo_cultivo=None):
        """
        Obtiene variedades con paginación y filtro opcional por tipo de cultivo.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            id_tipo_cultivo (int, optional): ID del tipo de cultivo para filtrar.
            
        Returns:
            dict: Variedades, total_registros, total_paginas, pagina_actual.
        """
        pagina, por_pagina, offset = self._validar_parametros_paginacion(pagina, por_pagina)
        
        # Construir condiciones WHERE
        where_clause = "v.activo = 1 AND t.activo = 1"
        params_count = []
        params_data = []
        
        if id_tipo_cultivo and id_tipo_cultivo != 0:
            where_clause += " AND v.id_tipo_cultivo = ?"
            params_count.append(id_tipo_cultivo)
            params_data.append(id_tipo_cultivo)
        
        # Contar total de registros (ahora cacheado)
        total_registros = self._contar_registros_cached(id_tipo_cultivo)
        
        # Obtener registros paginados
        data_query = f"""
        SELECT v.id_variedad, v.id_tipo_cultivo, v.nombre, v.tiempo_produccion, 
               v.rendimiento_esperado, v.resistencia_zona, v.activo,
               t.nombre AS nombre_tipo_cultivo, t.nombre_cientifico AS nombre_cientifico_tipo
        FROM VariedadesCultivo v
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE {where_clause}
        ORDER BY t.nombre, v.nombre
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        
        params_data.extend([offset, por_pagina])
        rows = self._ejecutar_consulta(data_query, params_data)
        
        variedades = []
        for row in rows:
            variedad = self._construir_objeto_variedad_cultivo(row)
            variedades.append(variedad)
        
        total_paginas = self._calcular_total_paginas(total_registros, por_pagina)
        
        resultado = {
            'variedades': variedades,
            'total_registros': total_registros,
            'total_paginas': total_paginas,
            'pagina_actual': pagina
        }
        
        logger.info(f"Página {pagina}: {len(variedades)} variedades de {total_registros} totales")
        return resultado

    @cacheable('variedades_cultivo', key_func=lambda texto: f"buscar_{texto.lower().replace(' ', '_')}", ttl=900)  # 15 min
    def buscar_por_nombre(self, texto_busqueda):
        """
        Busca variedades por nombre.
        
        Args:
            texto_busqueda (str): Texto a buscar.
            
        Returns:
            list: Lista de variedades que coinciden.
        """
        query = """
        SELECT v.id_variedad, v.id_tipo_cultivo, v.nombre, v.tiempo_produccion, 
               v.rendimiento_esperado, v.resistencia_zona, v.activo,
               t.nombre AS nombre_tipo_cultivo, t.nombre_cientifico AS nombre_cientifico_tipo
        FROM VariedadesCultivo v
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE v.activo = 1 AND t.activo = 1 
        AND (v.nombre LIKE ? OR t.nombre LIKE ? OR v.resistencia_zona LIKE ?)
        ORDER BY t.nombre, v.nombre
        """
        
        patron = f"%{texto_busqueda}%"
        rows = self._ejecutar_consulta(query, (patron, patron, patron))
        
        variedades = []
        for row in rows:
            variedad = self._construir_objeto_variedad_cultivo(row)
            variedades.append(variedad)
        
        logger.info(f"Búsqueda '{texto_busqueda}': {len(variedades)} resultados")
        return variedades

    @cacheable('variedades_cultivo', key_func=lambda rendimiento_min: f"rendimiento_{rendimiento_min}", ttl=1800)  # 30 min
    def obtener_por_rendimiento(self, rendimiento_minimo):
        """
        Obtiene variedades filtradas por rendimiento mínimo esperado.
        
        Args:
            rendimiento_minimo (float): Rendimiento mínimo esperado.
            
        Returns:
            list: Lista de variedades que superan el rendimiento mínimo.
        """
        query = """
        SELECT v.id_variedad, v.id_tipo_cultivo, v.nombre, v.tiempo_produccion, 
               v.rendimiento_esperado, v.resistencia_zona, v.activo,
               t.nombre AS nombre_tipo_cultivo, t.nombre_cientifico AS nombre_cientifico_tipo
        FROM VariedadesCultivo v
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE v.activo = 1 AND t.activo = 1 
        AND v.rendimiento_esperado >= ?
        ORDER BY v.rendimiento_esperado DESC, t.nombre, v.nombre
        """
        
        rows = self._ejecutar_consulta(query, (rendimiento_minimo,))
        variedades = []
        
        for row in rows:
            variedad = self._construir_objeto_variedad_cultivo(row)
            variedades.append(variedad)
        
        logger.info(f"Variedades con rendimiento ≥ {rendimiento_minimo}: {len(variedades)} resultados")
        return variedades

    @cacheable('estadisticas_variedades', key_func=lambda tipo_id=None: f"conteo_{tipo_id or 'all'}", ttl=1800)  # 30 min
    def _contar_registros_cached(self, id_tipo_cultivo=None):
        """
        Cuenta registros de variedades (versión cacheada).
        
        Args:
            id_tipo_cultivo (int, optional): ID del tipo de cultivo para filtrar.
            
        Returns:
            int: Número total de variedades.
        """
        if id_tipo_cultivo and id_tipo_cultivo != 0:
            count_query = """
            SELECT COUNT(*)
            FROM VariedadesCultivo v
            JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
            WHERE v.activo = 1 AND t.activo = 1 AND v.id_tipo_cultivo = ?
            """
            return self._ejecutar_consulta_escalar(count_query, (id_tipo_cultivo,))
        else:
            count_query = """
            SELECT COUNT(*)
            FROM VariedadesCultivo v
            JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
            WHERE v.activo = 1 AND t.activo = 1
            """
            return self._ejecutar_consulta_escalar(count_query)

    @cacheable('estadisticas_variedades', key_func=lambda *args: 'estadisticas_basicas', ttl=1800)  # 30 min
    def obtener_estadisticas(self):
        """
        Obtiene estadísticas básicas de variedades de cultivo.
        
        Returns:
            dict: Estadísticas de variedades.
        """
        query = """
        SELECT 
            COUNT(*) as total_variedades,
            COUNT(DISTINCT v.id_tipo_cultivo) as tipos_cultivo_con_variedades,
            COUNT(CASE WHEN v.rendimiento_esperado IS NOT NULL THEN 1 END) as con_rendimiento,
            AVG(v.rendimiento_esperado) as rendimiento_promedio,
            COUNT(CASE WHEN v.tiempo_produccion IS NOT NULL THEN 1 END) as con_tiempo_produccion,
            AVG(v.tiempo_produccion) as tiempo_promedio_produccion
        FROM VariedadesCultivo v
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE v.activo = 1 AND t.activo = 1
        """
        
        rows = self._ejecutar_consulta(query)
        if rows:
            row = rows[0]
            stats = {
                'total_variedades': row.total_variedades,
                'tipos_cultivo_con_variedades': row.tipos_cultivo_con_variedades,
                'con_rendimiento_esperado': row.con_rendimiento,
                'rendimiento_promedio': float(row.rendimiento_promedio) if row.rendimiento_promedio else 0,
                'con_tiempo_produccion': row.con_tiempo_produccion,
                'tiempo_promedio_produccion': float(row.tiempo_promedio_produccion) if row.tiempo_promedio_produccion else 0
            }
        else:
            stats = {
                'total_variedades': 0,
                'tipos_cultivo_con_variedades': 0,
                'con_rendimiento_esperado': 0,
                'rendimiento_promedio': 0,
                'con_tiempo_produccion': 0,
                'tiempo_promedio_produccion': 0
            }
        
        logger.info(f"Estadísticas variedades de cultivo: {stats}")
        return stats

    @cacheable('variedades_cultivo', key_func=lambda limite=10: f'ranking_rendimiento_{limite}', ttl=1800)  # 30 min
    def obtener_ranking_por_rendimiento(self, limite=10):
        """
        Obtiene las variedades con mejor rendimiento esperado.
        
        Args:
            limite (int): Número máximo de variedades a retornar.
            
        Returns:
            list: Lista de variedades ordenadas por rendimiento.
        """
        query = """
        SELECT TOP (?) v.id_variedad, v.id_tipo_cultivo, v.nombre, v.tiempo_produccion, 
               v.rendimiento_esperado, v.resistencia_zona, v.activo,
               t.nombre AS nombre_tipo_cultivo, t.nombre_cientifico AS nombre_cientifico_tipo
        FROM VariedadesCultivo v
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE v.activo = 1 AND t.activo = 1 
        AND v.rendimiento_esperado IS NOT NULL
        ORDER BY v.rendimiento_esperado DESC
        """
        
        rows = self._ejecutar_consulta(query, (limite,))
        variedades = []
        
        for i, row in enumerate(rows, 1):
            variedad = self._construir_objeto_variedad_cultivo(row)
            variedad['ranking'] = i
            variedades.append(variedad)
        
        logger.info(f"Ranking de variedades por rendimiento: top {len(variedades)}")
        return variedades

    # ==================== MÉTODOS DE ESCRITURA CON INVALIDACIÓN OPTIMIZADA ====================

    @cache_invalidator('variedades_cultivo', key='todas_activas')     # Lista completa
    @cache_invalidator('variedades_cultivo', pattern='pag_')          # Paginación
    @cache_invalidator('variedades_cultivo', pattern='tipo_')         # Por tipo
    @cache_invalidator('variedades_cultivo', pattern='buscar_')       # Búsquedas
    @cache_invalidator('variedades_cultivo', pattern='rendimiento_')  # Por rendimiento
    @cache_invalidator('estadisticas_variedades')                     # Estadísticas
    def crear(self, datos_variedad):
        """
        Crea una nueva variedad de cultivo.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            datos_variedad (dict): Datos de la variedad.
            
        Returns:
            tuple: (True, id_variedad) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
            RegistroYaExiste: Si ya existe una variedad con el mismo nombre en el tipo.
        """
        self._validar_datos_variedad(datos_variedad)
        
        # Verificar si ya existe una variedad con el mismo nombre en el mismo tipo
        if self._existe_nombre_en_tipo(datos_variedad['nombre'], datos_variedad['id_tipo_cultivo']):
            raise RegistroYaExiste(f"Ya existe una variedad '{datos_variedad['nombre']}' en este tipo de cultivo")
        
        query = """
        INSERT INTO VariedadesCultivo (id_tipo_cultivo, nombre, tiempo_produccion, 
                                    rendimiento_esperado, resistencia_zona, activo)
        VALUES (?, ?, ?, ?, ?, ?)
        """
        
        valores = (
            datos_variedad['id_tipo_cultivo'],
            datos_variedad['nombre'],
            datos_variedad.get('tiempo_produccion'),
            datos_variedad.get('rendimiento_esperado'),
            datos_variedad.get('resistencia_zona'),
            1  # activo por defecto
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_variedad = self._obtener_ultimo_id()
        
        logger.info(f"Variedad de cultivo creada con ID: {id_variedad}")
        return True, id_variedad

    @cache_invalidator('variedades_cultivo', pattern='id_')           # Específica
    @cache_invalidator('variedades_cultivo', key='todas_activas')     # Lista completa
    @cache_invalidator('variedades_cultivo', pattern='pag_')          # Paginación
    @cache_invalidator('variedades_cultivo', pattern='tipo_')         # Por tipo
    @cache_invalidator('variedades_cultivo', pattern='buscar_')       # Búsquedas
    @cache_invalidator('variedades_cultivo', pattern='rendimiento_')  # Por rendimiento
    @cache_invalidator('estadisticas_variedades')                     # Estadísticas
    def actualizar(self, id_variedad, datos_variedad):
        """
        Actualiza una variedad de cultivo existente.
        OPTIMIZADO: Invalidación específica y general.
        
        Args:
            id_variedad (int): ID de la variedad.
            datos_variedad (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si la variedad no existe.
            ErrorValidacion: Si los datos no son válidos.
        """
        # Verificar que la variedad existe
        variedad_actual = self.obtener_por_id(id_variedad)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        if 'id_tipo_cultivo' in datos_variedad:
            campos_actualizar.append("id_tipo_cultivo = ?")
            valores.append(datos_variedad['id_tipo_cultivo'])
            
        if 'nombre' in datos_variedad:
            # Verificar que el nuevo nombre no exista en el tipo (excluyendo el registro actual)
            tipo_id = datos_variedad.get('id_tipo_cultivo', variedad_actual['id_tipo_cultivo'])
            if self._existe_nombre_en_tipo_excepto(datos_variedad['nombre'], tipo_id, id_variedad):
                raise RegistroYaExiste(f"Ya existe otra variedad '{datos_variedad['nombre']}' en este tipo de cultivo")
            campos_actualizar.append("nombre = ?")
            valores.append(datos_variedad['nombre'])
            
        if 'tiempo_produccion' in datos_variedad:
            campos_actualizar.append("tiempo_produccion = ?")
            valores.append(datos_variedad['tiempo_produccion'])
            
        if 'rendimiento_esperado' in datos_variedad:
            campos_actualizar.append("rendimiento_esperado = ?")
            valores.append(datos_variedad['rendimiento_esperado'])
            
        if 'resistencia_zona' in datos_variedad:
            campos_actualizar.append("resistencia_zona = ?")
            valores.append(datos_variedad['resistencia_zona'])
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        # Validar datos antes de actualizar
        datos_para_validar = variedad_actual.copy()
        datos_para_validar.update(datos_variedad)
        self._validar_datos_variedad(datos_para_validar)
        
        query = f"UPDATE VariedadesCultivo SET {', '.join(campos_actualizar)} WHERE id_variedad = ?"
        valores.append(id_variedad)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Variedad {id_variedad} actualizada. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('variedades_cultivo', pattern='id_')           # Específica
    @cache_invalidator('variedades_cultivo', key='todas_activas')     # Lista completa
    @cache_invalidator('variedades_cultivo', pattern='pag_')          # Paginación
    @cache_invalidator('variedades_cultivo', pattern='tipo_')         # Por tipo
    @cache_invalidator('variedades_cultivo', pattern='buscar_')       # Búsquedas
    @cache_invalidator('variedades_cultivo', pattern='rendimiento_')  # Por rendimiento
    @cache_invalidator('estadisticas_variedades')                     # Estadísticas
    def desactivar(self, id_variedad):
        """
        Desactiva una variedad de cultivo (eliminación lógica).
        OPTIMIZADO: Invalidación completa ya que afecta todas las listas.
        
        Args:
            id_variedad (int): ID de la variedad.
            
        Returns:
            bool: True si se desactivó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si la variedad no existe.
        """
        # Verificar que la variedad existe
        self.obtener_por_id(id_variedad)
        
        query = "UPDATE VariedadesCultivo SET activo = 0 WHERE id_variedad = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_variedad,), obtener_resultado=False)
        
        logger.info(f"Variedad {id_variedad} desactivada. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _construir_objeto_variedad_cultivo(self, row):
        """
        Construye un objeto variedad de cultivo a partir de una fila de la base de datos.
        
        Args:
            row: Fila de la consulta.
            
        Returns:
            dict: Objeto variedad estructurado.
        """
        return {
            'id_variedad': row.id_variedad,
            'id': row.id_variedad,  # Alias para compatibilidad
            'id_tipo_cultivo': row.id_tipo_cultivo,
            'nombre': row.nombre or '',
            'tiempo_produccion': row.tiempo_produccion,
            'rendimiento_esperado': float(row.rendimiento_esperado) if row.rendimiento_esperado else None,
            'resistencia_zona': row.resistencia_zona or '',
            'activo': bool(row.activo),
            
            # Información del tipo de cultivo
            'nombre_tipo_cultivo': row.nombre_tipo_cultivo or '',
            'nombre_cientifico_tipo': row.nombre_cientifico_tipo or '',
            'nombre_completo': f"{row.nombre_tipo_cultivo} - {row.nombre}" if row.nombre_tipo_cultivo else row.nombre,
            
            # Campos calculados
            'tiene_rendimiento': bool(row.rendimiento_esperado),
            'tiene_tiempo_produccion': bool(row.tiempo_produccion),
            'rendimiento_texto': self._formatear_rendimiento(row.rendimiento_esperado),
            'tiempo_produccion_texto': self._formatear_tiempo_produccion(row.tiempo_produccion),
            'categoria_rendimiento': self._categorizar_rendimiento(row.rendimiento_esperado)
        }
    
    def _validar_datos_variedad(self, datos):
        """
        Valida los datos de la variedad de cultivo.
        
        Args:
            datos (dict): Datos a validar.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        if not datos.get('nombre') or not datos.get('nombre').strip():
            raise ErrorValidacion("El nombre de la variedad es obligatorio")
        
        if not datos.get('id_tipo_cultivo'):
            raise ErrorValidacion("El tipo de cultivo es obligatorio")
        
        # Validar tiempo de producción
        tiempo_produccion = datos.get('tiempo_produccion')
        if tiempo_produccion is not None and tiempo_produccion < 0:
            raise ErrorValidacion("El tiempo de producción debe ser positivo")
        
        # Validar rendimiento esperado
        rendimiento = datos.get('rendimiento_esperado')
        if rendimiento is not None and rendimiento < 0:
            raise ErrorValidacion("El rendimiento esperado debe ser positivo")
        
        # Validar longitud de campos
        if len(datos.get('nombre', '')) > 100:
            raise ErrorValidacion("El nombre no puede exceder 100 caracteres")
            
        if datos.get('resistencia_zona') and len(datos['resistencia_zona']) > 200:
            raise ErrorValidacion("La resistencia de zona no puede exceder 200 caracteres")
    
    def _existe_nombre_en_tipo(self, nombre, id_tipo_cultivo):
        """
        Verifica si una variedad ya existe en un tipo de cultivo específico.
        
        Args:
            nombre (str): Nombre a verificar.
            id_tipo_cultivo (int): ID del tipo de cultivo.
            
        Returns:
            bool: True si existe.
        """
        count = self._contar_registros(
            "VariedadesCultivo", 
            "nombre = ? AND id_tipo_cultivo = ? AND activo = 1", 
            (nombre, id_tipo_cultivo)
        )
        return count > 0
    
    def _existe_nombre_en_tipo_excepto(self, nombre, id_tipo_cultivo, id_excluir):
        """
        Verifica si una variedad ya existe en un tipo excluyendo un ID específico.
        
        Args:
            nombre (str): Nombre a verificar.
            id_tipo_cultivo (int): ID del tipo de cultivo.
            id_excluir (int): ID a excluir de la búsqueda.
            
        Returns:
            bool: True si existe.
        """
        count = self._contar_registros(
            "VariedadesCultivo", 
            "nombre = ? AND id_tipo_cultivo = ? AND activo = 1 AND id_variedad != ?", 
            (nombre, id_tipo_cultivo, id_excluir)
        )
        return count > 0
    
    def _formatear_rendimiento(self, rendimiento):
        """
        Formatea el rendimiento esperado.
        
        Args:
            rendimiento (float): Rendimiento esperado.
            
        Returns:
            str: Rendimiento formateado.
        """
        if rendimiento is None:
            return "No especificado"
        return f"{rendimiento:,.2f} ton/ha"
    
    def _formatear_tiempo_produccion(self, tiempo):
        """
        Formatea el tiempo de producción.
        
        Args:
            tiempo (int): Tiempo en días.
            
        Returns:
            str: Tiempo formateado.
        """
        if tiempo is None:
            return "No especificado"
        return f"{tiempo} días"
    
    def _categorizar_rendimiento(self, rendimiento):
        """
        Categoriza el rendimiento esperado.
        
        Args:
            rendimiento (float): Rendimiento esperado.
            
        Returns:
            str: Categoría del rendimiento.
        """
        if rendimiento is None:
            return "sin_datos"
        elif rendimiento < 5:
            return "bajo"
        elif rendimiento < 15:
            return "medio"
        elif rendimiento < 30:
            return "alto"
        else:
            return "muy_alto"