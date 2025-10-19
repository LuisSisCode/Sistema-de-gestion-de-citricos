# bd_conecciones/repositorio/ClientesVentasRep/venta_repositorio.py

import logging
from datetime import datetime, date
from ...core.repositorio_base import RepositorioBase
from ...core.excepciones_bd import RegistroNoEncontrado, RegistroYaExiste, ErrorValidacion
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class VentaRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de ventas con caché optimizado."""

    @cacheable('ventas', key_func=lambda: 'todas_activas', ttl=600)  # 10 min - datos dinámicos
    def obtener_todos(self):
        """
        Obtiene todas las ventas de la base de datos con información de cliente, estado y primer detalle.
        
        Returns:
            list: Lista de diccionarios con la información de cada venta.
        """
        query = """
        SELECT v.id_venta, v.id_cliente, c.nombre AS cliente_nombre, v.codigo_venta, 
            v.fecha_venta, v.subtotal, v.total, v.condiciones_pago, v.fecha_entrega, 
            v.lugar_entrega, v.id_estado, e.nombre AS estado_nombre, v.estado_pago,
            u.nombre AS registrado_por_nombre, v.observaciones,
            -- Datos del primer detalle de la venta (o NULL si no hay detalles)
            (SELECT TOP 1 dv.cantidad FROM DetallesVenta dv WHERE dv.id_venta = v.id_venta) AS cantidad,
            (SELECT TOP 1 dv.precio_unitario FROM DetallesVenta dv WHERE dv.id_venta = v.id_venta) AS precio_unitario
        FROM Ventas v
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        JOIN EstadosVenta e ON v.id_estado = e.id_estado
        JOIN Usuarios u ON v.registrado_por = u.id_usuario
        ORDER BY v.fecha_venta DESC
        """
        
        rows = self._ejecutar_consulta(query)
        ventas = []
        
        for row in rows:
            venta = {
                'id_venta': row.id_venta,
                'id_cliente': row.id_cliente,
                'cliente_nombre': row.cliente_nombre,
                'codigo_venta': row.codigo_venta,
                'fecha_venta': self._formatear_fecha(row.fecha_venta),
                'subtotal': float(row.subtotal) if row.subtotal else 0.0,
                'total': float(row.total) if row.total else 0.0,
                'condiciones_pago': row.condiciones_pago or '',
                'fecha_entrega': self._formatear_fecha(row.fecha_entrega),
                'lugar_entrega': row.lugar_entrega or "",
                'id_estado': row.id_estado,
                'estado_nombre': row.estado_nombre,
                'estado_pago': row.estado_pago,
                'registrado_por': row.registrado_por_nombre,
                'observaciones': row.observaciones or "",
                'cantidad': float(row.cantidad) if row.cantidad else 0.0,
                'precio_unitario': float(row.precio_unitario) if row.precio_unitario else 0.0,
            }
            ventas.append(venta)
        
        logger.info(f"Se obtuvieron {len(ventas)} ventas")
        return ventas

    @cacheable('ventas', key_func=lambda id_venta: f"id_{id_venta}", ttl=1800)  # 30 min
    def obtener_por_id(self, id_venta):
        """
        Obtiene una venta específica por su ID con todos sus detalles.
        
        Args:
            id_venta (int): ID de la venta a obtener.
            
        Returns:
            dict: Diccionario con la información de la venta o None si no se encuentra.
            
        Raises:
            RegistroNoEncontrado: Si la venta no existe.
        """
        # Consulta para obtener la información general de la venta
        query_venta = """
        SELECT v.id_venta, v.id_cliente, c.nombre AS cliente_nombre, v.codigo_venta, 
               v.fecha_venta, v.subtotal, v.total, v.condiciones_pago, v.fecha_entrega, 
               v.lugar_entrega, v.id_estado, e.nombre AS estado_nombre, v.estado_pago,
               u.nombre AS registrado_por_nombre, v.observaciones
        FROM Ventas v
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        JOIN EstadosVenta e ON v.id_estado = e.id_estado
        JOIN Usuarios u ON v.registrado_por = u.id_usuario
        WHERE v.id_venta = ?
        """
        
        rows = self._ejecutar_consulta(query_venta, (id_venta,))
        
        if not rows:
            raise RegistroNoEncontrado(f"Venta con ID {id_venta} no encontrada")
        
        row_venta = rows[0]
        
        venta = {
            'id_venta': row_venta.id_venta,
            'id_cliente': row_venta.id_cliente,
            'cliente_nombre': row_venta.cliente_nombre,
            'codigo_venta': row_venta.codigo_venta,
            'fecha_venta': self._formatear_fecha(row_venta.fecha_venta),
            'subtotal': float(row_venta.subtotal),
            'total': float(row_venta.total),
            'condiciones_pago': row_venta.condiciones_pago,
            'fecha_entrega': self._formatear_fecha(row_venta.fecha_entrega),
            'lugar_entrega': row_venta.lugar_entrega,
            'id_estado': row_venta.id_estado,
            'estado_nombre': row_venta.estado_nombre,
            'estado_pago': row_venta.estado_pago,
            'registrado_por': row_venta.registrado_por_nombre,
            'observaciones': row_venta.observaciones,
            'detalles': []
        }
        
        # Consulta para obtener los detalles de la venta
        query_detalles = """
        SELECT dv.id_detalle_venta, dv.id_lote,
               vc.nombre AS variedad, tc.nombre AS tipo_cultivo,
               dv.cantidad, dv.unidad_medida, dv.precio_unitario, 
               dv.subtotal, dv.total, dv.observaciones
        FROM DetallesVenta dv
        JOIN LotesCosecha lc ON dv.id_lote = lc.id_lote
        JOIN CiclosProduccion cp ON lc.id_ciclo = cp.id_ciclo
        JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
        JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
        WHERE dv.id_venta = ?
        """
        
        detalle_rows = self._ejecutar_consulta(query_detalles, (id_venta,))
        
        for detalle_row in detalle_rows:
            detalle = {
                'id_detalle_venta': detalle_row.id_detalle_venta,
                'id_lote': detalle_row.id_lote,
                'tipo_cultivo': detalle_row.tipo_cultivo,
                'variedad': detalle_row.variedad,
                'cantidad': float(detalle_row.cantidad),
                'unidad_medida': detalle_row.unidad_medida,
                'precio_unitario': float(detalle_row.precio_unitario),
                'subtotal': float(detalle_row.subtotal),
                'total': float(detalle_row.total),
                'observaciones': detalle_row.observaciones,
                'producto_completo': f"{detalle_row.tipo_cultivo} - {detalle_row.variedad}"
            }
            venta['detalles'].append(detalle)
        
        return venta

    @cacheable('ventas', key_func=lambda pagina, por_pagina=10: f"pagina_{pagina}_{por_pagina}", ttl=600)  # 10 min
    def obtener_paginado(self, pagina, por_pagina=10):
        """
        Obtiene ventas con paginación.
        
        Args:
            pagina (int): Número de página.
            por_pagina (int): Registros por página.
            
        Returns:
            dict: Ventas, total_registros, total_paginas, pagina_actual.
        """
        pagina, por_pagina, offset = self._validar_parametros_paginacion(pagina, por_pagina)
        
        # Contar total de registros
        total_registros = self._contar_registros("Ventas")
        
        # Obtener registros paginados
        query = """
        SELECT v.id_venta, v.id_cliente, c.nombre AS cliente_nombre, v.codigo_venta, 
               v.fecha_venta, v.total, v.estado_pago, e.nombre AS estado_nombre
        FROM Ventas v
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        JOIN EstadosVenta e ON v.id_estado = e.id_estado
        ORDER BY v.fecha_venta DESC
        OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
        """
        
        rows = self._ejecutar_consulta(query, (offset, por_pagina))
        ventas = []
        
        for row in rows:
            venta = {
                'id_venta': row.id_venta,
                'id_cliente': row.id_cliente,
                'cliente_nombre': row.cliente_nombre,
                'codigo_venta': row.codigo_venta,
                'fecha_venta': self._formatear_fecha(row.fecha_venta),
                'total': float(row.total),
                'estado_pago': row.estado_pago,
                'estado_nombre': row.estado_nombre
            }
            ventas.append(venta)
        
        total_paginas = self._calcular_total_paginas(total_registros, por_pagina)
        
        resultado = {
            'ventas': ventas,
            'total_registros': total_registros,
            'total_paginas': total_paginas,
            'pagina_actual': pagina
        }
        
        logger.info(f"Página {pagina}: {len(ventas)} ventas de {total_registros} totales")
        return resultado

    @cacheable('variedades_venta', key_func=lambda: 'disponibles', ttl=1200)  # 20 min
    def obtener_variedades_disponibles(self):
        """
        Obtiene las variedades de cultivo disponibles para venta.
        
        Returns:
            list: Lista de diccionarios con la información de cada variedad disponible.
        """
        query = """
        SELECT v.id_variedad, v.nombre AS variedad, 
            tc.id_tipo_cultivo, tc.nombre AS tipo_cultivo,
            v.activo
        FROM VariedadesCultivo v
        JOIN TiposCultivo tc ON v.id_tipo_cultivo = tc.id_tipo_cultivo
        WHERE v.activo = 1
        ORDER BY tc.nombre, v.nombre
        """
        
        rows = self._ejecutar_consulta(query)
        variedades = []
        
        for row in rows:
            variedad = {
                'id_variedad': row.id_variedad,
                'variedad': row.variedad,
                'id_tipo_cultivo': row.id_tipo_cultivo,
                'tipo_cultivo': row.tipo_cultivo,
                'activo': bool(row.activo),
                'producto_completo': f"{row.tipo_cultivo} - {row.variedad}"
            }
            variedades.append(variedad)
        
        logger.info(f"Se obtuvieron {len(variedades)} variedades disponibles")
        return variedades

    def buscar_por_rango_monto(self, monto_min, monto_max):
        """
        Busca ventas dentro de un rango de montos.
        
        Args:
            monto_min (float): Monto mínimo a buscar.
            monto_max (float): Monto máximo a buscar.
            
        Returns:
            list: Lista de diccionarios con las ventas encontradas.
        """
        query = """
        SELECT v.id_venta, v.id_cliente, c.nombre AS cliente_nombre, v.codigo_venta, 
               v.fecha_venta, v.total, v.estado_pago, e.nombre AS estado_nombre
        FROM Ventas v
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        JOIN EstadosVenta e ON v.id_estado = e.id_estado
        WHERE v.total BETWEEN ? AND ?
        ORDER BY v.total DESC
        """
        
        rows = self._ejecutar_consulta(query, (monto_min, monto_max))
        ventas = []
        
        for row in rows:
            venta = {
                'id_venta': row.id_venta,
                'id_cliente': row.id_cliente,
                'cliente_nombre': row.cliente_nombre,
                'codigo_venta': row.codigo_venta,
                'fecha_venta': self._formatear_fecha(row.fecha_venta),
                'total': float(row.total),
                'estado_pago': row.estado_pago,
                'estado_nombre': row.estado_nombre
            }
            ventas.append(venta)
        
        logger.info(f"Se encontraron {len(ventas)} ventas en el rango de montos especificado")
        return ventas

    # ==================== MÉTODOS DE ESCRITURA CON INVALIDACIÓN OPTIMIZADA ====================

    @cache_invalidator('ventas', key='todas_activas')    # Invalidar lista completa
    @cache_invalidator('ventas', pattern='pagina_')      # Invalidar paginación
    @cache_invalidator('variedades_venta', key='disponibles')  # Invalidar variedades
    def crear(self, venta_data, detalles_data):
        """
        Crea una nueva venta con sus detalles.
        OPTIMIZADO: Invalidación granular por tipos de caché.
        
        Args:
            venta_data (dict): Datos de la venta.
            detalles_data (list): Lista de detalles de la venta.
            
        Returns:
            tuple: (True, id_venta) si fue exitoso.
            
        Raises:
            ErrorValidacion: Si los datos no son válidos.
        """
        self._validar_datos_venta(venta_data, detalles_data)
        
        # Verificar que el cliente existe
        cliente_count = self._contar_registros("Clientes", "id_cliente = ? AND activo = 1", (venta_data['id_cliente'],))
        if cliente_count == 0:
            raise ErrorValidacion(f"El cliente con ID {venta_data['id_cliente']} no existe")
        
        # Verificar que el código de venta no existe
        if self._existe_codigo_venta(venta_data['codigo_venta']):
            raise RegistroYaExiste(f"Ya existe una venta con código {venta_data['codigo_venta']}")
        
        try:
            # Insertar venta principal
            query_venta = """
            INSERT INTO Ventas (id_cliente, codigo_venta, fecha_venta, subtotal, total, 
                            condiciones_pago, fecha_entrega, lugar_entrega, id_estado, 
                            estado_pago, registrado_por, observaciones)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
            
            fecha_venta = datetime.now().strftime('%Y-%m-%d') if 'fecha_venta' not in venta_data else venta_data['fecha_venta']
            
            valores_venta = (
                venta_data['id_cliente'],
                venta_data['codigo_venta'],
                fecha_venta,
                float(venta_data['subtotal']) if venta_data['subtotal'] is not None else 0.0,
                float(venta_data['total']) if venta_data['total'] is not None else 0.0,
                venta_data.get('condiciones_pago', ''),
                venta_data.get('fecha_entrega'),
                venta_data.get('lugar_entrega', ''),
                venta_data['id_estado'],
                venta_data.get('estado_pago', 'Pendiente'),
                venta_data['registrado_por'],
                venta_data.get('observaciones', '')
            )
            
            self._ejecutar_consulta(query_venta, valores_venta, obtener_resultado=False)
            id_venta = self._obtener_ultimo_id()
            
            # Insertar detalles de la venta
            for detalle in detalles_data:
                self._insertar_detalle_venta(id_venta, detalle)
            
            logger.info(f"Venta creada con ID: {id_venta}")
            return True, id_venta
            
        except Exception as e:
            logger.error(f"Error al crear venta: {str(e)}")
            raise

    @cache_invalidator('ventas', pattern='id_')          # Invalidar caché específico
    @cache_invalidator('ventas', key='todas_activas')    # Invalidar lista completa
    @cache_invalidator('ventas', pattern='pagina_')      # Invalidar paginación
    def actualizar(self, id_venta, venta_data):
        """
        Actualiza una venta existente.
        
        Args:
            id_venta (int): ID de la venta.
            venta_data (dict): Datos actualizados.
            
        Returns:
            bool: True si se actualizó correctamente.
            
        Raises:
            RegistroNoEncontrado: Si la venta no existe.
        """
        # Verificar que la venta existe
        self.obtener_por_id(id_venta)
        
        # Construir consulta dinámicamente
        campos_actualizar = []
        valores = []
        
        if 'id_cliente' in venta_data:
            campos_actualizar.append("id_cliente = ?")
            valores.append(venta_data['id_cliente'])
            
        if 'fecha_venta' in venta_data:
            campos_actualizar.append("fecha_venta = ?")
            valores.append(venta_data['fecha_venta'])
            
        if 'subtotal' in venta_data:
            campos_actualizar.append("subtotal = ?")
            valores.append(venta_data['subtotal'])
            
        if 'total' in venta_data:
            campos_actualizar.append("total = ?")
            valores.append(venta_data['total'])
            
        if 'condiciones_pago' in venta_data:
            campos_actualizar.append("condiciones_pago = ?")
            valores.append(venta_data['condiciones_pago'])
            
        if 'fecha_entrega' in venta_data:
            campos_actualizar.append("fecha_entrega = ?")
            valores.append(venta_data['fecha_entrega'])
            
        if 'lugar_entrega' in venta_data:
            campos_actualizar.append("lugar_entrega = ?")
            valores.append(venta_data['lugar_entrega'])
            
        if 'id_estado' in venta_data:
            campos_actualizar.append("id_estado = ?")
            valores.append(venta_data['id_estado'])
            
        if 'estado_pago' in venta_data:
            campos_actualizar.append("estado_pago = ?")
            valores.append(venta_data['estado_pago'])
            
        if 'observaciones' in venta_data:
            campos_actualizar.append("observaciones = ?")
            valores.append(venta_data['observaciones'])
        
        if not campos_actualizar:
            logger.warning("No hay campos para actualizar")
            return False
        
        query = f"UPDATE Ventas SET {', '.join(campos_actualizar)} WHERE id_venta = ?"
        valores.append(id_venta)
        
        filas_afectadas = self._ejecutar_consulta(query, valores, obtener_resultado=False)
        
        logger.info(f"Venta {id_venta} actualizada. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('ventas', pattern='id_')          # Invalidar caché específico
    @cache_invalidator('ventas', key='todas_activas')    # Invalidar lista completa
    def cambiar_estado_venta(self, id_venta, nuevo_estado_id):
        """
        Actualiza el estado de una venta.
        
        Args:
            id_venta (int): ID de la venta.
            nuevo_estado_id (int): ID del nuevo estado.
            
        Returns:
            bool: True si se actualizó correctamente.
        """
        query = "UPDATE Ventas SET id_estado = ? WHERE id_venta = ?"
        filas_afectadas = self._ejecutar_consulta(query, (nuevo_estado_id, id_venta), obtener_resultado=False)
        
        logger.info(f"Estado de venta {id_venta} actualizado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('ventas', pattern='id_')          # Invalidar caché específico
    @cache_invalidator('ventas', key='todas_activas')    # Invalidar lista completa
    def cambiar_estado_pago(self, id_venta, nuevo_estado_pago):
        """
        Actualiza el estado de pago de una venta.
        
        Args:
            id_venta (int): ID de la venta.
            nuevo_estado_pago (str): Nuevo estado de pago.
            
        Returns:
            bool: True si se actualizó correctamente.
        """
        # Verificar que el estado es válido
        if nuevo_estado_pago not in ['Pendiente', 'Parcial', 'Pagado']:
            raise ErrorValidacion(f"Estado de pago inválido: {nuevo_estado_pago}")
        
        query = "UPDATE Ventas SET estado_pago = ? WHERE id_venta = ?"
        filas_afectadas = self._ejecutar_consulta(query, (nuevo_estado_pago, id_venta), obtener_resultado=False)
        
        logger.info(f"Estado de pago de venta {id_venta} actualizado. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('ventas', key='todas_activas')    # Invalidar lista completa
    @cache_invalidator('ventas', pattern='pagina_')      # Invalidar paginación
    def cancelar_venta(self, id_venta, motivo_cancelacion):
        """
        Cancela una venta.
        
        Args:
            id_venta (int): ID de la venta.
            motivo_cancelacion (str): Motivo de cancelación.
            
        Returns:
            bool: True si se canceló correctamente.
        """
        # Obtener ID del estado "Cancelado"
        estado_cancelado = self._ejecutar_consulta_escalar(
            "SELECT id_estado FROM EstadosVenta WHERE nombre = 'Cancelado'"
        )
        
        if not estado_cancelado:
            raise ErrorValidacion("No se encontró el estado 'Cancelado'")
        
        observaciones = f"CANCELADO: {motivo_cancelacion}"
        query = """
        UPDATE Ventas
        SET id_estado = ?, observaciones = ?
        WHERE id_venta = ?
        """
        
        filas_afectadas = self._ejecutar_consulta(query, (estado_cancelado, observaciones, id_venta), obtener_resultado=False)
        
        logger.info(f"Venta {id_venta} cancelada. Filas afectadas: {filas_afectadas}")
        return filas_afectadas > 0

    @cache_invalidator('ventas', key='todas_activas')    # Invalidar lista completa
    @cache_invalidator('ventas', pattern='pagina_')      # Invalidar paginación
    def duplicar_venta(self, id_venta, nuevo_codigo=None, nueva_fecha=None):
        """
        Duplica una venta existente con todos sus detalles.
        
        Args:
            id_venta (int): ID de la venta a duplicar.
            nuevo_codigo (str): Código para la nueva venta.
            nueva_fecha (str): Fecha para la nueva venta.
            
        Returns:
            tuple: (True, nueva_venta_id) si fue exitoso.
        """
        # Obtener datos de la venta original
        venta_original = self.obtener_por_id(id_venta)
        
        # Generar nuevo código si no se proporcionó
        if not nuevo_codigo:
            nuevo_codigo = self.generar_codigo_venta()
        
        # Establecer nueva fecha
        if nueva_fecha:
            fecha_nueva_venta = nueva_fecha
        else:
            fecha_nueva_venta = datetime.now().strftime('%Y-%m-%d')
        
        # Obtener ID del estado inicial
        estado_inicial = self._ejecutar_consulta_escalar(
            "SELECT TOP 1 id_estado FROM EstadosVenta WHERE activo = 1"
        )
        
        # Crear nueva venta
        venta_data = {
            'id_cliente': venta_original['id_cliente'],
            'codigo_venta': nuevo_codigo,
            'fecha_venta': fecha_nueva_venta,
            'subtotal': 0,
            'total': 0,
            'condiciones_pago': venta_original['condiciones_pago'],
            'lugar_entrega': venta_original['lugar_entrega'],
            'id_estado': estado_inicial,
            'estado_pago': 'Pendiente',
            'registrado_por': venta_original.get('registrado_por', 1),
            'observaciones': f"Duplicado de venta #{id_venta}"
        }
        
        # Duplicar detalles
        detalles_data = []
        for detalle in venta_original['detalles']:
            nuevo_detalle = {
                'id_lote': detalle['id_lote'],
                'cantidad': detalle['cantidad'],
                'unidad_medida': detalle['unidad_medida'],
                'precio_unitario': detalle['precio_unitario'],
                'subtotal': detalle['subtotal'],
                'total': detalle['total'],
                'observaciones': detalle['observaciones']
            }
            detalles_data.append(nuevo_detalle)
        
        # Calcular totales
        subtotal_total = sum(d['subtotal'] for d in detalles_data)
        total_final = sum(d['total'] for d in detalles_data)
        
        venta_data['subtotal'] = subtotal_total
        venta_data['total'] = total_final
        
        success, nueva_venta_id = self.crear(venta_data, detalles_data)
        
        logger.info(f"Venta duplicada correctamente con ID: {nueva_venta_id}")
        return success, nueva_venta_id

    def generar_codigo_venta(self):
        """
        Genera un código único para una nueva venta.
        
        Returns:
            str: Código generado para la venta.
        """
        # Consultar el último código
        ultimo_codigo = self._ejecutar_consulta_escalar("""
            SELECT TOP 1 codigo_venta 
            FROM Ventas 
            WHERE codigo_venta LIKE 'V-%'
            ORDER BY id_venta DESC
        """)
        
        if ultimo_codigo:
            try:
                numero_str = ultimo_codigo.replace("V-", "")
                if "-" in numero_str:
                    numero_str = numero_str.split("-")[-1]
                numero = int(numero_str)
                nuevo_numero = numero + 1
            except (ValueError, IndexError):
                nuevo_numero = 1
        else:
            nuevo_numero = 1
        
        nuevo_codigo = f"V-{nuevo_numero:04d}"
        return nuevo_codigo

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _validar_datos_venta(self, venta_data, detalles_data):
        """Valida los datos de la venta."""
        if not venta_data.get('id_cliente'):
            raise ErrorValidacion("El ID del cliente es obligatorio")
        
        if not venta_data.get('codigo_venta'):
            raise ErrorValidacion("El código de venta es obligatorio")
        
        if not venta_data.get('registrado_por'):
            raise ErrorValidacion("El campo registrado_por es obligatorio")
        
        if not detalles_data or len(detalles_data) == 0:
            raise ErrorValidacion("La venta debe tener al menos un detalle")
        
        for i, detalle in enumerate(detalles_data):
            if not detalle.get('id_lote'):
                raise ErrorValidacion(f"Detalle #{i+1}: ID de lote es obligatorio")
            
            if not detalle.get('cantidad') or float(detalle['cantidad']) <= 0:
                raise ErrorValidacion(f"Detalle #{i+1}: Cantidad debe ser mayor que cero")
    
    def _existe_codigo_venta(self, codigo_venta):
        """Verifica si un código de venta ya existe."""
        count = self._contar_registros("Ventas", "codigo_venta = ?", (codigo_venta,))
        return count > 0
    
    def _insertar_detalle_venta(self, id_venta, detalle_data):
        """Inserta un detalle de venta."""
        query = """
        INSERT INTO DetallesVenta (id_venta, id_lote, cantidad, unidad_medida, 
                                precio_unitario, subtotal, total, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        valores = (
            id_venta,
            detalle_data['id_lote'],
            detalle_data['cantidad'],
            detalle_data['unidad_medida'],
            detalle_data['precio_unitario'],
            detalle_data['subtotal'],
            detalle_data['total'],
            detalle_data.get('observaciones')
        )
        
        self._ejecutar_consulta(query, valores, obtener_resultado=False)