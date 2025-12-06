# backend/repositories/AgroquimicosRep/lote_agroquimico_repositorio.py
"""
Repositorio para gestión de lotes de agroquímicos
Manejo de inventario, stock, vencimientos y alertas
"""

import logging
from datetime import datetime
from typing import List, Optional, Dict, Tuple
from backend.core.repositorio_base import RepositorioBase
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)


class LoteAgroquimicoRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de Lotes de Agroquímicos"""
    
    def __init__(self):
        super().__init__()
        self.tabla = "LotesAgroquimicos"
    
    # ==================== CONSULTAS ====================
    
    @cacheable('lotes_agroquimicos', ttl=get_ttl('lotes'))
    def obtener_todos(self) -> List[Dict]:
        """Obtiene todos los lotes de agroquímicos"""
        query = """
        SELECT la.id_lote_agroquimico, la.id_producto, p.nombre_comercial,
               la.codigo_lote, la.fecha_compra, la.fecha_vencimiento,
               la.cantidad_inicial, la.cantidad_actual, la.precio_unitario,
               la.activo, prov.nombre as proveedor
        FROM LotesAgroquimicos la
        LEFT JOIN ProductosAgroquimicos p ON la.id_producto = p.id_producto
        LEFT JOIN Proveedores prov ON la.id_proveedor = prov.id_proveedor
        ORDER BY la.fecha_vencimiento
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                lotes = []
                for row in cursor.fetchall():
                    lote = {
                        'id_lote_agroquimico': row.id_lote_agroquimico,
                        'id_producto': row.id_producto,
                        'nombre_producto': row.nombre_comercial,
                        'codigo_lote': row.codigo_lote,
                        'fecha_compra': self._formatear_fecha(row.fecha_compra),
                        'fecha_vencimiento': self._formatear_fecha(row.fecha_vencimiento),
                        'cantidad_inicial': float(row.cantidad_inicial),
                        'cantidad_actual': float(row.cantidad_actual),
                        'precio_unitario': float(row.precio_unitario) if row.precio_unitario else 0.0,
                        'activo': bool(row.activo),
                        'proveedor': row.proveedor
                    }
                    lotes.append(lote)
                
                logger.info(f"Se obtuvieron {len(lotes)} lotes")
                return lotes
                
        except Exception as e:
            logger.error(f"Error al obtener lotes: {str(e)}")
            return []
    
    def obtener_por_id(self, id_lote: int) -> Optional[Dict]:
        """Obtiene un lote específico por su ID"""
        query = """
        SELECT la.id_lote_agroquimico, la.id_producto, p.nombre_comercial,
               la.codigo_lote, la.fecha_compra, la.fecha_vencimiento,
               la.cantidad_inicial, la.cantidad_actual, la.precio_unitario,
               la.activo, la.id_proveedor, prov.nombre as proveedor
        FROM LotesAgroquimicos la
        LEFT JOIN ProductosAgroquimicos p ON la.id_producto = p.id_producto
        LEFT JOIN Proveedores prov ON la.id_proveedor = prov.id_proveedor
        WHERE la.id_lote_agroquimico = ?
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_lote,))
                row = cursor.fetchone()
                
                if not row:
                    return None
                
                # Calcular días para vencer
                dias_para_vencer = None
                if row.fecha_vencimiento:
                    fecha_vencimiento = row.fecha_vencimiento if isinstance(row.fecha_vencimiento, datetime) else datetime.strptime(row.fecha_vencimiento, '%Y-%m-%d')
                    dias_para_vencer = (fecha_vencimiento - datetime.now()).days
                
                return {
                    'id_lote_agroquimico': row.id_lote_agroquimico,
                    'id_producto': row.id_producto,
                    'nombre_producto': row.nombre_comercial,
                    'codigo_lote': row.codigo_lote,
                    'fecha_compra': self._formatear_fecha(row.fecha_compra),
                    'fecha_vencimiento': self._formatear_fecha(row.fecha_vencimiento),
                    'cantidad_inicial': float(row.cantidad_inicial),
                    'cantidad_actual': float(row.cantidad_actual),
                    'precio_unitario': float(row.precio_unitario) if row.precio_unitario else 0.0,
                    'activo': bool(row.activo),
                    'id_proveedor': row.id_proveedor,
                    'proveedor': row.proveedor,
                    'dias_para_vencer': dias_para_vencer
                }
                
        except Exception as e:
            logger.error(f"Error al obtener lote {id_lote}: {str(e)}")
            return None
    
    def obtener_por_producto(self, id_producto: int, solo_activos: bool = True) -> List[Dict]:
        """Obtiene lotes por producto"""
        query = """
        SELECT id_lote_agroquimico, codigo_lote, fecha_compra, fecha_vencimiento,
               cantidad_inicial, cantidad_actual, precio_unitario, activo
        FROM LotesAgroquimicos
        WHERE id_producto = ?
        """
        
        if solo_activos:
            query += " AND activo = 1 AND cantidad_actual > 0"
        
        query += " ORDER BY fecha_vencimiento"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_producto,))
                
                lotes = []
                for row in cursor.fetchall():
                    lote = {
                        'id_lote_agroquimico': row.id_lote_agroquimico,
                        'codigo_lote': row.codigo_lote,
                        'fecha_compra': self._formatear_fecha(row.fecha_compra),
                        'fecha_vencimiento': self._formatear_fecha(row.fecha_vencimiento),
                        'cantidad_inicial': float(row.cantidad_inicial),
                        'cantidad_actual': float(row.cantidad_actual),
                        'precio_unitario': float(row.precio_unitario) if row.precio_unitario else 0.0,
                        'activo': bool(row.activo)
                    }
                    lotes.append(lote)
                
                return lotes
                
        except Exception as e:
            logger.error(f"Error al obtener lotes por producto {id_producto}: {str(e)}")
            return []
    
    # ==================== INSERCIÓN ====================
    
    @cache_invalidator('lotes_agroquimicos')
    def crear(self, datos: Dict) -> Tuple[bool, Optional[int]]:
        """Crea un nuevo lote de agroquímico"""
        query = """
        INSERT INTO LotesAgroquimicos 
        (id_producto, id_proveedor, codigo_lote, fecha_compra, fecha_vencimiento,
         cantidad_inicial, cantidad_actual, precio_unitario, activo)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        try:
            valores = (
                datos['id_producto'],
                datos.get('id_proveedor'),
                datos['codigo_lote'],
                datos.get('fecha_compra', datetime.now().strftime('%Y-%m-%d')),
                datos['fecha_vencimiento'],
                datos['cantidad_inicial'],
                datos.get('cantidad_actual', datos['cantidad_inicial']),
                datos.get('precio_unitario', 0.0),
                1 if datos.get('activo', True) else 0
            )
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                id_lote = self._obtener_ultimo_id()
                logger.info(f"Lote creado con ID: {id_lote}")
                return True, id_lote
                
        except Exception as e:
            logger.error(f"Error al crear lote: {str(e)}")
            return False, None
    
    # ==================== ACTUALIZACIÓN ====================
    
    @cache_invalidator('lotes_agroquimicos')
    def actualizar(self, id_lote: int, datos: Dict) -> bool:
        """Actualiza un lote existente"""
        try:
            campos_actualizar = []
            valores = []
            
            campos_permitidos = ['id_producto', 'id_proveedor', 'codigo_lote', 
                               'fecha_compra', 'fecha_vencimiento', 'cantidad_inicial',
                               'cantidad_actual', 'precio_unitario', 'activo']
            
            for campo in campos_permitidos:
                if campo in datos:
                    campos_actualizar.append(f"{campo} = ?")
                    if campo == 'activo':
                        valores.append(1 if datos[campo] else 0)
                    else:
                        valores.append(datos[campo])
            
            if not campos_actualizar:
                logger.warning("No hay campos para actualizar")
                return False
            
            valores.append(id_lote)
            query = f"UPDATE LotesAgroquimicos SET {', '.join(campos_actualizar)} WHERE id_lote_agroquimico = ?"
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Lote {id_lote} actualizado. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al actualizar lote {id_lote}: {str(e)}")
            return False
    
    @cache_invalidator('lotes_agroquimicos')
    def actualizar_cantidad(self, id_lote: int, nueva_cantidad: float) -> bool:
        """Actualiza solo la cantidad actual de un lote"""
        query = "UPDATE LotesAgroquimicos SET cantidad_actual = ? WHERE id_lote_agroquimico = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (nueva_cantidad, id_lote))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                if filas_afectadas > 0:
                    logger.info(f"Cantidad actualizada del lote {id_lote}: {nueva_cantidad}")
                    return True
                return False
                
        except Exception as e:
            logger.error(f"Error al actualizar cantidad del lote {id_lote}: {str(e)}")
            return False
    
    # ==================== ELIMINACIÓN ====================
    
    @cache_invalidator('lotes_agroquimicos')
    def eliminar(self, id_lote: int) -> bool:
        """Elimina (desactiva) un lote"""
        return self.actualizar(id_lote, {'activo': False})
    
    # ==================== MÉTODOS DE INVENTARIO ====================
    
    def obtener_stock_producto(self, id_producto: int) -> Dict:
        """Obtiene el stock total de un producto"""
        query = """
        SELECT 
            SUM(cantidad_actual) as stock_total,
            COUNT(*) as total_lotes,
            COUNT(CASE WHEN cantidad_actual > 0 THEN 1 END) as lotes_disponibles,
            MIN(fecha_vencimiento) as proximo_vencimiento
        FROM LotesAgroquimicos
        WHERE id_producto = ? AND activo = 1
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_producto,))
                row = cursor.fetchone()
                
                return {
                    'stock_total': float(row[0]) if row[0] else 0.0,
                    'total_lotes': row[1],
                    'lotes_disponibles': row[2],
                    'proximo_vencimiento': self._formatear_fecha(row[3])
                }
                
        except Exception as e:
            logger.error(f"Error al obtener stock del producto {id_producto}: {str(e)}")
            return {'stock_total': 0.0, 'total_lotes': 0, 'lotes_disponibles': 0, 'proximo_vencimiento': None}
    
    def obtener_lotes_por_vencer(self, dias: int = 30) -> List[Dict]:
        """Obtiene lotes que están por vencer en los próximos días"""
        query = """
        SELECT la.id_lote_agroquimico, la.id_producto, p.nombre_comercial,
               la.codigo_lote, la.fecha_vencimiento, la.cantidad_actual,
               DATEDIFF(day, GETDATE(), la.fecha_vencimiento) as dias_para_vencer
        FROM LotesAgroquimicos la
        JOIN ProductosAgroquimicos p ON la.id_producto = p.id_producto
        WHERE la.activo = 1 
        AND la.cantidad_actual > 0
        AND la.fecha_vencimiento BETWEEN GETDATE() AND DATEADD(day, ?, GETDATE())
        ORDER BY la.fecha_vencimiento
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (dias,))
                
                lotes = []
                for row in cursor.fetchall():
                    lote = {
                        'id_lote_agroquimico': row.id_lote_agroquimico,
                        'id_producto': row.id_producto,
                        'nombre_producto': row.nombre_comercial,
                        'codigo_lote': row.codigo_lote,
                        'fecha_vencimiento': self._formatear_fecha(row.fecha_vencimiento),
                        'cantidad_actual': float(row.cantidad_actual),
                        'dias_para_vencer': row.dias_para_vencer,
                        'nivel_alerta': 'critico' if row.dias_para_vencer <= 7 else 'medio' if row.dias_para_vencer <= 15 else 'bajo'
                    }
                    lotes.append(lote)
                
                return lotes
                
        except Exception as e:
            logger.error(f"Error al obtener lotes por vencer: {str(e)}")
            return []
    
    def obtener_lotes_stock_bajo(self, umbral: float = 10.0) -> List[Dict]:
        """Obtiene lotes con stock bajo"""
        query = """
        SELECT la.id_lote_agroquimico, la.id_producto, p.nombre_comercial,
               la.codigo_lote, la.cantidad_inicial, la.cantidad_actual,
               (la.cantidad_actual / la.cantidad_inicial) * 100 as porcentaje_stock
        FROM LotesAgroquimicos la
        JOIN ProductosAgroquimicos p ON la.id_producto = p.id_producto
        WHERE la.activo = 1 
        AND la.cantidad_actual > 0
        AND (la.cantidad_actual / la.cantidad_inicial) * 100 <= ?
        ORDER BY porcentaje_stock
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (umbral,))
                
                lotes = []
                for row in cursor.fetchall():
                    lote = {
                        'id_lote_agroquimico': row.id_lote_agroquimico,
                        'id_producto': row.id_producto,
                        'nombre_producto': row.nombre_comercial,
                        'codigo_lote': row.codigo_lote,
                        'cantidad_inicial': float(row.cantidad_inicial),
                        'cantidad_actual': float(row.cantidad_actual),
                        'porcentaje_stock': float(row.porcentaje_stock),
                        'nivel_alerta': 'critico' if row.porcentaje_stock <= 5 else 'medio' if row.porcentaje_stock <= 10 else 'bajo'
                    }
                    lotes.append(lote)
                
                return lotes
                
        except Exception as e:
            logger.error(f"Error al obtener lotes con stock bajo: {str(e)}")
            return []
        
    def listar_lotes_por_vencer(self, dias: int = 30) -> List[Dict]:
        """Alias/compatibilidad: devuelve lotes próximos a vencer"""
        try:
            lotes = self.obtener_lotes_por_vencer(dias)
            logger.info(f"Listados {len(lotes)} lotes por vencer en los próximos {dias} días")
            return lotes
        except Exception as e:
            logger.error(f"Error al listar lotes por vencer: {str(e)}")
            return []