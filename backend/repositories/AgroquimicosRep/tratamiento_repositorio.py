# backend/repositories/AgroquimicosRep/tratamiento_repositorio.py
"""
Repositorio para gestión de tratamientos agroquímicos
Incluye integración con inventario de lotes
"""

from typing import List, Optional, Dict, Any
from datetime import datetime
from backend.core.repositorio_base import RepositorioBase



class TratamientoRepositorio:
    """
    Repositorio para gestionar tratamientos de cultivos con agroquímicos
    """
    
    def __init__(self, RepositorioBase):
        """
        Inicializa el repositorio con una sesión de base de datos
        
        Args:
            db_session: Sesión de SQLAlchemy
        """
        self.db = db_session
    
    def crear_tratamiento(self, datos_tratamiento: Dict[str, Any], 
                         lote_repositorio=None) -> Dict[str, Any]:
        """
        Crea un nuevo tratamiento y descuenta del inventario
        
        Args:
            datos_tratamiento: Diccionario con datos del tratamiento
                - id_lote_agricola: ID del lote agrícola donde se aplica
                - id_mezcla: ID de la mezcla a aplicar
                - fecha_aplicacion: Fecha de aplicación
                - area_tratada: Área tratada (hectáreas)
                - dosis_aplicada: Dosis aplicada
                - metodo_aplicacion: Método (aspersión, goteo, etc.)
                - condiciones_climaticas: Condiciones al aplicar
                - responsable: Responsable de la aplicación
                - detalles_productos: Lista con productos y lotes a usar
                    [{id_producto, id_lote, cantidad_usada, unidad_medida}]
            lote_repositorio: Instancia de LoteAgroquimicoRepositorio (opcional)
            
        Returns:
            Diccionario con los datos del tratamiento creado
        """
        try:
            # Validar stock disponible ANTES de crear el tratamiento
            if 'detalles_productos' in datos_tratamiento and lote_repositorio:
                self._validar_stock_disponible(
                    datos_tratamiento['detalles_productos'],
                    lote_repositorio
                )
            
            # Crear el registro del tratamiento
            query_tratamiento = """
                INSERT INTO tratamiento (
                    id_lote,
                    id_mezcla,
                    fecha_aplicacion,
                    area_tratada,
                    dosis_aplicada,
                    metodo_aplicacion,
                    condiciones_climaticas,
                    responsable,
                    estado,
                    fecha_registro
                ) VALUES (
                    :id_lote_agricola,
                    :id_mezcla,
                    :fecha_aplicacion,
                    :area_tratada,
                    :dosis_aplicada,
                    :metodo_aplicacion,
                    :condiciones_climaticas,
                    :responsable,
                    'programado',
                    NOW()
                )
                RETURNING id_tratamiento, id_lote, id_mezcla, fecha_aplicacion, estado
            """
            
            resultado = self.db.execute(query_tratamiento, {
                'id_lote_agricola': datos_tratamiento['id_lote_agricola'],
                'id_mezcla': datos_tratamiento['id_mezcla'],
                'fecha_aplicacion': datos_tratamiento.get('fecha_aplicacion', datetime.now()),
                'area_tratada': datos_tratamiento.get('area_tratada'),
                'dosis_aplicada': datos_tratamiento.get('dosis_aplicada'),
                'metodo_aplicacion': datos_tratamiento.get('metodo_aplicacion'),
                'condiciones_climaticas': datos_tratamiento.get('condiciones_climaticas'),
                'responsable': datos_tratamiento.get('responsable')
            }).fetchone()
            
            id_tratamiento = resultado[0]
            
            # Crear detalles del tratamiento y descontar del inventario
            if 'detalles_productos' in datos_tratamiento:
                self._crear_detalles_tratamiento(
                    id_tratamiento=id_tratamiento,
                    detalles=datos_tratamiento['detalles_productos'],
                    lote_repositorio=lote_repositorio
                )
            
            self.db.commit()
            
            return {
                'id_tratamiento': resultado[0],
                'id_lote_agricola': resultado[1],
                'id_mezcla': resultado[2],
                'fecha_aplicacion': resultado[3],
                'estado': resultado[4]
            }
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Error al crear tratamiento: {str(e)}")
    
    def obtener_tratamiento_por_id(self, id_tratamiento: int) -> Optional[Dict[str, Any]]:
        """
        Obtiene un tratamiento completo por su ID
        
        Args:
            id_tratamiento: ID del tratamiento
            
        Returns:
            Diccionario con datos completos del tratamiento
        """
        query = """
            SELECT 
                t.id_tratamiento,
                t.id_lote as id_lote_agricola,
                l.nombre_lote as nombre_lote_agricola,
                t.id_mezcla,
                m.nombre_mezcla,
                t.fecha_aplicacion,
                t.area_tratada,
                t.dosis_aplicada,
                t.metodo_aplicacion,
                t.condiciones_climaticas,
                t.responsable,
                t.estado,
                t.observaciones
            FROM tratamiento t
            INNER JOIN lote l ON t.id_lote = l.id_lote
            LEFT JOIN mezcla m ON t.id_mezcla = m.id_mezcla
            WHERE t.id_tratamiento = :id_tratamiento
        """
        
        resultado = self.db.execute(query, {'id_tratamiento': id_tratamiento}).fetchone()
        
        if not resultado:
            return None
        
        # Obtener detalles de productos usados
        detalles = self._obtener_detalles_tratamiento(id_tratamiento)
        
        return {
            'id_tratamiento': resultado[0],
            'id_lote_agricola': resultado[1],
            'nombre_lote_agricola': resultado[2],
            'id_mezcla': resultado[3],
            'nombre_mezcla': resultado[4],
            'fecha_aplicacion': resultado[5],
            'area_tratada': float(resultado[6]) if resultado[6] else None,
            'dosis_aplicada': float(resultado[7]) if resultado[7] else None,
            'metodo_aplicacion': resultado[8],
            'condiciones_climaticas': resultado[9],
            'responsable': resultado[10],
            'estado': resultado[11],
            'observaciones': resultado[12],
            'productos_usados': detalles
        }
    
    def listar_tratamientos(self, filtros: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """
        Lista tratamientos con filtros opcionales
        
        Args:
            filtros: Diccionario con filtros opcionales
                - id_lote_agricola: Filtrar por lote agrícola
                - fecha_desde: Fecha inicio
                - fecha_hasta: Fecha fin
                - estado: Estado del tratamiento
                
        Returns:
            Lista de tratamientos
        """
        query = """
            SELECT 
                t.id_tratamiento,
                t.id_lote as id_lote_agricola,
                l.nombre_lote as nombre_lote_agricola,
                t.id_mezcla,
                m.nombre_mezcla,
                t.fecha_aplicacion,
                t.area_tratada,
                t.responsable,
                t.estado
            FROM tratamiento t
            INNER JOIN lote l ON t.id_lote = l.id_lote
            LEFT JOIN mezcla m ON t.id_mezcla = m.id_mezcla
            WHERE 1=1
        """
        
        params = {}
        
        if filtros:
            if 'id_lote_agricola' in filtros:
                query += " AND t.id_lote = :id_lote_agricola"
                params['id_lote_agricola'] = filtros['id_lote_agricola']
            
            if 'fecha_desde' in filtros:
                query += " AND t.fecha_aplicacion >= :fecha_desde"
                params['fecha_desde'] = filtros['fecha_desde']
            
            if 'fecha_hasta' in filtros:
                query += " AND t.fecha_aplicacion <= :fecha_hasta"
                params['fecha_hasta'] = filtros['fecha_hasta']
            
            if 'estado' in filtros:
                query += " AND t.estado = :estado"
                params['estado'] = filtros['estado']
        
        query += " ORDER BY t.fecha_aplicacion DESC"
        
        resultados = self.db.execute(query, params).fetchall()
        
        return [
            {
                'id_tratamiento': r[0],
                'id_lote_agricola': r[1],
                'nombre_lote_agricola': r[2],
                'id_mezcla': r[3],
                'nombre_mezcla': r[4],
                'fecha_aplicacion': r[5],
                'area_tratada': float(r[6]) if r[6] else None,
                'responsable': r[7],
                'estado': r[8]
            }
            for r in resultados
        ]
    
    def actualizar_estado_tratamiento(self, id_tratamiento: int, 
                                     nuevo_estado: str) -> bool:
        """
        Actualiza el estado de un tratamiento
        
        Args:
            id_tratamiento: ID del tratamiento
            nuevo_estado: Nuevo estado (programado, en_proceso, completado, cancelado)
            
        Returns:
            True si se actualizó correctamente
        """
        try:
            query = """
                UPDATE tratamiento
                SET estado = :nuevo_estado,
                    fecha_ultima_modificacion = NOW()
                WHERE id_tratamiento = :id_tratamiento
            """
            
            self.db.execute(query, {
                'nuevo_estado': nuevo_estado,
                'id_tratamiento': id_tratamiento
            })
            
            self.db.commit()
            return True
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Error al actualizar estado del tratamiento: {str(e)}")
    
    def completar_tratamiento(self, id_tratamiento: int, 
                             observaciones: Optional[str] = None) -> bool:
        """
        Marca un tratamiento como completado
        
        Args:
            id_tratamiento: ID del tratamiento
            observaciones: Observaciones finales (opcional)
            
        Returns:
            True si se completó correctamente
        """
        try:
            query = """
                UPDATE tratamiento
                SET estado = 'completado',
                    observaciones = :observaciones,
                    fecha_ultima_modificacion = NOW()
                WHERE id_tratamiento = :id_tratamiento
            """
            
            self.db.execute(query, {
                'observaciones': observaciones,
                'id_tratamiento': id_tratamiento
            })
            
            self.db.commit()
            return True
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Error al completar tratamiento: {str(e)}")
    
    def cancelar_tratamiento(self, id_tratamiento: int, 
                            motivo: str,
                            devolver_stock: bool = True,
                            lote_repositorio=None) -> bool:
        """
        Cancela un tratamiento y opcionalmente devuelve el stock al inventario
        
        Args:
            id_tratamiento: ID del tratamiento
            motivo: Motivo de la cancelación
            devolver_stock: Si True, devuelve las cantidades al inventario
            lote_repositorio: Instancia de LoteAgroquimicoRepositorio (requerido si devolver_stock=True)
            
        Returns:
            True si se canceló correctamente
        """
        try:
            # Si se debe devolver stock, obtener los productos usados
            if devolver_stock and lote_repositorio:
                detalles = self._obtener_detalles_tratamiento(id_tratamiento)
                
                # Devolver cantidades al inventario
                for detalle in detalles:
                    if detalle['id_lote_agroquimico']:
                        self._devolver_cantidad_lote(
                            id_lote=detalle['id_lote_agroquimico'],
                            cantidad=detalle['cantidad_usada'],
                            lote_repositorio=lote_repositorio
                        )
            
            # Actualizar estado del tratamiento
            query = """
                UPDATE tratamiento
                SET estado = 'cancelado',
                    observaciones = CONCAT(COALESCE(observaciones, ''), 
                                         ' [CANCELADO: ', :motivo, ']'),
                    fecha_ultima_modificacion = NOW()
                WHERE id_tratamiento = :id_tratamiento
            """
            
            self.db.execute(query, {
                'motivo': motivo,
                'id_tratamiento': id_tratamiento
            })
            
            self.db.commit()
            return True
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Error al cancelar tratamiento: {str(e)}")
    
    def obtener_historial_tratamientos_lote(self, id_lote_agricola: int) -> List[Dict[str, Any]]:
        """
        Obtiene el historial completo de tratamientos de un lote agrícola
        
        Args:
            id_lote_agricola: ID del lote agrícola
            
        Returns:
            Lista de tratamientos aplicados al lote
        """
        return self.listar_tratamientos({'id_lote_agricola': id_lote_agricola})
    
    # ==================== MÉTODOS PRIVADOS ====================
    
    def _validar_stock_disponible(self, detalles: List[Dict[str, Any]], 
                                  lote_repositorio) -> None:
        """
        Valida que haya stock suficiente antes de crear el tratamiento
        
        Args:
            detalles: Lista de productos a usar
            lote_repositorio: Repositorio de lotes
            
        Raises:
            ValueError: Si no hay stock suficiente
        """
        for detalle in detalles:
            lote = lote_repositorio.obtener_lote_por_id(detalle['id_lote'])
            
            if not lote:
                raise ValueError(
                    f"Lote {detalle['id_lote']} no encontrado"
                )
            
            if lote['cantidad_actual'] < detalle['cantidad_usada']:
                raise ValueError(
                    f"Stock insuficiente para {lote['nombre_producto']}. "
                    f"Disponible: {lote['cantidad_actual']} {lote['unidad_medida']}, "
                    f"Solicitado: {detalle['cantidad_usada']}"
                )
    
    def _crear_detalles_tratamiento(self, id_tratamiento: int, 
                                    detalles: List[Dict[str, Any]],
                                    lote_repositorio=None) -> None:
        """
        Crea los detalles del tratamiento y descuenta del inventario
        
        Args:
            id_tratamiento: ID del tratamiento
            detalles: Lista de productos usados
            lote_repositorio: Repositorio de lotes
        """
        for detalle in detalles:
            # Insertar detalle del tratamiento
            query = """
                INSERT INTO tratamiento_detalle (
                    id_tratamiento,
                    id_producto,
                    id_lote_agroquimico,
                    cantidad_usada,
                    unidad_medida
                ) VALUES (
                    :id_tratamiento,
                    :id_producto,
                    :id_lote,
                    :cantidad_usada,
                    :unidad_medida
                )
            """
            
            self.db.execute(query, {
                'id_tratamiento': id_tratamiento,
                'id_producto': detalle['id_producto'],
                'id_lote': detalle['id_lote'],
                'cantidad_usada': detalle['cantidad_usada'],
                'unidad_medida': detalle['unidad_medida']
            })
            
            # Descontar del lote en inventario
            if lote_repositorio:
                lote_repositorio.descontar_cantidad(
                    id_lote=detalle['id_lote'],
                    cantidad=detalle['cantidad_usada'],
                    id_tratamiento=id_tratamiento
                )
    
    def _obtener_detalles_tratamiento(self, id_tratamiento: int) -> List[Dict[str, Any]]:
        """
        Obtiene los detalles de productos usados en un tratamiento
        
        Args:
            id_tratamiento: ID del tratamiento
            
        Returns:
            Lista de productos usados con sus cantidades
        """
        query = """
            SELECT 
                td.id_detalle,
                td.id_producto,
                p.nombre_comercial,
                td.id_lote_agroquimico,
                la.numero_lote,
                td.cantidad_usada,
                td.unidad_medida
            FROM tratamiento_detalle td
            INNER JOIN producto p ON td.id_producto = p.id_producto
            LEFT JOIN lote_agroquimico la ON td.id_lote_agroquimico = la.id_lote
            WHERE td.id_tratamiento = :id_tratamiento
            ORDER BY td.id_detalle
        """
        
        resultados = self.db.execute(query, {'id_tratamiento': id_tratamiento}).fetchall()
        
        return [
            {
                'id_detalle': r[0],
                'id_producto': r[1],
                'nombre_producto': r[2],
                'id_lote_agroquimico': r[3],
                'numero_lote': r[4],
                'cantidad_usada': float(r[5]),
                'unidad_medida': r[6]
            }
            for r in resultados
        ]
    
    def _devolver_cantidad_lote(self, id_lote: int, cantidad: float, 
                               lote_repositorio) -> None:
        """
        Devuelve cantidad al lote en caso de cancelación
        
        Args:
            id_lote: ID del lote
            cantidad: Cantidad a devolver
            lote_repositorio: Repositorio de lotes
        """
        try:
            query = """
                UPDATE lote_agroquimico
                SET cantidad_actual = cantidad_actual + :cantidad,
                    estado = CASE 
                        WHEN estado = 'agotado' AND (cantidad_actual + :cantidad) > 0 
                        THEN 'activo' 
                        ELSE estado 
                    END,
                    fecha_ultima_modificacion = NOW()
                WHERE id_lote = :id_lote
            """
            
            self.db.execute(query, {
                'cantidad': cantidad,
                'id_lote': id_lote
            })
            
        except Exception as e:
            raise Exception(f"Error al devolver cantidad al lote: {str(e)}")
    
    def obtener_consumo_por_producto(self, 
                                    fecha_desde: Optional[datetime] = None,
                                    fecha_hasta: Optional[datetime] = None) -> List[Dict[str, Any]]:
        """
        Obtiene el consumo total por producto en un rango de fechas
        
        Args:
            fecha_desde: Fecha inicial (opcional)
            fecha_hasta: Fecha final (opcional)
            
        Returns:
            Lista con consumo por producto
        """
        query = """
            SELECT 
                p.id_producto,
                p.nombre_comercial,
                p.ingrediente_activo,
                COUNT(DISTINCT t.id_tratamiento) as total_tratamientos,
                SUM(td.cantidad_usada) as cantidad_total_consumida,
                td.unidad_medida,
                MIN(t.fecha_aplicacion) as primera_aplicacion,
                MAX(t.fecha_aplicacion) as ultima_aplicacion
            FROM tratamiento_detalle td
            INNER JOIN tratamiento t ON td.id_tratamiento = t.id_tratamiento
            INNER JOIN producto p ON td.id_producto = p.id_producto
            WHERE t.estado = 'completado'
        """
        
        params = {}
        
        if fecha_desde:
            query += " AND t.fecha_aplicacion >= :fecha_desde"
            params['fecha_desde'] = fecha_desde
        
        if fecha_hasta:
            query += " AND t.fecha_aplicacion <= :fecha_hasta"
            params['fecha_hasta'] = fecha_hasta
        
        query += """
            GROUP BY p.id_producto, p.nombre_comercial, p.ingrediente_activo, td.unidad_medida
            ORDER BY cantidad_total_consumida DESC
        """
        
        resultados = self.db.execute(query, params).fetchall()
        
        return [
            {
                'id_producto': r[0],
                'nombre_comercial': r[1],
                'ingrediente_activo': r[2],
                'total_tratamientos': r[3],
                'cantidad_total_consumida': float(r[4]),
                'unidad_medida': r[5],
                'primera_aplicacion': r[6],
                'ultima_aplicacion': r[7]
            }
            for r in resultados
        ]
