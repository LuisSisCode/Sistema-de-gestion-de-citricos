# bd_conecciones/repositorio/ClientesVentasRep/detalle_venta_repositorio.py

import logging
from ...nucleo.repositorio_base import RepositorioBase
from ...nucleo.excepciones_bd import RegistroNoEncontrado, ErrorValidacion
from ...nucleo.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class DetalleVentaRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de detalles de venta con caché optimizado."""

    @cacheable('detalles_venta', key_func=lambda id_venta: f"venta_{id_venta}", ttl=900)  # 15 min
    def obtener_por_venta(self, id_venta):
        """
        Obtiene todos los detalles de una venta específica.
        
        Args:
            id_venta (int): ID de la venta para obtener sus detalles.
            
        Returns:
            list: Lista de diccionarios con la información de cada detalle.
        """
        query = """
        SELECT dv.id_detalle_venta, dv.id_venta, dv.id_lote,
               tc.nombre AS tipo_cultivo, vc.nombre AS variedad, 
               dv.cantidad, dv.unidad_medida, dv.precio_unitario, 
               dv.subtotal, dv.total, dv.observaciones
        FROM DetallesVenta dv
        JOIN LotesCosecha lc ON dv.id_lote = lc.id_lote
        JOIN CiclosProduccion cp ON lc.id_ciclo = cp.id_ciclo
        JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
        JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
        WHERE dv.id_venta = ?
        ORDER BY dv.id_detalle_venta
        """
        
        rows = self._ejecutar_consulta(query, (id_venta,))
        detalles = []
        
        for row in rows:
            detalle = {
                'id_detalle_venta': row.id_detalle_venta,
                'id_venta': row.id_venta,
                'id_lote': row.id_lote,
                'tipo_cultivo': row.tipo_cultivo,
                'variedad': row.variedad,
                'cantidad': float(row.cantidad),
                'unidad_medida': row.unidad_medida,
                'precio_unitario': float(row.precio_unitario),
                'subtotal': float(row.subtotal),
                'total': float(row.total),
                'observaciones': row.observaciones,
                'producto_completo': f"{row.tipo_cultivo} - {row.variedad}"
            }
            detalles.append(detalle)
        
        logger.info(f"Se obtuvieron {len(detalles)} detalles para la venta ID: {id_venta}")
        return detalles

    def obtener_todos(self):
        """
        Obtiene todos los detalles de venta (rara vez usado).
        
        Returns:
            list: Lista de todos los detalles de venta.
        """
        query = """
        SELECT dv.id_detalle_venta, dv.id_venta, dv.id_lote,
               v.codigo_venta, c.nombre AS cliente_nombre,
               tc.nombre AS tipo_cultivo, vc.nombre AS variedad,
               dv.cantidad, dv.unidad_medida, dv.precio_unitario,
               dv.subtotal, dv.total, dv.observaciones
        FROM DetallesVenta dv
        JOIN Ventas v ON dv.id_venta = v.id_venta
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        JOIN LotesCosecha lc ON dv.id_lote = lc.id_lote
        JOIN CiclosProduccion cp ON lc.id_ciclo = cp.id_ciclo
        JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
        JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
        ORDER BY dv.id_venta DESC, dv.id_detalle_venta
        """
        
        rows = self._ejecutar_consulta(query)
        detalles = []
        
        for row in rows:
            detalle = {
                'id_detalle_venta': row.id_detalle_venta,
                'id_venta': row.id_venta,
                'id_lote': row.id_lote,
                'codigo_venta': row.codigo_venta,
                'cliente_nombre': row.cliente_nombre,
                'tipo_cultivo': row.tipo_cultivo,
                'variedad': row.variedad,
                'cantidad': float(row.cantidad),
                'unidad_medida': row.unidad_medida,
                'precio_unitario': float(row.precio_unitario),
                'subtotal': float(row.subtotal),
                'total': float(row.total),
                'observaciones': row.observaciones,
                'producto_completo': f"{row.tipo_cultivo} - {row.variedad}"
            }
            detalles.append(detalle)
        
        logger.info(f"Se obtuvieron {len(detalles)} detalles de venta en total")
        return detalles

    @cacheable('detalles_venta', key_func=lambda id_detalle: f"id_{id_detalle}", ttl=1800)  # 30 min
    def obtener_por_id(self, id_detalle_venta):
        """
        Obtiene un detalle de venta específico por su ID.
        
        Args:
            id_detalle_venta (int): ID del detalle de venta.
            
        Returns:
            dict: Información del detalle de venta.
            
        Raises:
            RegistroNoEncontrado: Si el detalle no existe.
        """
        query = """
        SELECT dv.id_detalle_venta, dv.id_venta, dv.id_lote,
               v.codigo_venta, c.nombre AS cliente_nombre,
               tc.nombre AS tipo_cultivo, vc.nombre AS variedad,
               dv.cantidad, dv.unidad_medida, dv.precio_unitario,
               dv.subtotal, dv.total, dv.observaciones
        FROM DetallesVenta dv
        JOIN Ventas v ON dv.id_venta = v.id_venta
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        JOIN LotesCosecha lc ON dv.id_lote = lc.id_lote
        JOIN CiclosProduccion cp ON lc.id_ciclo = cp.id_ciclo
        JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
        JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
        WHERE dv.id_detalle_venta = ?
        """
        
        rows = self._ejecutar_consulta(query, (id_detalle_venta,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Detalle de venta con ID {id_detalle_venta} no encontrado")
        
        row = rows[0]
        return {
            'id_detalle_venta': row.id_detalle_venta,
            'id_venta': row.id_venta,
            'id_lote': row.id_lote,
            'codigo_venta': row.codigo_venta,
            'cliente_nombre': row.cliente_nombre,
            'tipo_cultivo': row.tipo_cultivo,
            'variedad': row.variedad,
            'cantidad': float(row.cantidad),
            'unidad_medida': row.unidad_medida,
            'precio_unitario': float(row.precio_unitario),
            'subtotal': float(row.subtotal),
            'total': float(row.total),
            'observaciones': row.observaciones,
            'producto_completo': f"{row.tipo_cultivo} - {row.variedad}"
        }

    @cacheable('lotes_venta', key_func=lambda: 'disponibles', ttl=1200)  # 20 min
    def obtener_lotes_disponibles(self):
        """
        Obtiene los lotes de cosecha disponibles para venta.
        
        Returns:
            list: Lista de lotes disponibles con información del producto.
        """
        query = """
        SELECT lc.id_lote, lc.codigo_lote, lc.fecha_cosecha,
               lc.cantidad_cosechada, lc.unidad_medida, lc.precio_unitario_sugerido,
               tc.nombre AS tipo_cultivo, vc.nombre AS variedad,
               cc.nombre AS categoria_calidad
        FROM LotesCosecha lc
        JOIN CiclosProduccion cp ON lc.id_ciclo = cp.id_ciclo
        JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
        JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
        JOIN CategoriasCalidad cc ON lc.id_categoria_calidad = cc.id_categoria
        WHERE lc.activo = 1 AND lc.cantidad_cosechada > 0
        ORDER BY lc.fecha_cosecha DESC, tc.nombre, vc.nombre
        """
        
        rows = self._ejecutar_consulta(query)
        lotes = []
        
        for row in rows:
            lote = {
                'id_lote': row.id_lote,
                'codigo_lote': row.codigo_lote,
                'fecha_cosecha': self._formatear_fecha(row.fecha_cosecha),
                'cantidad_cosechada': float(row.cantidad_cosechada),
                'unidad_medida': row.unidad_medida,
                'precio_unitario_sugerido': float(row.precio_unitario_sugerido) if row.precio_unitario_sugerido else 0.0,
                'tipo_cultivo': row.tipo_cultivo,
                'variedad': row.variedad,
                'categoria_calidad': row.categoria_calidad,
                'producto_completo': f"{row.tipo_cultivo} - {row.variedad} ({row.categoria_calidad})"
            }
            lotes.append(lote)
        
        logger.info(f"Se obtuvieron {len(lotes)} lotes disponibles")
        return lotes

    # ==================== MÉTODOS DE ESCRITURA CON INVALIDACIÓN OPTIMIZADA ====================

    @cache_invalidator('detalles_venta', pattern='venta_')   # Invalidar detalles por venta
    @cache_invalidator('detalles_venta', pattern='id_')      # Invalidar detalles específicos
    @cache_invalidator('ventas', pattern='id_')              # Invalidar caché de ventas
    @cache_invalidator('lotes_venta', key='disponibles')     # Invalidar lotes disponibles
    def crear(self, detalle_data):
        """
        Agrega un nuevo detalle a una venta existente.
        
        Args:
            detalle_data (dict): Datos del detalle a agregar.
            
        Returns:
            tuple: (True, id_detalle_venta) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        self._validar_datos_detalle(detalle_data)
        
        # Verificar que la venta existe
        venta_count = self._contar_registros("Ventas", "id_venta = ?", (detalle_data['id_venta'],))
        if venta_count == 0:
            raise ErrorValidacion(f"La venta con ID {detalle_data['id_venta']} no existe")
        
        # Verificar que el lote existe y está disponible
        lote_count = self._contar_registros("LotesCosecha", "id_lote = ? AND activo = 1", (detalle_data['id_lote'],))
        if lote_count == 0:
            raise ErrorValidacion(f"El lote con ID {detalle_data['id_lote']} no existe o no está activo")
        
        # Insertar detalle de venta
        query = """
        INSERT INTO DetallesVenta (id_venta, id_lote, cantidad, unidad_medida, 
                                precio_unitario, subtotal, total, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        valores = (
            detalle_data['id_venta'],
            detalle_data['id_lote'],
            detalle_data['cantidad'],
            detalle_data['unidad_medida'],
            detalle_data['precio_unitario'],
            detalle_data['subtotal'],
            detalle_data['total'],
            detalle_data.get('observaciones')
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)
        id_detalle_venta = self._obtener_ultimo_id()
        
        # Actualizar totales de la venta
        self._actualizar_totales_venta(detalle_data['id_venta'])
        
        logger.info(f"Detalle de venta creado con ID: {id_detalle_venta}")
        return True, id_detalle_venta

    @cache_invalidator('detalles_venta', pattern='venta_')   # Invalidar detalles por venta
    @cache_invalidator('detalles_venta', pattern='id_')      # Invalidar detalles específicos
    @cache_invalidator('ventas', pattern='id_')              # Invalidar caché de ventas
    @cache_invalidator('lotes_venta', key='disponibles')     # Invalidar lotes disponibles
    def actualizar(self, id_detalle_venta, detalle_data):
        """
        Actualiza un detalle de venta existente y recalcula los totales.
        
        Args:
            id_detalle_venta (int): ID del detalle de venta a actualizar.
            detalle_data (dict): Datos actualizados del detalle.
            
        Returns:
            bool: True si se actualizó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el detalle no existe.
        """
        # Obtener información del detalle actual
        detalle_actual = self.obtener_por_id(id_detalle_venta)
        id_venta = detalle_actual['id_venta']
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        if 'id_lote' in detalle_data:
            # Verificar que el nuevo lote existe
            lote_count = self._contar_registros("LotesCosecha", "id_lote = ? AND activo = 1", (detalle_data['id_lote'],))
            if lote_count == 0:
                raise ErrorValidacion(f"El lote con ID {detalle_data['id_lote']} no existe o no está activo")
            campos_actualizar.append("id_lote = ?")
            valores.append(detalle_data['id_lote'])
        
        if 'cantidad' in detalle_data:
            campos_actualizar.append("cantidad = ?")
            valores.append(detalle_data['cantidad'])
        
        if 'unidad_medida' in detalle_data:
            campos_actualizar.append("unidad_medida = ?")
            valores.append(detalle_data['unidad_medida'])
        
        if 'precio_unitario' in detalle_data:
            campos_actualizar.append("precio_unitario = ?")
            valores.append(detalle_data['precio_unitario'])
        
        if 'subtotal' in detalle_data:
            campos_actualizar.append("subtotal = ?")
            valores.append(detalle_data['subtotal'])
        
        if 'total' in detalle_data:
            campos_actualizar.append("total = ?")
            valores.append(detalle_data['total'])
        
        if 'observaciones' in detalle_data:
            campos_actualizar.append("observaciones = ?")
            valores.append(detalle_data['observaciones'])
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar en el detalle")
            return True
        
        query = f"UPDATE DetallesVenta SET {', '.join(campos_actualizar)} WHERE id_detalle_venta = ?"
        valores.append(id_detalle_venta)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        # Actualizar totales de la venta
        self._actualizar_totales_venta(id_venta)
        
        logger.info(f"Detalle de venta {id_detalle_venta} actualizado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('detalles_venta', pattern='venta_')   # Invalidar detalles por venta
    @cache_invalidator('detalles_venta', pattern='id_')      # Invalidar detalles específicos
    @cache_invalidator('ventas', pattern='id_')              # Invalidar caché de ventas
    @cache_invalidator('lotes_venta', key='disponibles')     # Invalidar lotes disponibles
    def desactivar(self, id_detalle_venta):
        """
        Elimina un detalle de venta y actualiza los totales de la venta.
        
        Args:
            id_detalle_venta (int): ID del detalle de venta a eliminar.
            
        Returns:
            bool: True si se eliminó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si el detalle no existe.
        """
        # Obtener información del detalle antes de eliminarlo
        detalle = self.obtener_por_id(id_detalle_venta)
        id_venta = detalle['id_venta']
        
        # Eliminar el detalle de venta
        query = "DELETE FROM DetallesVenta WHERE id_detalle_venta = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_detalle_venta,), obtener_resultado=False)
        
        # Actualizar totales de la venta
        self._actualizar_totales_venta(id_venta)
        
        logger.info(f"Detalle de venta {id_detalle_venta} eliminado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    def eliminar_por_venta(self, id_venta):
        """
        Elimina todos los detalles de una venta específica.
        
        Args:
            id_venta (int): ID de la venta.
            
        Returns:
            int: Número de detalles eliminados.
        """
        query = "DELETE FROM DetallesVenta WHERE id_venta = ?"
        filas_afectadas = self._ejecutar_consulta(query, (id_venta,), obtener_resultado=False)
        
        logger.info(f"Eliminados {filas_afectadas} detalles de la venta {id_venta}")
        return filas_afectadas

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _validar_datos_detalle(self, datos):
        """
        Valida los datos del detalle de venta.
        
        Args:
            datos (dict): Datos a validar.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        if not datos.get('id_venta'):
            raise ErrorValidacion("El ID de la venta es obligatorio")
        
        if not datos.get('id_lote'):
            raise ErrorValidacion("El ID del lote es obligatorio")
        
        if not datos.get('cantidad') or float(datos['cantidad']) <= 0:
            raise ErrorValidacion("La cantidad debe ser mayor que cero")
        
        if not datos.get('precio_unitario') or float(datos['precio_unitario']) <= 0:
            raise ErrorValidacion("El precio unitario debe ser mayor que cero")
        
        if not datos.get('unidad_medida'):
            raise ErrorValidacion("La unidad de medida es obligatoria")
    
    def _actualizar_totales_venta(self, id_venta):
        """
        Actualiza los totales (subtotal y total) de una venta basado en sus detalles.
        
        Args:
            id_venta (int): ID de la venta a actualizar.
        """
        # Calcular nuevos totales
        query_totales = """
        SELECT COALESCE(SUM(subtotal), 0) AS nuevo_subtotal, 
               COALESCE(SUM(total), 0) AS nuevo_total 
        FROM DetallesVenta 
        WHERE id_venta = ?
        """
        
        row = self._ejecutar_consulta(query_totales, (id_venta,))[0]
        nuevo_subtotal = float(row.nuevo_subtotal)
        nuevo_total = float(row.nuevo_total)
        
        # Actualizar la venta
        query_actualizar = """
        UPDATE Ventas 
        SET subtotal = ?, total = ?
        WHERE id_venta = ?
        """
        
        self._ejecutar_consulta(query_actualizar, (nuevo_subtotal, nuevo_total, id_venta), obtener_resultado=False)
        
        logger.info(f"Totales de venta {id_venta} actualizados: subtotal={nuevo_subtotal}, total={nuevo_total}")
    
    def obtener_totales_venta(self, id_venta):
        """
        Obtiene los totales calculados de una venta basado en sus detalles.
        
        Args:
            id_venta (int): ID de la venta.
            
        Returns:
            dict: Totales calculados (subtotal, total, cantidad_items).
        """
        query = """
        SELECT COUNT(*) AS cantidad_items,
               COALESCE(SUM(subtotal), 0) AS subtotal_calculado,
               COALESCE(SUM(total), 0) AS total_calculado,
               COALESCE(SUM(cantidad), 0) AS cantidad_total
        FROM DetallesVenta 
        WHERE id_venta = ?
        """
        
        row = self._ejecutar_consulta(query, (id_venta,))[0]
        
        return {
            'cantidad_items': row.cantidad_items,
            'subtotal_calculado': float(row.subtotal_calculado),
            'total_calculado': float(row.total_calculado),
            'cantidad_total': float(row.cantidad_total)
        }