# bd_conecciones/repositorio/ClientesVentasRep/relacion_cliente_venta_repositorio.py

import logging
from datetime import datetime, timedelta
from ...core.repositorio_base import RepositorioBase
from ...core.excepciones_bd import RegistroNoEncontrado, ErrorValidacion
from ...core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)

class RelacionClienteVentaRepositorio(RepositorioBase):
    """Repositorio para consultas complejas y relaciones entre clientes y ventas."""

    # ==================== MÉTODOS ABSTRACTOS IMPLEMENTADOS ====================
    
    def obtener_todos(self):
        """No aplicable para RelacionClienteVentaRepositorio."""
        return []
    
    def obtener_por_id(self, id_registro):
        """No aplicable para RelacionClienteVentaRepositorio."""
        return {}
    
    def crear(self, datos):
        """No aplicable para RelacionClienteVentaRepositorio."""
        return True, None
    
    def actualizar(self, id_registro, datos):
        """No aplicable para RelacionClienteVentaRepositorio."""
        return True
    
    def desactivar(self, id_registro):
        """No aplicable para RelacionClienteVentaRepositorio."""
        return True

    # ==================== MÉTODOS REALES DE RELACIONES ====================

    @cacheable('pagos_pendientes', key_func=lambda: 'lista_completa', ttl=300)  # 5 min - datos dinámicos
    def obtener_pagos_pendientes(self):
        """
        Obtiene un resumen de los pagos pendientes.
        
        Returns:
            list: Lista de diccionarios con información de ventas con pagos pendientes.
        """
        query = """
        SELECT v.id_venta, v.codigo_venta, v.fecha_venta, 
            c.id_cliente, c.nombre AS cliente_nombre,
            v.total, v.estado_pago, v.condiciones_pago
        FROM Ventas v
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        WHERE v.estado_pago IN ('Pendiente', 'Parcial')
        ORDER BY v.fecha_venta
        """
        
        rows = self._ejecutar_consulta(query)
        pagos_pendientes = []
        
        for row in rows:
            pago = {
                'id_venta': row.id_venta,
                'codigo_venta': row.codigo_venta,
                'fecha_venta': self._formatear_fecha(row.fecha_venta),
                'id_cliente': row.id_cliente,
                'cliente_nombre': row.cliente_nombre,
                'total': float(row.total),
                'estado_pago': row.estado_pago,
                'condiciones_pago': row.condiciones_pago
            }
            pagos_pendientes.append(pago)
        
        logger.info(f"Se obtuvieron {len(pagos_pendientes)} pagos pendientes")
        return pagos_pendientes

    @cacheable('ventas_vencidas', key_func=lambda: 'lista_completa', ttl=300)  # 5 min - datos dinámicos
    def obtener_ventas_vencidas(self):
        """
        Obtiene las ventas con fecha de entrega vencida.
        
        Returns:
            list: Lista de diccionarios con información de ventas vencidas.
        """
        hoy = datetime.now().date()
        hoy_str = hoy.strftime('%Y-%m-%d')
        
        query = """
        SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.fecha_entrega,
            c.id_cliente, c.nombre AS cliente_nombre,
            v.total, v.estado_pago, e.nombre AS estado_nombre
        FROM Ventas v
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        JOIN EstadosVenta e ON v.id_estado = e.id_estado
        WHERE v.fecha_entrega < ?
            AND e.nombre NOT IN ('Entregado', 'Finalizado', 'Cancelado')
        ORDER BY v.fecha_entrega
        """
        
        rows = self._ejecutar_consulta(query, (hoy_str,))
        ventas_vencidas = []
        
        for row in rows:
            venta = {
                'id_venta': row.id_venta,
                'codigo_venta': row.codigo_venta,
                'fecha_venta': self._formatear_fecha(row.fecha_venta),
                'fecha_entrega': self._formatear_fecha(row.fecha_entrega),
                'id_cliente': row.id_cliente,
                'cliente_nombre': row.cliente_nombre,
                'total': float(row.total),
                'estado_pago': row.estado_pago,
                'estado_nombre': row.estado_nombre
            }
            ventas_vencidas.append(venta)
        
        logger.info(f"Se obtuvieron {len(ventas_vencidas)} ventas vencidas")
        return ventas_vencidas

    @cacheable('clientes_clasificados', key_func=lambda: 'por_volumen', ttl=1800)  # 30 min
    def clasificar_clientes_por_volumen(self):
        """
        Clasifica a los clientes por volumen de compras.
        
        Returns:
            list: Lista de diccionarios con los clientes clasificados.
        """
        query = """
        SELECT c.id_cliente, c.nombre, c.telefono, c.correo,
            COUNT(v.id_venta) AS total_ventas,
            COALESCE(SUM(v.total), 0) AS monto_total,
            MAX(v.fecha_venta) AS ultima_compra
        FROM Clientes c
        LEFT JOIN Ventas v ON c.id_cliente = v.id_cliente
        WHERE c.activo = 1
        GROUP BY c.id_cliente, c.nombre, c.telefono, c.correo
        ORDER BY monto_total DESC
        """
        
        rows = self._ejecutar_consulta(query)
        clientes = []
        
        # Determinar categorías de clientes basadas en percentiles
        if len(rows) > 0:
            # Extrae montos totales para calcular percentiles
            montos = [float(row.monto_total) if row.monto_total else 0.0 for row in rows]
            montos.sort()
            
            # Calculamos percentiles para clasificación
            percentil_80 = self._calcular_percentil(montos, 80)
            percentil_50 = self._calcular_percentil(montos, 50)
            percentil_20 = self._calcular_percentil(montos, 20)
            
            for row in rows:
                monto = float(row.monto_total) if row.monto_total else 0.0
                
                # Determinar categoría
                if monto >= percentil_80:
                    categoria = "Premium"
                elif monto >= percentil_50:
                    categoria = "Regular"
                elif monto >= percentil_20:
                    categoria = "Ocasional"
                else:
                    categoria = "Nuevo"
                
                cliente = {
                    'id_cliente': row.id_cliente,
                    'nombre': row.nombre,
                    'telefono': row.telefono,
                    'correo': row.correo,
                    'total_ventas': row.total_ventas or 0,
                    'monto_total': monto,
                    'ultima_compra': self._formatear_fecha(row.ultima_compra),
                    'categoria': categoria
                }
                clientes.append(cliente)
        
        logger.info(f"Clasificación de clientes completada. Total: {len(clientes)}")
        return clientes

    @cacheable('historial_cliente', key_func=lambda id_cli: f"cliente_{id_cli}", ttl=900)  # 15 min
    def obtener_historial_compras_cliente(self, id_cliente):
        """
        Obtiene el historial de compras de un cliente específico.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            dict: Diccionario con el historial de compras y estadísticas.
        """
        # Obtener información básica del cliente
        query_cliente = """
        SELECT nombre, fecha_registro
        FROM Clientes
        WHERE id_cliente = ? AND activo = 1
        """
        
        cliente_rows = self._ejecutar_consulta(query_cliente, (id_cliente,))
        
        if not cliente_rows:
            raise RegistroNoEncontrado(f"Cliente con ID {id_cliente} no encontrado")
        
        row_cliente = cliente_rows[0]
        
        # Obtener todas las ventas del cliente
        query_ventas = """
        SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.subtotal, v.total,
               v.condiciones_pago, v.estado_pago, e.nombre AS estado_nombre,
               (SELECT COUNT(*) FROM DetallesVenta WHERE id_venta = v.id_venta) AS total_productos
        FROM Ventas v
        JOIN EstadosVenta e ON v.id_estado = e.id_estado
        WHERE v.id_cliente = ?
        ORDER BY v.fecha_venta DESC
        """
        
        ventas_rows = self._ejecutar_consulta(query_ventas, (id_cliente,))
        
        ventas = []
        total_ventas = 0
        total_gastado = 0
        
        for row in ventas_rows:
            venta = {
                'id_venta': row.id_venta,
                'codigo_venta': row.codigo_venta,
                'fecha_venta': self._formatear_fecha(row.fecha_venta),
                'subtotal': float(row.subtotal),
                'total': float(row.total),
                'condiciones_pago': row.condiciones_pago,
                'estado_pago': row.estado_pago,
                'estado_nombre': row.estado_nombre,
                'total_productos': row.total_productos
            }
            ventas.append(venta)
            
            total_ventas += 1
            total_gastado += float(row.total)
        
        # Obtener productos más comprados por el cliente
        query_productos = """
        SELECT tc.nombre AS tipo_cultivo, vc.nombre AS variedad,
               SUM(dv.cantidad) AS cantidad_total,
               COUNT(DISTINCT v.id_venta) AS frecuencia_compra
        FROM DetallesVenta dv
        JOIN Ventas v ON dv.id_venta = v.id_venta
        JOIN LotesCosecha lc ON dv.id_lote = lc.id_lote
        JOIN CiclosProduccion cp ON lc.id_ciclo = cp.id_ciclo
        JOIN VariedadesCultivo vc ON cp.id_variedad = vc.id_variedad
        JOIN TiposCultivo tc ON vc.id_tipo_cultivo = tc.id_tipo_cultivo
        WHERE v.id_cliente = ?
        GROUP BY tc.nombre, vc.nombre
        ORDER BY cantidad_total DESC
        """
        
        productos_rows = self._ejecutar_consulta(query_productos, (id_cliente,))
        
        productos = []
        for row in productos_rows:
            producto = {
                'tipo_cultivo': row.tipo_cultivo,
                'variedad': row.variedad,
                'cantidad_total': float(row.cantidad_total),
                'frecuencia_compra': row.frecuencia_compra,
                'producto_completo': f"{row.tipo_cultivo} - {row.variedad}"
            }
            productos.append(producto)
        
        # Calcular estadísticas
        promedio_compra = total_gastado / total_ventas if total_ventas > 0 else 0
        fecha_registro = row_cliente.fecha_registro.date() if row_cliente.fecha_registro else datetime.now().date()
        antiguedad_dias = (datetime.now().date() - fecha_registro).days
        
        # Armar el historial completo
        historial = {
            'cliente': {
                'id_cliente': id_cliente,
                'nombre': row_cliente.nombre,
                'fecha_registro': fecha_registro.strftime('%Y-%m-%d'),
                'antiguedad_dias': antiguedad_dias
            },
            'estadisticas': {
                'total_ventas': total_ventas,
                'total_gastado': total_gastado,
                'promedio_compra': promedio_compra,
                'primera_compra': ventas[-1]['fecha_venta'] if ventas else None,
                'ultima_compra': ventas[0]['fecha_venta'] if ventas else None
            },
            'ventas': ventas,
            'productos_favoritos': productos[:5]  # Top 5 productos
        }
        
        return historial

    @cacheable('ventas_cliente', key_func=lambda id_cli: f"ventas_cliente_{id_cli}", ttl=900)  # 15 min
    def obtener_ventas_por_cliente(self, id_cliente):
        """
        Obtiene todas las ventas realizadas a un cliente específico.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            list: Lista de diccionarios con las ventas del cliente.
        """
        query = """
        SELECT v.id_venta, v.codigo_venta, v.fecha_venta, v.subtotal, 
               v.total, v.estado_pago, e.nombre AS estado_nombre
        FROM Ventas v
        JOIN EstadosVenta e ON v.id_estado = e.id_estado
        WHERE v.id_cliente = ?
        ORDER BY v.fecha_venta DESC
        """
        
        rows = self._ejecutar_consulta(query, (id_cliente,))
        ventas = []
        
        for row in rows:
            venta = {
                'id_venta': row.id_venta,
                'codigo_venta': row.codigo_venta,
                'fecha_venta': self._formatear_fecha(row.fecha_venta),
                'subtotal': float(row.subtotal),
                'total': float(row.total),
                'estado_pago': row.estado_pago,
                'estado_nombre': row.estado_nombre
            }
            ventas.append(venta)
        
        logger.info(f"Se obtuvieron {len(ventas)} ventas para el cliente ID: {id_cliente}")
        return ventas

    @cacheable('cliente_top', key_func=lambda: 'mes_actual', ttl=900)  # 15 min
    def obtener_cliente_top(self):
        """
        Obtiene el cliente con mayor volumen de compras en el último mes.
        
        Returns:
            dict: Diccionario con la información del cliente top o None si no hay ventas.
        """
        # Obtener el primer día del mes actual
        hoy = datetime.now().date()
        primer_dia_mes = datetime(hoy.year, hoy.month, 1).date()
        primer_dia_mes_str = primer_dia_mes.strftime('%Y-%m-%d')
        
        query = """
        SELECT TOP 1 c.id_cliente, c.nombre, COUNT(v.id_venta) AS total_ventas, 
            SUM(v.total) AS monto_total,
            (SELECT SUM(total) FROM Ventas 
                WHERE fecha_venta >= ?) AS total_ventas_mes
        FROM Ventas v
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        WHERE v.fecha_venta >= ?
        GROUP BY c.id_cliente, c.nombre
        ORDER BY monto_total DESC
        """
        
        rows = self._ejecutar_consulta(query, (primer_dia_mes_str, primer_dia_mes_str))
        
        if rows and rows[0].monto_total:
            row = rows[0]
            # Calcular el porcentaje del total de ventas
            porcentaje = (float(row.monto_total) / float(row.total_ventas_mes)) * 100 if row.total_ventas_mes else 0
            
            cliente_top = {
                'id_cliente': row.id_cliente,
                'nombre': row.nombre,
                'total_ventas': row.total_ventas,
                'monto_total': float(row.monto_total),
                'porcentaje_ventas': round(porcentaje, 2)
            }
            return cliente_top
        
        return None

    def contar_ventas_por_cliente(self, id_cliente):
        """
        Cuenta las ventas de un cliente específico.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            int: Número de ventas del cliente.
        """
        count = self._contar_registros("Ventas", "id_cliente = ?", (id_cliente,))
        logger.info(f"Cliente {id_cliente} tiene {count} ventas")
        return count

    def verificar_dependencias_cliente(self, id_cliente):
        """
        Verifica todas las dependencias de un cliente antes de eliminarlo.
        
        Args:
            id_cliente (int): ID del cliente.
            
        Returns:
            dict: Información detallada de dependencias.
        """
        # Contar ventas
        ventas = self.contar_ventas_por_cliente(id_cliente)
        
        dependencias = {
            'ventas': ventas,
            'total_dependencias': ventas,
            'puede_eliminar': ventas == 0
        }
        
        if not dependencias['puede_eliminar']:
            logger.info(f"Cliente {id_cliente} no puede eliminarse - tiene {ventas} ventas asociadas")
        else:
            logger.info(f"Cliente {id_cliente} puede ser eliminado - sin dependencias")
        
        return dependencias

    @cacheable('resumen_ventas', key_func=lambda fi, ff: f"periodo_{fi}_{ff}", ttl=600)  # 10 min
    def obtener_resumen_ventas_por_periodo(self, fecha_inicio, fecha_fin):
        """
        Obtiene un resumen de ventas por un período específico.
        
        Args:
            fecha_inicio (str): Fecha de inicio en formato YYYY-MM-DD.
            fecha_fin (str): Fecha de fin en formato YYYY-MM-DD.
            
        Returns:
            dict: Diccionario con el resumen de ventas.
        """
        # Consulta para obtener el total de ventas en el período
        query_total = """
        SELECT COUNT(*) AS total_ventas, 
            COALESCE(SUM(total), 0) AS monto_total,
            COALESCE(SUM(CASE WHEN estado_pago = 'Pagado' THEN total ELSE 0 END), 0) AS monto_pagado,
            COALESCE(SUM(CASE WHEN estado_pago = 'Pendiente' THEN total ELSE 0 END), 0) AS monto_pendiente,
            COALESCE(SUM(CASE WHEN estado_pago = 'Parcial' THEN total ELSE 0 END), 0) AS monto_parcial
        FROM Ventas
        WHERE fecha_venta BETWEEN ? AND ?
        """
        
        total_rows = self._ejecutar_consulta(query_total, (fecha_inicio, fecha_fin))
        
        if not total_rows:
            return self._resumen_vacio(fecha_inicio, fecha_fin)
        
        row_total = total_rows[0]
        
        # Consulta para obtener ventas por cliente
        query_clientes = """
        SELECT c.id_cliente, c.nombre, COUNT(v.id_venta) AS total_ventas, 
               COALESCE(SUM(v.total), 0) AS monto_total
        FROM Ventas v
        JOIN Clientes c ON v.id_cliente = c.id_cliente
        WHERE v.fecha_venta BETWEEN ? AND ?
        GROUP BY c.id_cliente, c.nombre
        ORDER BY monto_total DESC
        """
        
        clientes_rows = self._ejecutar_consulta(query_clientes, (fecha_inicio, fecha_fin))
        
        clientes = []
        for row in clientes_rows:
            cliente = {
                'id_cliente': row.id_cliente,
                'nombre': row.nombre,
                'total_ventas': row.total_ventas,
                'monto_total': float(row.monto_total)
            }
            clientes.append(cliente)
        
        # Consulta para obtener ventas por estado
        query_estados = """
        SELECT e.id_estado, e.nombre, COUNT(v.id_venta) AS total_ventas, 
               COALESCE(SUM(v.total), 0) AS monto_total
        FROM Ventas v
        JOIN EstadosVenta e ON v.id_estado = e.id_estado
        WHERE v.fecha_venta BETWEEN ? AND ?
        GROUP BY e.id_estado, e.nombre
        ORDER BY monto_total DESC
        """
        
        estados_rows = self._ejecutar_consulta(query_estados, (fecha_inicio, fecha_fin))
        
        estados = []
        for row in estados_rows:
            estado = {
                'id_estado': row.id_estado,
                'nombre': row.nombre,
                'total_ventas': row.total_ventas,
                'monto_total': float(row.monto_total)
            }
            estados.append(estado)
        
        # Armar el resumen
        resumen = {
            'periodo': {
                'fecha_inicio': fecha_inicio,
                'fecha_fin': fecha_fin
            },
            'totales': {
                'total_ventas': row_total.total_ventas,
                'monto_total': float(row_total.monto_total),
                'monto_pagado': float(row_total.monto_pagado),
                'monto_pendiente': float(row_total.monto_pendiente),
                'monto_parcial': float(row_total.monto_parcial)
            },
            'por_cliente': clientes,
            'por_estado': estados
        }
        
        return resumen

    @cacheable('resumen_ventas', key_func=lambda: 'mes_actual', ttl=600)  # 10 min
    def obtener_ventas_del_mes(self):
        """
        Obtiene un resumen de las ventas del mes actual.
        
        Returns:
            dict: Diccionario con el resumen de ventas del mes.
        """
        # Obtener el primer y último día del mes actual
        hoy = datetime.now().date()
        primer_dia_mes = datetime(hoy.year, hoy.month, 1).date()
        
        # Calcular el último día del mes
        if hoy.month == 12:
            ultimo_dia_mes = datetime(hoy.year + 1, 1, 1).date()
        else:
            ultimo_dia_mes = datetime(hoy.year, hoy.month + 1, 1).date()
        
        ultimo_dia_mes = (ultimo_dia_mes - timedelta(days=1))
        
        return self.obtener_resumen_ventas_por_periodo(
            primer_dia_mes.strftime('%Y-%m-%d'),
            ultimo_dia_mes.strftime('%Y-%m-%d')
        )

    def buscar_clientes_con_ventas(self, texto_busqueda):
        """
        Busca clientes que tengan ventas, incluyendo información de sus compras.
        
        Args:
            texto_busqueda (str): Texto a buscar en nombre del cliente.
            
        Returns:
            list: Lista de clientes con información de sus ventas.
        """
        query = """
        SELECT c.id_cliente, c.nombre, c.telefono, c.correo,
               COUNT(v.id_venta) AS cantidad_ventas,
               COALESCE(SUM(v.total), 0) AS monto_total
        FROM Clientes c
        LEFT JOIN Ventas v ON c.id_cliente = v.id_cliente
        WHERE c.activo = 1 
        AND c.nombre LIKE ?
        GROUP BY c.id_cliente, c.nombre, c.telefono, c.correo
        HAVING COUNT(v.id_venta) > 0
        ORDER BY c.nombre
        """
        
        patron = f"%{texto_busqueda}%"
        rows = self._ejecutar_consulta(query, (patron,))
        
        clientes = []
        for row in rows:
            cliente = {
                'id_cliente': row.id_cliente,
                'nombre': row.nombre,
                'telefono': row.telefono,
                'correo': row.correo,
                'cantidad_ventas': row.cantidad_ventas,
                'monto_total': float(row.monto_total)
            }
            clientes.append(cliente)
        
        logger.info(f"Búsqueda '{texto_busqueda}' con ventas: {len(clientes)} resultados")
        return clientes

    # ==================== MÉTODOS AUXILIARES ====================
    
    def _calcular_percentil(self, valores, percentil):
        """
        Calcula un percentil específico para una lista de valores.
        
        Args:
            valores (list): Lista de valores numéricos.
            percentil (float): Percentil a calcular (0-100).
            
        Returns:
            float: Valor del percentil.
        """
        if not valores:
            return 0
            
        k = (len(valores) - 1) * percentil / 100
        f = int(k)
        c = int(k) + 1 if k != f else int(k)
        
        if f >= len(valores):
            return valores[-1]
        elif c >= len(valores):
            return valores[-1]
        else:
            return valores[f] + (valores[c] - valores[f]) * (k - f)
    
    def _resumen_vacio(self, fecha_inicio, fecha_fin):
        """
        Genera un resumen vacío para períodos sin ventas.
        
        Args:
            fecha_inicio (str): Fecha de inicio.
            fecha_fin (str): Fecha de fin.
            
        Returns:
            dict: Resumen vacío estructurado.
        """
        return {
            'periodo': {
                'fecha_inicio': fecha_inicio,
                'fecha_fin': fecha_fin
            },
            'totales': {
                'total_ventas': 0,
                'monto_total': 0.0,
                'monto_pagado': 0.0,
                'monto_pendiente': 0.0,
                'monto_parcial': 0.0
            },
            'por_cliente': [],
            'por_estado': []
        }