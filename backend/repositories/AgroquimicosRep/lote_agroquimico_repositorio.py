# backend/repositories/AgroquimicosRep/lote_agroquimico_repositorio.py
"""
Repositorio para gestión de lotes de agroquímicos
Manejo de inventario, stock, vencimientos y alertas
"""

from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any
from sqlalchemy import func, and_, or_
from sqlalchemy.orm import Session
from decimal import Decimal


class LoteAgroquimicoRepositorio:
    """
    Repositorio para gestionar lotes de agroquímicos en inventario
    """
    
    def __init__(self, db_session: Session):
        """
        Inicializa el repositorio con una sesión de base de datos
        
        Args:
            db_session: Sesión de SQLAlchemy
        """
        self.db = db_session
    
    def crear_lote(self, datos_lote: Dict[str, Any]) -> Dict[str, Any]:
        """
        Registra un nuevo lote de agroquímico (compra)
        
        Args:
            datos_lote: Diccionario con los datos del lote
                - id_producto: ID del producto
                - numero_lote: Número de lote del fabricante
                - fecha_compra: Fecha de compra
                - fecha_vencimiento: Fecha de vencimiento
                - cantidad_inicial: Cantidad comprada
                - unidad_medida: Unidad (litros, kg, etc.)
                - ubicacion_almacen: Ubicación física
                - precio_compra: Precio de compra (opcional)
                - proveedor: Nombre del proveedor (opcional)
        
        Returns:
            Diccionario con los datos del lote creado
        """
        try:
            query = """
                INSERT INTO lote_agroquimico (
                    id_producto,
                    numero_lote,
                    fecha_compra,
                    fecha_vencimiento,
                    cantidad_inicial,
                    cantidad_actual,
                    unidad_medida,
                    ubicacion_almacen,
                    precio_compra,
                    proveedor,
                    estado,
                    fecha_registro
                ) VALUES (
                    :id_producto,
                    :numero_lote,
                    :fecha_compra,
                    :fecha_vencimiento,
                    :cantidad_inicial,
                    :cantidad_inicial,
                    :unidad_medida,
                    :ubicacion_almacen,
                    :precio_compra,
                    :proveedor,
                    'activo',
                    NOW()
                )
                RETURNING id_lote, id_producto, numero_lote, fecha_compra, 
                          fecha_vencimiento, cantidad_inicial, cantidad_actual,
                          unidad_medida, ubicacion_almacen, estado
            """
            
            resultado = self.db.execute(query, {
                'id_producto': datos_lote['id_producto'],
                'numero_lote': datos_lote['numero_lote'],
                'fecha_compra': datos_lote.get('fecha_compra', datetime.now()),
                'fecha_vencimiento': datos_lote['fecha_vencimiento'],
                'cantidad_inicial': datos_lote['cantidad_inicial'],
                'unidad_medida': datos_lote['unidad_medida'],
                'ubicacion_almacen': datos_lote.get('ubicacion_almacen', 'ALMACEN-01'),
                'precio_compra': datos_lote.get('precio_compra'),
                'proveedor': datos_lote.get('proveedor')
            }).fetchone()
            
            self.db.commit()
            
            return {
                'id_lote': resultado[0],
                'id_producto': resultado[1],
                'numero_lote': resultado[2],
                'fecha_compra': resultado[3],
                'fecha_vencimiento': resultado[4],
                'cantidad_inicial': float(resultado[5]),
                'cantidad_actual': float(resultado[6]),
                'unidad_medida': resultado[7],
                'ubicacion_almacen': resultado[8],
                'estado': resultado[9]
            }
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Error al crear lote: {str(e)}")
    
    def obtener_lote_por_id(self, id_lote: int) -> Optional[Dict[str, Any]]:
        """
        Obtiene un lote específico por su ID
        
        Args:
            id_lote: ID del lote
            
        Returns:
            Diccionario con los datos del lote o None si no existe
        """
        query = """
            SELECT 
                l.id_lote,
                l.id_producto,
                p.nombre_comercial,
                p.ingrediente_activo,
                l.numero_lote,
                l.fecha_compra,
                l.fecha_vencimiento,
                l.cantidad_inicial,
                l.cantidad_actual,
                l.unidad_medida,
                l.ubicacion_almacen,
                l.precio_compra,
                l.proveedor,
                l.estado,
                DATEDIFF(l.fecha_vencimiento, CURDATE()) as dias_para_vencer,
                DATEDIFF(CURDATE(), l.fecha_compra) as dias_en_inventario
            FROM lote_agroquimico l
            INNER JOIN producto p ON l.id_producto = p.id_producto
            WHERE l.id_lote = :id_lote
        """
        
        resultado = self.db.execute(query, {'id_lote': id_lote}).fetchone()
        
        if not resultado:
            return None
        
        return {
            'id_lote': resultado[0],
            'id_producto': resultado[1],
            'nombre_producto': resultado[2],
            'ingrediente_activo': resultado[3],
            'numero_lote': resultado[4],
            'fecha_compra': resultado[5],
            'fecha_vencimiento': resultado[6],
            'cantidad_inicial': float(resultado[7]),
            'cantidad_actual': float(resultado[8]),
            'unidad_medida': resultado[9],
            'ubicacion_almacen': resultado[10],
            'precio_compra': float(resultado[11]) if resultado[11] else None,
            'proveedor': resultado[12],
            'estado': resultado[13],
            'dias_para_vencer': resultado[14],
            'dias_en_inventario': resultado[15]
        }
    
    def listar_lotes_por_producto(self, id_producto: int, 
                                   incluir_agotados: bool = False) -> List[Dict[str, Any]]:
        """
        Lista todos los lotes de un producto específico
        
        Args:
            id_producto: ID del producto
            incluir_agotados: Si incluir lotes agotados (cantidad_actual = 0)
            
        Returns:
            Lista de lotes del producto
        """
        query = """
            SELECT 
                l.id_lote,
                l.numero_lote,
                l.fecha_compra,
                l.fecha_vencimiento,
                l.cantidad_inicial,
                l.cantidad_actual,
                l.unidad_medida,
                l.ubicacion_almacen,
                l.estado,
                DATEDIFF(l.fecha_vencimiento, CURDATE()) as dias_para_vencer
            FROM lote_agroquimico l
            WHERE l.id_producto = :id_producto
        """
        
        if not incluir_agotados:
            query += " AND l.cantidad_actual > 0"
        
        query += " ORDER BY l.fecha_vencimiento ASC"
        
        resultados = self.db.execute(query, {'id_producto': id_producto}).fetchall()
        
        return [
            {
                'id_lote': r[0],
                'numero_lote': r[1],
                'fecha_compra': r[2],
                'fecha_vencimiento': r[3],
                'cantidad_inicial': float(r[4]),
                'cantidad_actual': float(r[5]),
                'unidad_medida': r[6],
                'ubicacion_almacen': r[7],
                'estado': r[8],
                'dias_para_vencer': r[9]
            }
            for r in resultados
        ]
    
    def obtener_stock_actual_producto(self, id_producto: int) -> Dict[str, Any]:
        """
        Obtiene el stock total actual de un producto (suma de todos sus lotes activos)
        
        Args:
            id_producto: ID del producto
            
        Returns:
            Diccionario con stock total, número de lotes y próximo a vencer
        """
        query = """
            SELECT 
                COALESCE(SUM(cantidad_actual), 0) as stock_total,
                COUNT(*) as numero_lotes,
                MIN(fecha_vencimiento) as proxima_fecha_vencimiento,
                MIN(DATEDIFF(fecha_vencimiento, CURDATE())) as dias_minimo_vencer
            FROM lote_agroquimico
            WHERE id_producto = :id_producto
            AND cantidad_actual > 0
            AND estado = 'activo'
        """
        
        resultado = self.db.execute(query, {'id_producto': id_producto}).fetchone()
        
        return {
            'id_producto': id_producto,
            'stock_total': float(resultado[0]),
            'numero_lotes': resultado[1],
            'proxima_fecha_vencimiento': resultado[2],
            'dias_minimo_vencer': resultado[3] if resultado[3] is not None else None
        }
    
    def descontar_cantidad(self, id_lote: int, cantidad: float, 
                          id_tratamiento: Optional[int] = None) -> Dict[str, Any]:
        """
        Descuenta cantidad de un lote cuando se usa en un tratamiento
        
        Args:
            id_lote: ID del lote
            cantidad: Cantidad a descontar
            id_tratamiento: ID del tratamiento que consume el lote (opcional)
            
        Returns:
            Diccionario con el resultado de la operación
        """
        try:
            # Verificar stock disponible
            lote = self.obtener_lote_por_id(id_lote)
            
            if not lote:
                raise ValueError(f"Lote {id_lote} no encontrado")
            
            if lote['cantidad_actual'] < cantidad:
                raise ValueError(
                    f"Stock insuficiente. Disponible: {lote['cantidad_actual']} "
                    f"{lote['unidad_medida']}, Solicitado: {cantidad}"
                )
            
            # Descontar cantidad
            nueva_cantidad = lote['cantidad_actual'] - cantidad
            nuevo_estado = 'agotado' if nueva_cantidad == 0 else 'activo'
            
            query = """
                UPDATE lote_agroquimico
                SET cantidad_actual = :nueva_cantidad,
                    estado = :nuevo_estado,
                    fecha_ultima_modificacion = NOW()
                WHERE id_lote = :id_lote
            """
            
            self.db.execute(query, {
                'nueva_cantidad': nueva_cantidad,
                'nuevo_estado': nuevo_estado,
                'id_lote': id_lote
            })
            
            # Registrar el movimiento (si tienes tabla de movimientos)
            self._registrar_movimiento(
                id_lote=id_lote,
                tipo_movimiento='salida',
                cantidad=cantidad,
                id_tratamiento=id_tratamiento
            )
            
            self.db.commit()
            
            return {
                'exito': True,
                'id_lote': id_lote,
                'cantidad_descontada': cantidad,
                'cantidad_anterior': lote['cantidad_actual'],
                'cantidad_actual': nueva_cantidad,
                'estado': nuevo_estado
            }
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Error al descontar cantidad: {str(e)}")
    
    def listar_lotes_por_vencer(self, dias: int = 30) -> List[Dict[str, Any]]:
        """
        Lista lotes que están próximos a vencer
        
        Args:
            dias: Número de días de anticipación para considerar próximo a vencer
            
        Returns:
            Lista de lotes próximos a vencer
        """
        query = """
            SELECT 
                l.id_lote,
                l.id_producto,
                p.nombre_comercial,
                l.numero_lote,
                l.fecha_vencimiento,
                l.cantidad_actual,
                l.unidad_medida,
                l.ubicacion_almacen,
                DATEDIFF(l.fecha_vencimiento, CURDATE()) as dias_para_vencer
            FROM lote_agroquimico l
            INNER JOIN producto p ON l.id_producto = p.id_producto
            WHERE l.cantidad_actual > 0
            AND l.estado = 'activo'
            AND DATEDIFF(l.fecha_vencimiento, CURDATE()) <= :dias
            AND DATEDIFF(l.fecha_vencimiento, CURDATE()) >= 0
            ORDER BY l.fecha_vencimiento ASC
        """
        
        resultados = self.db.execute(query, {'dias': dias}).fetchall()
        
        return [
            {
                'id_lote': r[0],
                'id_producto': r[1],
                'nombre_producto': r[2],
                'numero_lote': r[3],
                'fecha_vencimiento': r[4],
                'cantidad_actual': float(r[5]),
                'unidad_medida': r[6],
                'ubicacion_almacen': r[7],
                'dias_para_vencer': r[8],
                'nivel_alerta': 'critico' if r[8] <= 7 else 'alto' if r[8] <= 15 else 'medio'
            }
            for r in resultados
        ]
    
    def listar_lotes_vencidos(self) -> List[Dict[str, Any]]:
        """
        Lista lotes que ya están vencidos
        
        Returns:
            Lista de lotes vencidos
        """
        query = """
            SELECT 
                l.id_lote,
                l.id_producto,
                p.nombre_comercial,
                l.numero_lote,
                l.fecha_vencimiento,
                l.cantidad_actual,
                l.unidad_medida,
                l.ubicacion_almacen,
                DATEDIFF(CURDATE(), l.fecha_vencimiento) as dias_vencido
            FROM lote_agroquimico l
            INNER JOIN producto p ON l.id_producto = p.id_producto
            WHERE l.fecha_vencimiento < CURDATE()
            AND l.cantidad_actual > 0
            ORDER BY l.fecha_vencimiento ASC
        """
        
        resultados = self.db.execute(query).fetchall()
        
        # Actualizar estado a vencido
        if resultados:
            ids_vencidos = [r[0] for r in resultados]
            self._actualizar_estado_lotes_vencidos(ids_vencidos)
        
        return [
            {
                'id_lote': r[0],
                'id_producto': r[1],
                'nombre_producto': r[2],
                'numero_lote': r[3],
                'fecha_vencimiento': r[4],
                'cantidad_actual': float(r[5]),
                'unidad_medida': r[6],
                'ubicacion_almacen': r[7],
                'dias_vencido': r[8]
            }
            for r in resultados
        ]
    
    def listar_lotes_con_stock_bajo(self, umbral_porcentaje: float = 20.0) -> List[Dict[str, Any]]:
        """
        Lista lotes con stock bajo (basado en porcentaje de cantidad inicial)
        
        Args:
            umbral_porcentaje: Porcentaje bajo el cual se considera stock bajo
            
        Returns:
            Lista de lotes con stock bajo
        """
        query = """
            SELECT 
                l.id_lote,
                l.id_producto,
                p.nombre_comercial,
                l.numero_lote,
                l.cantidad_inicial,
                l.cantidad_actual,
                l.unidad_medida,
                l.ubicacion_almacen,
                ROUND((l.cantidad_actual / l.cantidad_inicial) * 100, 2) as porcentaje_disponible
            FROM lote_agroquimico l
            INNER JOIN producto p ON l.id_producto = p.id_producto
            WHERE l.cantidad_actual > 0
            AND l.estado = 'activo'
            AND (l.cantidad_actual / l.cantidad_inicial) * 100 <= :umbral
            ORDER BY porcentaje_disponible ASC
        """
        
        resultados = self.db.execute(query, {'umbral': umbral_porcentaje}).fetchall()
        
        return [
            {
                'id_lote': r[0],
                'id_producto': r[1],
                'nombre_producto': r[2],
                'numero_lote': r[3],
                'cantidad_inicial': float(r[4]),
                'cantidad_actual': float(r[5]),
                'unidad_medida': r[6],
                'ubicacion_almacen': r[7],
                'porcentaje_disponible': float(r[8]),
                'nivel_alerta': 'critico' if r[8] <= 10 else 'alto' if r[8] <= 20 else 'medio'
            }
            for r in resultados
        ]
    
    def obtener_lotes_por_ubicacion(self, ubicacion: str) -> List[Dict[str, Any]]:
        """
        Obtiene todos los lotes en una ubicación específica del almacén
        
        Args:
            ubicacion: Código o nombre de la ubicación
            
        Returns:
            Lista de lotes en esa ubicación
        """
        query = """
            SELECT 
                l.id_lote,
                l.id_producto,
                p.nombre_comercial,
                l.numero_lote,
                l.cantidad_actual,
                l.unidad_medida,
                l.fecha_vencimiento,
                DATEDIFF(l.fecha_vencimiento, CURDATE()) as dias_para_vencer
            FROM lote_agroquimico l
            INNER JOIN producto p ON l.id_producto = p.id_producto
            WHERE l.ubicacion_almacen = :ubicacion
            AND l.cantidad_actual > 0
            ORDER BY l.fecha_vencimiento ASC
        """
        
        resultados = self.db.execute(query, {'ubicacion': ubicacion}).fetchall()
        
        return [
            {
                'id_lote': r[0],
                'id_producto': r[1],
                'nombre_producto': r[2],
                'numero_lote': r[3],
                'cantidad_actual': float(r[4]),
                'unidad_medida': r[5],
                'fecha_vencimiento': r[6],
                'dias_para_vencer': r[7]
            }
            for r in resultados
        ]
    
    def obtener_historial_uso_lote(self, id_lote: int) -> List[Dict[str, Any]]:
        """
        Obtiene el historial de uso de un lote (en qué tratamientos se usó)
        
        Args:
            id_lote: ID del lote
            
        Returns:
            Lista de tratamientos donde se usó el lote
        """
        query = """
            SELECT 
                td.id_tratamiento,
                t.nombre_tratamiento,
                t.fecha_aplicacion,
                td.cantidad_usada,
                td.unidad_medida,
                t.id_lote,
                l.nombre_lote
            FROM tratamiento_detalle td
            INNER JOIN tratamiento t ON td.id_tratamiento = t.id_tratamiento
            INNER JOIN lote l ON t.id_lote = l.id_lote
            WHERE td.id_lote = :id_lote
            ORDER BY t.fecha_aplicacion DESC
        """
        
        resultados = self.db.execute(query, {'id_lote': id_lote}).fetchall()
        
        return [
            {
                'id_tratamiento': r[0],
                'nombre_tratamiento': r[1],
                'fecha_aplicacion': r[2],
                'cantidad_usada': float(r[3]),
                'unidad_medida': r[4],
                'id_lote_agricola': r[5],
                'nombre_lote_agricola': r[6]
            }
            for r in resultados
        ]
    
    def actualizar_estado_lote(self, id_lote: int, nuevo_estado: str) -> bool:
        """
        Actualiza el estado de un lote
        
        Args:
            id_lote: ID del lote
            nuevo_estado: Nuevo estado (activo, vencido, agotado, en_revision)
            
        Returns:
            True si se actualizó correctamente
        """
        try:
            query = """
                UPDATE lote_agroquimico
                SET estado = :nuevo_estado,
                    fecha_ultima_modificacion = NOW()
                WHERE id_lote = :id_lote
            """
            
            self.db.execute(query, {
                'nuevo_estado': nuevo_estado,
                'id_lote': id_lote
            })
            
            self.db.commit()
            return True
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Error al actualizar estado del lote: {str(e)}")
    
    def obtener_resumen_inventario(self) -> Dict[str, Any]:
        """
        Obtiene un resumen general del inventario de agroquímicos
        
        Returns:
            Diccionario con estadísticas del inventario
        """
        query = """
            SELECT 
                COUNT(DISTINCT id_producto) as total_productos,
                COUNT(*) as total_lotes,
                SUM(CASE WHEN cantidad_actual > 0 THEN 1 ELSE 0 END) as lotes_disponibles,
                SUM(CASE WHEN DATEDIFF(fecha_vencimiento, CURDATE()) <= 30 
                    AND cantidad_actual > 0 THEN 1 ELSE 0 END) as lotes_por_vencer,
                SUM(CASE WHEN fecha_vencimiento < CURDATE() 
                    AND cantidad_actual > 0 THEN 1 ELSE 0 END) as lotes_vencidos,
                SUM(CASE WHEN (cantidad_actual / cantidad_inicial) * 100 <= 20 
                    AND cantidad_actual > 0 THEN 1 ELSE 0 END) as lotes_stock_bajo
            FROM lote_agroquimico
        """
        
        resultado = self.db.execute(query).fetchone()
        
        return {
            'total_productos': resultado[0],
            'total_lotes': resultado[1],
            'lotes_disponibles': resultado[2],
            'lotes_por_vencer': resultado[3],
            'lotes_vencidos': resultado[4],
            'lotes_stock_bajo': resultado[5]
        }
    
    def _actualizar_estado_lotes_vencidos(self, ids_lotes: List[int]) -> None:
        """
        Actualiza el estado de múltiples lotes a 'vencido'
        
        Args:
            ids_lotes: Lista de IDs de lotes a actualizar
        """
        if not ids_lotes:
            return
        
        try:
            query = """
                UPDATE lote_agroquimico
                SET estado = 'vencido',
                    fecha_ultima_modificacion = NOW()
                WHERE id_lote IN :ids_lotes
            """
            
            self.db.execute(query, {'ids_lotes': tuple(ids_lotes)})
            self.db.commit()
            
        except Exception as e:
            self.db.rollback()
            print(f"Error al actualizar lotes vencidos: {str(e)}")
    
    def _registrar_movimiento(self, id_lote: int, tipo_movimiento: str, 
                             cantidad: float, id_tratamiento: Optional[int] = None) -> None:
        """
        Registra un movimiento de inventario (si existe tabla de movimientos)
        
        Args:
            id_lote: ID del lote
            tipo_movimiento: Tipo (entrada, salida, ajuste)
            cantidad: Cantidad del movimiento
            id_tratamiento: ID del tratamiento relacionado (opcional)
        """
        try:
            # Solo registrar si existe la tabla movimiento_inventario
            query = """
                INSERT INTO movimiento_inventario (
                    id_lote,
                    tipo_movimiento,
                    cantidad,
                    id_tratamiento,
                    fecha_movimiento
                ) VALUES (
                    :id_lote,
                    :tipo_movimiento,
                    :cantidad,
                    :id_tratamiento,
                    NOW()
                )
            """
            
            self.db.execute(query, {
                'id_lote': id_lote,
                'tipo_movimiento': tipo_movimiento,
                'cantidad': cantidad,
                'id_tratamiento': id_tratamiento
            })
            
        except Exception:
            # Si la tabla no existe, simplemente ignorar
            pass
