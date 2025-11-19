# backend/repositories/AgroquimicosRep/producto_repositorio.py
"""
Repositorio para gestión de productos agroquímicos
Incluye funcionalidades de inventario y alertas de stock
"""

from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session


class ProductoRepositorio:
    """
    Repositorio para gestionar productos agroquímicos
    """
    
    def __init__(self, db_session: Session):
        """
        Inicializa el repositorio con una sesión de base de datos
        
        Args:
            db_session: Sesión de SQLAlchemy
        """
        self.db = db_session
    
    def crear_producto(self, datos_producto: Dict[str, Any]) -> Dict[str, Any]:
        """
        Crea un nuevo producto agroquímico
        
        Args:
            datos_producto: Diccionario con los datos del producto
            
        Returns:
            Diccionario con los datos del producto creado
        """
        try:
            query = """
                INSERT INTO producto (
                    nombre_comercial,
                    ingrediente_activo,
                    id_categoria,
                    concentracion,
                    unidad_medida,
                    fabricante,
                    registro_sanitario,
                    modo_accion,
                    dosis_recomendada,
                    intervalo_seguridad,
                    observaciones,
                    estado
                ) VALUES (
                    :nombre_comercial,
                    :ingrediente_activo,
                    :id_categoria,
                    :concentracion,
                    :unidad_medida,
                    :fabricante,
                    :registro_sanitario,
                    :modo_accion,
                    :dosis_recomendada,
                    :intervalo_seguridad,
                    :observaciones,
                    'activo'
                )
                RETURNING id_producto, nombre_comercial, ingrediente_activo, id_categoria
            """
            
            resultado = self.db.execute(query, datos_producto).fetchone()
            self.db.commit()
            
            return {
                'id_producto': resultado[0],
                'nombre_comercial': resultado[1],
                'ingrediente_activo': resultado[2],
                'id_categoria': resultado[3]
            }
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Error al crear producto: {str(e)}")
    
    def obtener_producto_por_id(self, id_producto: int) -> Optional[Dict[str, Any]]:
        """
        Obtiene un producto por su ID
        
        Args:
            id_producto: ID del producto
            
        Returns:
            Diccionario con los datos del producto o None si no existe
        """
        query = """
            SELECT 
                p.id_producto,
                p.nombre_comercial,
                p.ingrediente_activo,
                p.id_categoria,
                c.nombre_categoria,
                p.concentracion,
                p.unidad_medida,
                p.fabricante,
                p.registro_sanitario,
                p.modo_accion,
                p.dosis_recomendada,
                p.intervalo_seguridad,
                p.observaciones,
                p.estado
            FROM producto p
            LEFT JOIN categoria c ON p.id_categoria = c.id_categoria
            WHERE p.id_producto = :id_producto
        """
        
        resultado = self.db.execute(query, {'id_producto': id_producto}).fetchone()
        
        if not resultado:
            return None
        
        return {
            'id_producto': resultado[0],
            'nombre_comercial': resultado[1],
            'ingrediente_activo': resultado[2],
            'id_categoria': resultado[3],
            'nombre_categoria': resultado[4],
            'concentracion': resultado[5],
            'unidad_medida': resultado[6],
            'fabricante': resultado[7],
            'registro_sanitario': resultado[8],
            'modo_accion': resultado[9],
            'dosis_recomendada': resultado[10],
            'intervalo_seguridad': resultado[11],
            'observaciones': resultado[12],
            'estado': resultado[13]
        }
    
    def listar_productos(self, filtros: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """
        Lista productos con filtros opcionales
        
        Args:
            filtros: Diccionario con filtros opcionales (id_categoria, estado, etc.)
            
        Returns:
            Lista de productos
        """
        query = """
            SELECT 
                p.id_producto,
                p.nombre_comercial,
                p.ingrediente_activo,
                p.id_categoria,
                c.nombre_categoria,
                p.fabricante,
                p.estado
            FROM producto p
            LEFT JOIN categoria c ON p.id_categoria = c.id_categoria
            WHERE 1=1
        """
        
        params = {}
        
        if filtros:
            if 'id_categoria' in filtros:
                query += " AND p.id_categoria = :id_categoria"
                params['id_categoria'] = filtros['id_categoria']
            
            if 'estado' in filtros:
                query += " AND p.estado = :estado"
                params['estado'] = filtros['estado']
            
            if 'busqueda' in filtros:
                query += """ AND (p.nombre_comercial LIKE :busqueda 
                             OR p.ingrediente_activo LIKE :busqueda)"""
                params['busqueda'] = f"%{filtros['busqueda']}%"
        
        query += " ORDER BY p.nombre_comercial ASC"
        
        resultados = self.db.execute(query, params).fetchall()
        
        return [
            {
                'id_producto': r[0],
                'nombre_comercial': r[1],
                'ingrediente_activo': r[2],
                'id_categoria': r[3],
                'nombre_categoria': r[4],
                'fabricante': r[5],
                'estado': r[6]
            }
            for r in resultados
        ]
    
    def actualizar_producto(self, id_producto: int, 
                           datos_actualizados: Dict[str, Any]) -> bool:
        """
        Actualiza los datos de un producto
        
        Args:
            id_producto: ID del producto a actualizar
            datos_actualizados: Diccionario con los campos a actualizar
            
        Returns:
            True si se actualizó correctamente
        """
        try:
            # Construir query dinámica según campos a actualizar
            campos = []
            params = {'id_producto': id_producto}
            
            campos_permitidos = [
                'nombre_comercial', 'ingrediente_activo', 'id_categoria',
                'concentracion', 'unidad_medida', 'fabricante',
                'registro_sanitario', 'modo_accion', 'dosis_recomendada',
                'intervalo_seguridad', 'observaciones', 'estado'
            ]
            
            for campo in campos_permitidos:
                if campo in datos_actualizados:
                    campos.append(f"{campo} = :{campo}")
                    params[campo] = datos_actualizados[campo]
            
            if not campos:
                return False
            
            query = f"""
                UPDATE producto
                SET {', '.join(campos)},
                    fecha_ultima_modificacion = NOW()
                WHERE id_producto = :id_producto
            """
            
            self.db.execute(query, params)
            self.db.commit()
            
            return True
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Error al actualizar producto: {str(e)}")
    
    def eliminar_producto(self, id_producto: int, eliminacion_logica: bool = True) -> bool:
        """
        Elimina un producto (lógica o físicamente)
        
        Args:
            id_producto: ID del producto a eliminar
            eliminacion_logica: Si True, solo marca como inactivo; si False, elimina de BD
            
        Returns:
            True si se eliminó correctamente
        """
        try:
            if eliminacion_logica:
                query = """
                    UPDATE producto
                    SET estado = 'inactivo',
                        fecha_ultima_modificacion = NOW()
                    WHERE id_producto = :id_producto
                """
            else:
                query = """
                    DELETE FROM producto
                    WHERE id_producto = :id_producto
                """
            
            self.db.execute(query, {'id_producto': id_producto})
            self.db.commit()
            
            return True
            
        except Exception as e:
            self.db.rollback()
            raise Exception(f"Error al eliminar producto: {str(e)}")
    
    # ==================== NUEVOS MÉTODOS PARA INVENTARIO ====================
    
    def obtener_producto_con_stock(self, id_producto: int) -> Optional[Dict[str, Any]]:
        """
        Obtiene un producto con su información de stock actual
        
        Args:
            id_producto: ID del producto
            
        Returns:
            Diccionario con datos del producto y su stock
        """
        query = """
            SELECT 
                p.id_producto,
                p.nombre_comercial,
                p.ingrediente_activo,
                p.id_categoria,
                c.nombre_categoria,
                p.fabricante,
                p.unidad_medida,
                COALESCE(SUM(l.cantidad_actual), 0) as stock_total,
                COUNT(CASE WHEN l.cantidad_actual > 0 THEN 1 END) as lotes_disponibles,
                MIN(l.fecha_vencimiento) as proxima_fecha_vencimiento,
                MIN(DATEDIFF(l.fecha_vencimiento, CURDATE())) as dias_minimo_vencer
            FROM producto p
            LEFT JOIN categoria c ON p.id_categoria = c.id_categoria
            LEFT JOIN lote_agroquimico l ON p.id_producto = l.id_producto 
                AND l.cantidad_actual > 0 
                AND l.estado = 'activo'
            WHERE p.id_producto = :id_producto
            GROUP BY p.id_producto, p.nombre_comercial, p.ingrediente_activo,
                     p.id_categoria, c.nombre_categoria, p.fabricante, p.unidad_medida
        """
        
        resultado = self.db.execute(query, {'id_producto': id_producto}).fetchone()
        
        if not resultado:
            return None
        
        return {
            'id_producto': resultado[0],
            'nombre_comercial': resultado[1],
            'ingrediente_activo': resultado[2],
            'id_categoria': resultado[3],
            'nombre_categoria': resultado[4],
            'fabricante': resultado[5],
            'unidad_medida': resultado[6],
            'stock_total': float(resultado[7]),
            'lotes_disponibles': resultado[8],
            'proxima_fecha_vencimiento': resultado[9],
            'dias_minimo_vencer': resultado[10] if resultado[10] is not None else None
        }
    
    def listar_productos_con_stock(self, filtros: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """
        Lista todos los productos con su información de stock
        
        Args:
            filtros: Filtros opcionales (id_categoria, con_stock, etc.)
            
        Returns:
            Lista de productos con información de stock
        """
        query = """
            SELECT 
                p.id_producto,
                p.nombre_comercial,
                p.ingrediente_activo,
                p.id_categoria,
                c.nombre_categoria,
                p.unidad_medida,
                COALESCE(SUM(l.cantidad_actual), 0) as stock_total,
                COUNT(CASE WHEN l.cantidad_actual > 0 THEN 1 END) as lotes_disponibles,
                MIN(DATEDIFF(l.fecha_vencimiento, CURDATE())) as dias_minimo_vencer
            FROM producto p
            LEFT JOIN categoria c ON p.id_categoria = c.id_categoria
            LEFT JOIN lote_agroquimico l ON p.id_producto = l.id_producto 
                AND l.cantidad_actual > 0 
                AND l.estado = 'activo'
            WHERE p.estado = 'activo'
        """
        
        params = {}
        
        if filtros:
            if 'id_categoria' in filtros:
                query += " AND p.id_categoria = :id_categoria"
                params['id_categoria'] = filtros['id_categoria']
            
            if 'con_stock' in filtros and filtros['con_stock']:
                query += " HAVING stock_total > 0"
        
        query += """
            GROUP BY p.id_producto, p.nombre_comercial, p.ingrediente_activo,
                     p.id_categoria, c.nombre_categoria, p.unidad_medida
            ORDER BY p.nombre_comercial ASC
        """
        
        resultados = self.db.execute(query, params).fetchall()
        
        return [
            {
                'id_producto': r[0],
                'nombre_comercial': r[1],
                'ingrediente_activo': r[2],
                'id_categoria': r[3],
                'nombre_categoria': r[4],
                'unidad_medida': r[5],
                'stock_total': float(r[6]),
                'lotes_disponibles': r[7],
                'dias_minimo_vencer': r[8] if r[8] is not None else None
            }
            for r in resultados
        ]
    
    def listar_productos_con_alertas(self, 
                                     dias_vencimiento: int = 30,
                                     umbral_stock: float = 20.0) -> Dict[str, List[Dict[str, Any]]]:
        """
        Lista productos que tienen alertas de stock bajo o próximos a vencer
        
        Args:
            dias_vencimiento: Días de anticipación para alerta de vencimiento
            umbral_stock: Porcentaje bajo el cual se considera stock bajo
            
        Returns:
            Diccionario con listas de productos por tipo de alerta
        """
        # Productos con lotes próximos a vencer
        query_vencimiento = """
            SELECT DISTINCT
                p.id_producto,
                p.nombre_comercial,
                p.ingrediente_activo,
                COUNT(DISTINCT l.id_lote) as lotes_por_vencer,
                MIN(l.fecha_vencimiento) as fecha_vencimiento_mas_proxima,
                MIN(DATEDIFF(l.fecha_vencimiento, CURDATE())) as dias_minimo
            FROM producto p
            INNER JOIN lote_agroquimico l ON p.id_producto = l.id_producto
            WHERE l.cantidad_actual > 0
            AND l.estado = 'activo'
            AND DATEDIFF(l.fecha_vencimiento, CURDATE()) <= :dias
            AND DATEDIFF(l.fecha_vencimiento, CURDATE()) >= 0
            GROUP BY p.id_producto, p.nombre_comercial, p.ingrediente_activo
            ORDER BY dias_minimo ASC
        """
        
        productos_por_vencer = self.db.execute(
            query_vencimiento, 
            {'dias': dias_vencimiento}
        ).fetchall()
        
        # Productos con stock bajo
        query_stock_bajo = """
            SELECT DISTINCT
                p.id_producto,
                p.nombre_comercial,
                p.ingrediente_activo,
                COUNT(DISTINCT l.id_lote) as lotes_con_stock_bajo,
                SUM(l.cantidad_actual) as stock_total,
                MIN(ROUND((l.cantidad_actual / l.cantidad_inicial) * 100, 2)) as porcentaje_minimo
            FROM producto p
            INNER JOIN lote_agroquimico l ON p.id_producto = l.id_producto
            WHERE l.cantidad_actual > 0
            AND l.estado = 'activo'
            AND (l.cantidad_actual / l.cantidad_inicial) * 100 <= :umbral
            GROUP BY p.id_producto, p.nombre_comercial, p.ingrediente_activo
            ORDER BY porcentaje_minimo ASC
        """
        
        productos_stock_bajo = self.db.execute(
            query_stock_bajo,
            {'umbral': umbral_stock}
        ).fetchall()
        
        # Productos sin stock
        query_sin_stock = """
            SELECT 
                p.id_producto,
                p.nombre_comercial,
                p.ingrediente_activo,
                COALESCE(SUM(l.cantidad_actual), 0) as stock_total
            FROM producto p
            LEFT JOIN lote_agroquimico l ON p.id_producto = l.id_producto 
                AND l.cantidad_actual > 0
            WHERE p.estado = 'activo'
            GROUP BY p.id_producto, p.nombre_comercial, p.ingrediente_activo
            HAVING stock_total = 0
            ORDER BY p.nombre_comercial ASC
        """
        
        productos_sin_stock = self.db.execute(query_sin_stock).fetchall()
        
        return {
            'productos_por_vencer': [
                {
                    'id_producto': r[0],
                    'nombre_comercial': r[1],
                    'ingrediente_activo': r[2],
                    'lotes_por_vencer': r[3],
                    'fecha_vencimiento_mas_proxima': r[4],
                    'dias_minimo': r[5],
                    'nivel_alerta': 'critico' if r[5] <= 7 else 'alto' if r[5] <= 15 else 'medio'
                }
                for r in productos_por_vencer
            ],
            'productos_stock_bajo': [
                {
                    'id_producto': r[0],
                    'nombre_comercial': r[1],
                    'ingrediente_activo': r[2],
                    'lotes_con_stock_bajo': r[3],
                    'stock_total': float(r[4]),
                    'porcentaje_minimo': float(r[5]),
                    'nivel_alerta': 'critico' if r[5] <= 10 else 'alto' if r[5] <= 20 else 'medio'
                }
                for r in productos_stock_bajo
            ],
            'productos_sin_stock': [
                {
                    'id_producto': r[0],
                    'nombre_comercial': r[1],
                    'ingrediente_activo': r[2],
                    'stock_total': float(r[3]),
                    'nivel_alerta': 'critico'
                }
                for r in productos_sin_stock
            ]
        }
    
    def obtener_productos_mas_usados(self, limite: int = 10) -> List[Dict[str, Any]]:
        """
        Obtiene los productos más utilizados en tratamientos
        
        Args:
            limite: Número de productos a retornar
            
        Returns:
            Lista de productos más usados con cantidad total consumida
        """
        query = """
            SELECT 
                p.id_producto,
                p.nombre_comercial,
                p.ingrediente_activo,
                COUNT(DISTINCT td.id_tratamiento) as total_tratamientos,
                SUM(td.cantidad_usada) as cantidad_total_usada,
                p.unidad_medida
            FROM producto p
            INNER JOIN mezcla_detalle md ON p.id_producto = md.id_producto
            INNER JOIN tratamiento t ON md.id_mezcla = t.id_mezcla
            INNER JOIN tratamiento_detalle td ON t.id_tratamiento = td.id_tratamiento
            WHERE t.estado = 'completado'
            GROUP BY p.id_producto, p.nombre_comercial, p.ingrediente_activo, p.unidad_medida
            ORDER BY cantidad_total_usada DESC
            LIMIT :limite
        """
        
        resultados = self.db.execute(query, {'limite': limite}).fetchall()
        
        return [
            {
                'id_producto': r[0],
                'nombre_comercial': r[1],
                'ingrediente_activo': r[2],
                'total_tratamientos': r[3],
                'cantidad_total_usada': float(r[4]),
                'unidad_medida': r[5]
            }
            for r in resultados
        ]
