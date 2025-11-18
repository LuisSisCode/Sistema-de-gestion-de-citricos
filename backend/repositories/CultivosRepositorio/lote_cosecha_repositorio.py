# bd_conecciones/repositorios/CultivosRepositorio/lote_cosecha_repositorio.py

import logging
from datetime import datetime, date
from ...core.repositorio_base import RepositorioBase
from ...core.excepciones_bd import RegistroNoEncontrado, RegistroYaExiste, ErrorValidacion
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class LoteCosechaRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de lotes de cosecha con caché optimizado."""

    @cacheable('lotes_cosecha', key_func=lambda: 'todos_activos', ttl=900)  # 15 min
    def obtener_todos(self):
        """
        Obtiene todos los lotes de cosecha activos con información completa.
        
        Returns:
            list: Lista de diccionarios con información de lotes de cosecha.
        """
        query = """
        SELECT l.id_lote, l.id_ciclo, l.codigo_lote,
               l.fecha_cosecha, l.cantidad_cosechada, l.unidad_medida,
               l.registrado_por, l.observaciones, l.activo,
               c.id_parcela, c.id_variedad, c.area_sembrada,
               p.nombre AS nombre_parcela,
               v.nombre AS nombre_variedad,
               t.nombre AS nombre_tipo_cultivo,
               a.nombre + ' ' + a.apellido AS nombre_productor,
               u.nombre + ' ' + u.apellido AS registrado_por_nombre
        FROM LotesCosecha l
        JOIN CiclosProduccion c ON l.id_ciclo = c.id_ciclo
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Productores a ON p.id_productor = a.id_productor
        JOIN Usuarios u ON l.registrado_por = u.id_usuario
        WHERE l.activo = 1 AND p.activo = 1 AND v.activo = 1 AND t.activo = 1
        ORDER BY l.fecha_cosecha DESC
        """
        
        rows = self._ejecutar_consulta(query)
        lotes = []
        
        for row in rows:
            lote = self._construir_objeto_lote_cosecha(row)
            lotes.append(lote)
        
        logger.info(f"Se obtuvieron {len(lotes)} lotes de cosecha")
        return lotes

    @cacheable('lotes_cosecha', key_func=lambda id_lote: f"id_{id_lote}", ttl=1800)  # 30 min
    def obtener_por_id(self, id_lote):
        """
        Obtiene un lote de cosecha por su ID.
        
        Args:
            id_lote (int): ID del lote de cosecha.
            
        Returns:
            dict: Información del lote de cosecha.
            
        Raises:
            RegistroNoEncontrado: Si el lote no existe.
        """
        query = """
        SELECT l.id_lote, l.id_ciclo, l.codigo_lote,
               l.fecha_cosecha, l.cantidad_cosechada, l.unidad_medida,
               l.registrado_por, l.observaciones, l.activo,
               c.id_parcela, c.id_variedad, c.area_sembrada,
               p.nombre AS nombre_parcela,
               v.nombre AS nombre_variedad,
               t.nombre AS nombre_tipo_cultivo,
               a.nombre + ' ' + a.apellido AS nombre_productor,
               u.nombre + ' ' + u.apellido AS registrado_por_nombre
        FROM LotesCosecha l
        JOIN CiclosProduccion c ON l.id_ciclo = c.id_ciclo
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Productores a ON p.id_productor = a.id_productor
        JOIN Usuarios u ON l.registrado_por = u.id_usuario
        WHERE l.id_lote = ? AND l.activo = 1
        """
        
        rows = self._ejecutar_consulta(query, (id_lote,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Lote de cosecha con ID {id_lote} no encontrado")
        
        return self._construir_objeto_lote_cosecha(rows[0])

    @cacheable('lotes_cosecha', key_func=lambda id_ciclo: f"ciclo_{id_ciclo}", ttl=900)  # 15 min
    def obtener_por_ciclo(self, id_ciclo):
        """
        Obtiene lotes de cosecha de un ciclo específico.
        
        Args:
            id_ciclo (int): ID del ciclo de producción.
            
        Returns:
            list: Lista de lotes del ciclo.
        """
        query = """
        SELECT l.id_lote, l.id_ciclo, l.codigo_lote,
               l.fecha_cosecha, l.cantidad_cosechada, l.unidad_medida,
               l.registrado_por, l.observaciones, l.activo,
               c.id_parcela, c.id_variedad, c.area_sembrada,
               p.nombre AS nombre_parcela,
               v.nombre AS nombre_variedad,
               t.nombre AS nombre_tipo_cultivo,
               a.nombre + ' ' + a.apellido AS nombre_productor,
               u.nombre + ' ' + u.apellido AS registrado_por_nombre
        FROM LotesCosecha l
        JOIN CiclosProduccion c ON l.id_ciclo = c.id_ciclo
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Productores a ON p.id_productor = a.id_productor
        JOIN Usuarios u ON l.registrado_por = u.id_usuario
        WHERE l.id_ciclo = ? AND l.activo = 1
        ORDER BY l.fecha_cosecha DESC
        """
        
        rows = self._ejecutar_consulta(query, (id_ciclo,))
        lotes = []
        
        for row in rows:
            lote = self._construir_objeto_lote_cosecha(row)
            lotes.append(lote)
        
        logger.info(f"Se obtuvieron {len(lotes)} lotes del ciclo {id_ciclo}")
        return lotes

    @cacheable('lotes_cosecha', key_func=lambda fecha_desde, fecha_hasta: f"fecha_{fecha_desde}_{fecha_hasta}", ttl=600)  # 10 min
    def obtener_por_rango_fechas(self, fecha_desde, fecha_hasta):
        """
        Obtiene lotes de cosecha en un rango de fechas.
        
        Args:
            fecha_desde (date): Fecha inicial.
            fecha_hasta (date): Fecha final.
            
        Returns:
            list: Lista de lotes en el rango.
        """
        query = """
        SELECT l.id_lote, l.id_ciclo, l.codigo_lote,
               l.fecha_cosecha, l.cantidad_cosechada, l.unidad_medida,
               l.registrado_por, l.observaciones, l.activo,
               c.id_parcela, c.id_variedad, c.area_sembrada,
               p.nombre AS nombre_parcela,
               v.nombre AS nombre_variedad,
               t.nombre AS nombre_tipo_cultivo,
               a.nombre + ' ' + a.apellido AS nombre_productor,
               u.nombre + ' ' + u.apellido AS registrado_por_nombre
        FROM LotesCosecha l
        JOIN CiclosProduccion c ON l.id_ciclo = c.id_ciclo
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Productores a ON p.id_productor = a.id_productor
        JOIN Usuarios u ON l.registrado_por = u.id_usuario
        WHERE l.fecha_cosecha BETWEEN ? AND ? AND l.activo = 1
        ORDER BY l.fecha_cosecha DESC
        """
        
        rows = self._ejecutar_consulta(query, (fecha_desde, fecha_hasta))
        lotes = []
        
        for row in rows:
            lote = self._construir_objeto_lote_cosecha(row)
            lotes.append(lote)
        
        logger.info(f"Se obtuvieron {len(lotes)} lotes entre {fecha_desde} y {fecha_hasta}")
        return lotes

    @cacheable('lotes_disponibles', key_func=lambda: 'para_venta', ttl=300)  # 5 min - más frecuente
    def obtener_disponibles_para_venta(self):
        """
        Obtiene lotes disponibles para venta (no vendidos completamente).
        
        Returns:
            list: Lista de lotes disponibles.
        """
        query = """
        SELECT 
            l.id_lote, l.id_ciclo, l.codigo_lote,
            l.fecha_cosecha, l.cantidad_cosechada, l.unidad_medida,
            l.registrado_por, 
            MAX(CAST(l.observaciones AS VARCHAR(MAX))) AS observaciones, 
            l.activo,
            c.id_parcela, c.id_variedad, c.area_sembrada,
            p.nombre AS nombre_parcela,
            v.nombre AS nombre_variedad,
            t.nombre AS nombre_tipo_cultivo,
            a.nombre + ' ' + a.apellido AS nombre_productor,
            u.nombre + ' ' + u.apellido AS registrado_por_nombre,
            COALESCE(SUM(dv.cantidad), 0) AS cantidad_vendida,
            (l.cantidad_cosechada - COALESCE(SUM(dv.cantidad), 0)) AS cantidad_disponible
        FROM LotesCosecha l
        JOIN CiclosProduccion c ON l.id_ciclo = c.id_ciclo
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        JOIN Productores a ON p.id_productor = a.id_productor
        JOIN Usuarios u ON l.registrado_por = u.id_usuario
        LEFT JOIN DetallesVenta dv ON l.id_lote = dv.id_lote
        WHERE l.activo = 1
        GROUP BY 
            l.id_lote, l.id_ciclo, l.codigo_lote,
            l.fecha_cosecha, l.cantidad_cosechada, l.unidad_medida,
            l.registrado_por, l.activo,
            c.id_parcela, c.id_variedad, c.area_sembrada,
            p.nombre, v.nombre, t.nombre, a.nombre, a.apellido,
            u.nombre, u.apellido
        HAVING (l.cantidad_cosechada - COALESCE(SUM(dv.cantidad), 0)) > 0
        ORDER BY l.fecha_cosecha DESC
        """
        
        rows = self._ejecutar_consulta(query)
        lotes = []
        
        for row in rows:
            lote = self._construir_objeto_lote_cosecha(row)
            lote['cantidad_vendida'] = float(row.cantidad_vendida)
            lote['cantidad_disponible'] = float(row.cantidad_disponible)
            lotes.append(lote)
        
        logger.info(f"Se obtuvieron {len(lotes)} lotes disponibles para venta")
        return lotes

    @cacheable('estadisticas_lotes', key_func=lambda: 'estadisticas_basicas', ttl=900)  # 15 min
    def obtener_estadisticas(self):
        """
        Obtiene estadísticas básicas de lotes de cosecha.
        
        Returns:
            dict: Estadísticas de lotes.
        """
        query = """
        SELECT 
            COUNT(*) as total_lotes,
            COUNT(DISTINCT l.id_ciclo) as ciclos_cosechados,
            COUNT(DISTINCT cc.id_categoria) as categorias_utilizadas,
            SUM(l.cantidad_cosechada) as cantidad_total_cosechada,
            AVG(l.cantidad_cosechada) as cantidad_promedio_lote,
            AVG precio_promedio_sugerido,
            COUNT(CASE WHEN l.fecha_cosecha >= DATEADD(month, -1, GETDATE()) THEN 1 END) as lotes_ultimo_mes
        FROM LotesCosecha l
        WHERE l.activo = 1
        """
        
        rows = self._ejecutar_consulta(query)
        if rows:
            row = rows[0]
            stats = {
                'total_lotes': row.total_lotes,
                'ciclos_cosechados': row.ciclos_cosechados,
                'categorias_utilizadas': row.categorias_utilizadas,
                'cantidad_total_cosechada': float(row.cantidad_total_cosechada) if row.cantidad_total_cosechada else 0,
                'cantidad_promedio_lote': float(row.cantidad_promedio_lote) if row.cantidad_promedio_lote else 0,
                'precio_promedio_sugerido': float(row.precio_promedio_sugerido) if row.precio_promedio_sugerido else 0,
                'lotes_ultimo_mes': row.lotes_ultimo_mes
            }
        else:
            stats = {
                'total_lotes': 0, 'ciclos_cosechados': 0, 'categorias_utilizadas': 0,
                'cantidad_total_cosechada': 0, 'cantidad_promedio_lote': 0,
                'precio_promedio_sugerido': 0, 'lotes_ultimo_mes': 0
            }
        
        # Obtener distribución por calidad
        calidad_query = """
        SELECT COUNT(*) as cantidad, SUM(l.cantidad_cosechada) as total_cosechado
        FROM LotesCosecha l
        WHERE l.activo = 1
        ORDER BY total_cosechado DESC
        """
        
        calidad_rows = self._ejecutar_consulta(calidad_query)
        stats['distribucion_calidad'] = [
            {
                'categoria': row.nombre,
                'cantidad_lotes': row.cantidad,
                'total_cosechado': float(row.total_cosechado)
            }
            for row in calidad_rows
        ]
        
        logger.info(f"Estadísticas lotes de cosecha: {stats}")
        return stats

    # ==================== MÉTODOS DE ESCRITURA CON INVALIDACIÓN OPTIMIZADA ====================

    @cache_invalidator('lotes_cosecha', key='todos_activos')       # Lista completa
    @cache_invalidator('lotes_cosecha', pattern='ciclo_')          # Por ciclo
    @cache_invalidator('lotes_cosecha', pattern='fecha_')          # Por fecha
    @cache_invalidator('lotes_disponibles')                        # Disponibles para venta
    @cache_invalidator('estadisticas_lotes')                       # Estadísticas
    def crear(self, datos_lote):
        """
        Crea un nuevo lote de cosecha.
        OPTIMIZADO: Invalidación granular del caché afectado.
        
        Args:
            datos_lote (dict): Datos del lote.
            
        Returns:
            tuple: (True, id_lote) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        self._validar_datos_lote(datos_lote)
        
        # Generar código de lote si no se proporciona
        if not datos_lote.get('codigo_lote'):
            datos_lote['codigo_lote'] = self._generar_codigo_lote(datos_lote['id_ciclo'])
        
        query = """
        INSERT INTO LotesCosecha (
            id_ciclo, codigo_lote, fecha_cosecha,
            cantidad_cosechada, unidad_medida,
            registrado_por, observaciones, activo
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        valores = (
            datos_lote['id_ciclo'],
            datos_lote['codigo_lote'],
            datos_lote['fecha_cosecha'],
            datos_lote['cantidad_cosechada'],
            datos_lote.get('unidad_medida', 'kg'),
            datos_lote['registrado_por'],
            datos_lote.get('observaciones'),
            1  # activo por defecto
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_lote = self._obtener_ultimo_id()
        
        logger.info(f"Lote de cosecha creado con ID: {id_lote}")
        return True, id_lote

    @cache_invalidator('lotes_cosecha', pattern='id_')             # Específico
    @cache_invalidator('lotes_cosecha', key='todos_activos')       # Lista completa
    @cache_invalidator('lotes_cosecha', pattern='ciclo_')          # Por ciclo
    @cache_invalidator('lotes_disponibles')                        # Disponibles para venta
    @cache_invalidator('estadisticas_lotes')                       # Estadísticas
    def actualizar(self, id_lote, datos_lote):
        """
        Actualiza un lote de cosecha existente.
        OPTIMIZADO: Invalidación específica y general.
        
        Args:
            id_lote (int): ID del lote.
            datos_lote (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
        """
        # Verificar que el lote existe
        lote_actual = self.obtener_por_id(id_lote)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        campos_permitidos = [
            'codigo_lote', 'fecha_cosecha',
            'cantidad_cosechada', 'unidad_medida',
            'observaciones'
        ]
        
        for campo in campos_permitidos:
            if campo in datos_lote:
                campos_actualizar.append(f"{campo} = ?")
                valores.append(datos_lote[campo])
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        # Validar datos antes de actualizar
        datos_para_validar = lote_actual.copy()
        datos_para_validar.update(datos_lote)
        self._validar_datos_lote(datos_para_validar)
        
        query = f"UPDATE LotesCosecha SET {', '.join(campos_actualizar)} WHERE id_lote = ?"
        valores.append(id_lote)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Lote {id_lote} actualizado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('lotes_cosecha', pattern='id_')             # Específico
    @cache_invalidator('lotes_cosecha', key='todos_activos')       # Lista completa
    @cache_invalidator('lotes_cosecha', pattern='ciclo_')          # Por ciclo
    @cache_invalidator('lotes_disponibles')                        # Disponibles para venta
    @cache_invalidator('estadisticas_lotes')                       # Estadísticas
    def desactivar(self, id_lote):
        """
        Desactiva un lote de cosecha (eliminación lógica).
        
        Args:
            id_lote (int): ID del lote.
            
        Returns:
            bool: True si se desactivó correctamente.
        """
        # Verificar que el lote existe
        self.obtener_por_id(id_lote)
        
        query = "UPDATE LotesCosecha SET activo = 0 WHERE id_lote = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_lote,), obtener_resultado=False)
        
        logger.info(f"Lote {id_lote} desactivado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _construir_objeto_lote_cosecha(self, row):
        """
        Construye un objeto lote de cosecha a partir de una fila de la base de datos.
        
        Args:
            row: Fila de la consulta.
            
        Returns:
            dict: Objeto lote estructurado.
        """
        return {
            'id_lote': row.id_lote,
            'id': row.id_lote,  # Alias para compatibilidad
            'id_ciclo': row.id_ciclo,
            'codigo_lote': row.codigo_lote or '',
            'fecha_cosecha': self._formatear_fecha(row.fecha_cosecha),
            'cantidad_cosechada': float(row.cantidad_cosechada),
            'unidad_medida': row.unidad_medida or 'kg',
            'registrado_por': row.registrado_por,
            'observaciones': row.observaciones or '',
            'activo': bool(row.activo),
            
            # Información del ciclo
            'id_parcela': row.id_parcela,
            'id_variedad': row.id_variedad,
            'area_sembrada': float(row.area_sembrada),
            
            # Información relacionada
            'nombre_parcela': row.nombre_parcela or '',
            'nombre_variedad': row.nombre_variedad or '',
            'nombre_tipo_cultivo': row.nombre_tipo_cultivo or '',
            'nombre_productor': row.nombre_productor or '',
            'registrado_por_nombre': row.registrado_por_nombre or '',
            
            # Campos calculados
            'cultivo_completo': f"{row.nombre_tipo_cultivo} - {row.nombre_variedad}" if row.nombre_tipo_cultivo else row.nombre_variedad,
            'rendimiento_por_hectarea': float(row.cantidad_cosechada) / float(row.area_sembrada) if row.area_sembrada > 0 else 0,
            'dias_desde_cosecha': self._calcular_dias_desde_cosecha(row.fecha_cosecha),
            'cantidad_texto': f"{float(row.cantidad_cosechada):,.2f} {row.unidad_medida or 'kg'}"
        }
    
    def _validar_datos_lote(self, datos):
        """
        Valida los datos del lote de cosecha.
        
        Args:
            datos (dict): Datos a validar.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        if not datos.get('id_ciclo'):
            raise ErrorValidacion("El ciclo de producción es obligatorio")
        
        if not datos.get('fecha_cosecha'):
            raise ErrorValidacion("La fecha de cosecha es obligatoria")
        
        cantidad = datos.get('cantidad_cosechada')
        if not cantidad or cantidad <= 0:
            raise ErrorValidacion("La cantidad cosechada debe ser mayor a 0")
        
        # Validar que la fecha de cosecha no sea futura
        if isinstance(datos['fecha_cosecha'], str):
            fecha_cosecha = datetime.strptime(datos['fecha_cosecha'], '%Y-%m-%d').date()
        else:
            fecha_cosecha = datos['fecha_cosecha']
        
        if fecha_cosecha > date.today():
            raise ErrorValidacion("La fecha de cosecha no puede ser futura")
    
    def _generar_codigo_lote(self, id_ciclo):
        """
        Genera un código único para el lote.
        
        Args:
            id_ciclo (int): ID del ciclo de producción.
            
        Returns:
            str: Código único del lote.
        """
        fecha_actual = datetime.now()
        return f"L{id_ciclo}-{fecha_actual.strftime('%Y%m%d')}-{fecha_actual.strftime('%H%M')}"
    
    def _calcular_dias_desde_cosecha(self, fecha_cosecha):
        """
        Calcula los días transcurridos desde la cosecha.
        
        Args:
            fecha_cosecha: Fecha de cosecha.
            
        Returns:
            int: Días desde cosecha o None si no hay fecha.
        """
        if not fecha_cosecha:
            return None
        
        if isinstance(fecha_cosecha, str):
            try:
                fecha_cosecha = datetime.strptime(fecha_cosecha, '%Y-%m-%d').date()
            except:
                return None
        elif isinstance(fecha_cosecha, datetime):
            fecha_cosecha = fecha_cosecha.date()
        
        if isinstance(fecha_cosecha, date):
            return (date.today() - fecha_cosecha).days
        
        return None