"""
Repositorio para gestión de Compras de Combustible
Maneja todas las operaciones CRUD de la tabla ComprasCombustible
"""

import logging
from typing import List, Dict, Optional, Tuple
from datetime import datetime, date
from backend.core.repositorio_base import RepositorioBase
from backend.core.repositorio_base import ErrorConsulta
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)


class CompraCombustibleRepositorio(RepositorioBase):
    """
    Repositorio para la gestión de compras de combustible.
    
    Tabla: ComprasCombustible
    Columnas: id_compra, id_proveedor, tipo_combustible, fecha_compra,
              cantidad, unidad_medida, precio_unitario, precio_total,
              responsable, observaciones
    """
    
    def __init__(self):
        super().__init__()
        self.tabla = "ComprasCombustible"
        logger.info("CompraCombustibleRepositorio inicializado")
    
    def _formatear_fecha(self, fecha_valor) -> Optional[str]:
        """Convierte diferentes formatos de fecha a string YYYY-MM-DD"""
        if fecha_valor is None:
            return None
        
        if isinstance(fecha_valor, str):
            if not fecha_valor.strip():
                return None
            try:
                datetime.strptime(fecha_valor.strip(), '%Y-%m-%d')
                return fecha_valor.strip()
            except ValueError:
                logger.warning(f"Formato de fecha inválido: {fecha_valor}")
                return None
        
        if isinstance(fecha_valor, (datetime, date)):
            return fecha_valor.strftime('%Y-%m-%d')
        
        return None
    
    @cacheable('combustible', ttl=get_ttl('combustible'))
    def obtener_todos(self, filtros: Optional[Dict] = None) -> List[Dict]:
        """
        Obtiene todas las compras de combustible.
        
        Args:
            filtros: Diccionario opcional con filtros
                - tipo_combustible: Tipo de combustible
                - fecha_desde: Fecha inicial
                - fecha_hasta: Fecha final
                - id_proveedor: ID del proveedor
                
        Returns:
            Lista de diccionarios con información de compras
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_compra, c.id_proveedor, c.tipo_combustible, c.fecha_compra,
                       c.cantidad, c.unidad_medida, c.precio_unitario, c.precio_total,
                       c.responsable, c.observaciones,
                       p.nombre as proveedor_nombre,
                       emp.nombre as responsable_nombre, emp.apellido as responsable_apellido
                FROM ComprasCombustible c
                LEFT JOIN Proveedores p ON c.id_proveedor = p.id_proveedor
                INNER JOIN Empleados emp ON c.responsable = emp.id_empleado
                WHERE 1=1
                """
                
                valores = []
                
                if filtros:
                    if 'tipo_combustible' in filtros and filtros['tipo_combustible']:
                        query += " AND c.tipo_combustible = ?"
                        valores.append(filtros['tipo_combustible'])
                    
                    if 'fecha_desde' in filtros and filtros['fecha_desde']:
                        query += " AND c.fecha_compra >= ?"
                        valores.append(self._formatear_fecha(filtros['fecha_desde']))
                    
                    if 'fecha_hasta' in filtros and filtros['fecha_hasta']:
                        query += " AND c.fecha_compra <= ?"
                        valores.append(self._formatear_fecha(filtros['fecha_hasta']))
                    
                    if 'id_proveedor' in filtros and filtros['id_proveedor']:
                        query += " AND c.id_proveedor = ?"
                        valores.append(filtros['id_proveedor'])
                
                query += " ORDER BY c.fecha_compra DESC, c.id_compra DESC"
                
                cursor.execute(query, valores)
                
                compras = []
                for row in cursor.fetchall():
                    compra = {
                        'id_compra': int(row.id_compra),
                        'id_proveedor': int(row.id_proveedor) if row.id_proveedor else None,
                        'tipo_combustible': str(row.tipo_combustible).strip(),
                        'fecha_compra': self._formatear_fecha(row.fecha_compra),
                        'cantidad': float(row.cantidad),
                        'unidad_medida': str(row.unidad_medida).strip(),
                        'precio_unitario': float(row.precio_unitario),
                        'precio_total': float(row.precio_total),
                        'responsable': int(row.responsable),
                        'observaciones': str(row.observaciones).strip() if row.observaciones else "",
                        # Campos adicionales de JOIN
                        'proveedor_nombre': str(row.proveedor_nombre).strip() if row.proveedor_nombre else "Sin proveedor",
                        'responsable_nombre': f"{row.responsable_nombre} {row.responsable_apellido}".strip()
                    }
                    compras.append(compra)
                
                logger.info(f"Se obtuvieron {len(compras)} compras de combustible")
                return compras
                
        except Exception as e:
            logger.error(f"Error al obtener compras de combustible: {str(e)}")
            raise ErrorConsulta(f"Error al obtener compras de combustible: {str(e)}")
    
    def obtener_por_id(self, id_compra: int) -> Optional[Dict]:
        """
        Obtiene una compra específica por su ID.
        
        Args:
            id_compra: ID de la compra
            
        Returns:
            Diccionario con datos de la compra o None si no existe
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                SELECT c.id_compra, c.id_proveedor, c.tipo_combustible, c.fecha_compra,
                       c.cantidad, c.unidad_medida, c.precio_unitario, c.precio_total,
                       c.responsable, c.observaciones,
                       p.nombre as proveedor_nombre,
                       emp.nombre as responsable_nombre, emp.apellido as responsable_apellido
                FROM ComprasCombustible c
                LEFT JOIN Proveedores p ON c.id_proveedor = p.id_proveedor
                INNER JOIN Empleados emp ON c.responsable = emp.id_empleado
                WHERE c.id_compra = ?
                """
                
                cursor.execute(query, (id_compra,))
                row = cursor.fetchone()
                
                if not row:
                    logger.warning(f"No se encontró compra con ID: {id_compra}")
                    return None
                
                compra = {
                    'id_compra': int(row.id_compra),
                    'id_proveedor': int(row.id_proveedor) if row.id_proveedor else None,
                    'tipo_combustible': str(row.tipo_combustible).strip(),
                    'fecha_compra': self._formatear_fecha(row.fecha_compra),
                    'cantidad': float(row.cantidad),
                    'unidad_medida': str(row.unidad_medida).strip(),
                    'precio_unitario': float(row.precio_unitario),
                    'precio_total': float(row.precio_total),
                    'responsable': int(row.responsable),
                    'observaciones': str(row.observaciones).strip() if row.observaciones else "",
                    'proveedor_nombre': str(row.proveedor_nombre).strip() if row.proveedor_nombre else "Sin proveedor",
                    'responsable_nombre': f"{row.responsable_nombre} {row.responsable_apellido}".strip()
                }
                
                logger.info(f"Compra obtenida: ID {id_compra}")
                return compra
                
        except Exception as e:
            logger.error(f"Error al obtener compra por ID {id_compra}: {str(e)}")
            raise ErrorConsulta(f"Error al obtener compra: {str(e)}")
    
    @cache_invalidator('combustible')
    @cache_invalidator('estadisticas')
    def crear(self, datos: Dict) -> Tuple[bool, int]:
        """
        Registra una nueva compra de combustible.
        
        Args:
            datos: Diccionario con los datos de la compra
                - tipo_combustible (str, requerido): Tipo de combustible
                - fecha_compra (str, requerido): Fecha YYYY-MM-DD
                - cantidad (float, requerido): Cantidad comprada
                - unidad_medida (str, requerido): Unidad de medida
                - precio_unitario (float, requerido): Precio por unidad
                - responsable (int, requerido): ID del empleado
                - id_proveedor (int, opcional): ID del proveedor
                - observaciones (str, opcional): Observaciones
                
        Returns:
            Tupla (éxito, id_generado)
        """
        try:
            # Validar campos requeridos
            campos_requeridos = ['tipo_combustible', 'fecha_compra', 'cantidad', 
                               'unidad_medida', 'precio_unitario', 'responsable']
            for campo in campos_requeridos:
                if campo not in datos or datos[campo] is None or datos[campo] == '':
                    raise ValueError(f"El campo '{campo}' es requerido")
            
            # Validar valores numéricos
            if float(datos['cantidad']) <= 0:
                raise ValueError("La cantidad debe ser mayor a 0")
            
            if float(datos['precio_unitario']) <= 0:
                raise ValueError("El precio unitario debe ser mayor a 0")
            
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Validar empleado
                cursor.execute("SELECT id_empleado FROM Empleados WHERE id_empleado = ?", 
                             (datos['responsable'],))
                if not cursor.fetchone():
                    raise ValueError(f"No existe empleado con ID: {datos['responsable']}")
                
                # Validar proveedor si se proporciona
                id_proveedor = datos.get('id_proveedor')
                if id_proveedor:
                    cursor.execute("SELECT id_proveedor FROM Proveedores WHERE id_proveedor = ?", 
                                 (id_proveedor,))
                    if not cursor.fetchone():
                        raise ValueError(f"No existe proveedor con ID: {id_proveedor}")
                
                # Calcular precio total
                cantidad = float(datos['cantidad'])
                precio_unitario = float(datos['precio_unitario'])
                precio_total = cantidad * precio_unitario
                
                query = """
                INSERT INTO ComprasCombustible 
                (id_proveedor, tipo_combustible, fecha_compra, cantidad, unidad_medida,
                 precio_unitario, precio_total, responsable, observaciones)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """
                
                valores = (
                    id_proveedor,
                    str(datos['tipo_combustible']).strip(),
                    self._formatear_fecha(datos['fecha_compra']),
                    cantidad,
                    str(datos['unidad_medida']).strip(),
                    precio_unitario,
                    precio_total,
                    int(datos['responsable']),
                    str(datos.get('observaciones', '')).strip() if datos.get('observaciones') else None
                )
                
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID generado
                cursor.execute("SELECT @@IDENTITY")
                id_generado = cursor.fetchone()[0]
                
                logger.info(f"Compra de combustible registrada: ID {id_generado}, Total: ${precio_total:.2f}")
                return True, int(id_generado)
                
        except ValueError as ve:
            logger.warning(f"Validación fallida al crear compra: {str(ve)}")
            raise ErrorConsulta(str(ve))
        except Exception as e:
            logger.error(f"Error al crear compra de combustible: {str(e)}")
            raise ErrorConsulta(f"Error al crear compra de combustible: {str(e)}")
    
    @cache_invalidator('combustible')
    @cache_invalidator('estadisticas')
    def actualizar(self, id_compra: int, datos: Dict) -> bool:
        """
        Actualiza una compra de combustible existente.
        
        Args:
            id_compra: ID de la compra a actualizar
            datos: Diccionario con campos a actualizar
            
        Returns:
            True si se actualizó correctamente
        """
        try:
            # Verificar que la compra existe
            compra_actual = self.obtener_por_id(id_compra)
            if not compra_actual:
                raise ValueError(f"No existe compra con ID: {id_compra}")
            
            campos_actualizar = []
            valores = []
            
            # Recalcular precio_total si cambian cantidad o precio_unitario
            recalcular_total = False
            nueva_cantidad = datos.get('cantidad', compra_actual['cantidad'])
            nuevo_precio_unitario = datos.get('precio_unitario', compra_actual['precio_unitario'])
            
            if 'id_proveedor' in datos:
                if datos['id_proveedor']:
                    # Validar proveedor
                    with self.db.get_connection() as conn:
                        cursor = conn.cursor()
                        cursor.execute("SELECT id_proveedor FROM Proveedores WHERE id_proveedor = ?", 
                                     (datos['id_proveedor'],))
                        if not cursor.fetchone():
                            raise ValueError(f"No existe proveedor con ID: {datos['id_proveedor']}")
                    campos_actualizar.append("id_proveedor = ?")
                    valores.append(int(datos['id_proveedor']))
                else:
                    campos_actualizar.append("id_proveedor = NULL")
            
            if 'tipo_combustible' in datos:
                campos_actualizar.append("tipo_combustible = ?")
                valores.append(str(datos['tipo_combustible']).strip())
            
            if 'fecha_compra' in datos:
                campos_actualizar.append("fecha_compra = ?")
                valores.append(self._formatear_fecha(datos['fecha_compra']))
            
            if 'cantidad' in datos:
                if float(datos['cantidad']) <= 0:
                    raise ValueError("La cantidad debe ser mayor a 0")
                campos_actualizar.append("cantidad = ?")
                valores.append(float(datos['cantidad']))
                recalcular_total = True
            
            if 'unidad_medida' in datos:
                campos_actualizar.append("unidad_medida = ?")
                valores.append(str(datos['unidad_medida']).strip())
            
            if 'precio_unitario' in datos:
                if float(datos['precio_unitario']) <= 0:
                    raise ValueError("El precio unitario debe ser mayor a 0")
                campos_actualizar.append("precio_unitario = ?")
                valores.append(float(datos['precio_unitario']))
                recalcular_total = True
            
            # Recalcular precio_total si es necesario
            if recalcular_total:
                precio_total = float(nueva_cantidad) * float(nuevo_precio_unitario)
                campos_actualizar.append("precio_total = ?")
                valores.append(precio_total)
            
            if 'responsable' in datos:
                # Validar empleado
                with self.db.get_connection() as conn:
                    cursor = conn.cursor()
                    cursor.execute("SELECT id_empleado FROM Empleados WHERE id_empleado = ?", 
                                 (datos['responsable'],))
                    if not cursor.fetchone():
                        raise ValueError(f"No existe empleado con ID: {datos['responsable']}")
                campos_actualizar.append("responsable = ?")
                valores.append(int(datos['responsable']))
            
            if 'observaciones' in datos:
                campos_actualizar.append("observaciones = ?")
                obs = str(datos['observaciones']).strip() if datos['observaciones'] else None
                valores.append(obs)
            
            if not campos_actualizar:
                logger.warning("No hay campos para actualizar")
                return False
            
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Construir query dinámicamente para id_proveedor = NULL
                query_parts = []
                query_valores = []
                for i, campo in enumerate(campos_actualizar):
                    if campo == "id_proveedor = NULL":
                        query_parts.append(campo)
                    else:
                        query_parts.append(campo)
                        # Solo agregar valores para campos que no sean NULL
                        if not campo.endswith("= NULL"):
                            query_valores.append(valores[len(query_valores)])
                
                query = f"UPDATE ComprasCombustible SET {', '.join(query_parts)} WHERE id_compra = ?"
                query_valores.append(id_compra)
                
                cursor.execute(query, query_valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                
                if filas_afectadas > 0:
                    logger.info(f"Compra de combustible actualizada: ID {id_compra}")
                    return True
                else:
                    logger.warning(f"No se actualizó ninguna fila para ID: {id_compra}")
                    return False
                    
        except ValueError as ve:
            logger.warning(f"Validación fallida al actualizar compra: {str(ve)}")
            raise ErrorConsulta(str(ve))
        except Exception as e:
            logger.error(f"Error al actualizar compra de combustible: {str(e)}")
            raise ErrorConsulta(f"Error al actualizar compra de combustible: {str(e)}")
    
    @cache_invalidator('combustible')
    @cache_invalidator('estadisticas')
    def eliminar(self, id_compra: int) -> bool:
        """
        Elimina una compra de combustible.
        
        Args:
            id_compra: ID de la compra a eliminar
            
        Returns:
            True si se eliminó correctamente
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = "DELETE FROM ComprasCombustible WHERE id_compra = ?"
                cursor.execute(query, (id_compra,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                
                if filas_afectadas > 0:
                    logger.info(f"Compra de combustible eliminada: ID {id_compra}")
                    return True
                else:
                    logger.warning(f"No se eliminó ninguna fila para ID: {id_compra}")
                    return False
                    
        except Exception as e:
            logger.error(f"Error al eliminar compra de combustible: {str(e)}")
            raise ErrorConsulta(f"Error al eliminar compra de combustible: {str(e)}")
    
    @cacheable('resumen_combustible', key_func=lambda periodo: f"resumen_{periodo}", ttl=600)
    def obtener_resumen(self, periodo: str = 'mes') -> Dict:
        """
        Obtiene un resumen de compras de combustible por período.
        
        Args:
            periodo: Período de tiempo ('mes', 'trimestre', 'año')
            
        Returns:
            Diccionario con resumen por tipo de combustible
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Definir filtro de fechas
                if periodo == 'mes':
                    fecha_filtro = "DATEADD(month, -1, GETDATE())"
                elif periodo == 'trimestre':
                    fecha_filtro = "DATEADD(month, -3, GETDATE())"
                elif periodo == 'año':
                    fecha_filtro = "DATEADD(year, -1, GETDATE())"
                else:
                    fecha_filtro = "DATEADD(month, -1, GETDATE())"
                
                query = f"""
                SELECT tipo_combustible,
                       SUM(cantidad) as total_cantidad,
                       SUM(precio_total) as total_costo,
                       COUNT(*) as num_compras,
                       AVG(precio_unitario) as precio_promedio
                FROM ComprasCombustible
                WHERE fecha_compra >= {fecha_filtro}
                GROUP BY tipo_combustible
                """
                
                cursor.execute(query)
                
                resumen = {}
                for row in cursor.fetchall():
                    resumen[row.tipo_combustible] = {
                        'total_cantidad': float(row.total_cantidad),
                        'total_costo': float(row.total_costo),
                        'num_compras': int(row.num_compras),
                        'precio_promedio': float(row.precio_promedio)
                    }
                
                logger.info(f"Resumen de combustible generado para período: {periodo}")
                return resumen
                
        except Exception as e:
            logger.error(f"Error al obtener resumen de combustible: {str(e)}")
            raise ErrorConsulta(f"Error al obtener resumen de combustible: {str(e)}")
    
    def obtener_estadisticas(self) -> Dict:
        """
        Obtiene estadísticas generales de compras de combustible.
        
        Returns:
            Diccionario con estadísticas
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                # Total de compras y gasto
                cursor.execute("""
                SELECT COUNT(*) as total_compras,
                       COALESCE(SUM(precio_total), 0) as gasto_total,
                       COALESCE(SUM(cantidad), 0) as cantidad_total
                FROM ComprasCombustible
                """)
                row = cursor.fetchone()
                total_compras = row.total_compras
                gasto_total = float(row.gasto_total)
                cantidad_total = float(row.cantidad_total)
                
                # Por tipo de combustible
                cursor.execute("""
                SELECT tipo_combustible,
                       COUNT(*) as num_compras,
                       SUM(cantidad) as total_cantidad,
                       SUM(precio_total) as total_costo
                FROM ComprasCombustible
                GROUP BY tipo_combustible
                """)
                
                por_tipo = {}
                for row in cursor.fetchall():
                    por_tipo[row.tipo_combustible] = {
                        'num_compras': row.num_compras,
                        'total_cantidad': float(row.total_cantidad),
                        'total_costo': float(row.total_costo)
                    }
                
                estadisticas = {
                    'total_compras': total_compras,
                    'gasto_total': gasto_total,
                    'cantidad_total': cantidad_total,
                    'gasto_promedio': gasto_total / total_compras if total_compras > 0 else 0,
                    'por_tipo': por_tipo
                }
                
                logger.info("Estadísticas de combustible generadas")
                return estadisticas
                
        except Exception as e:
            logger.error(f"Error al obtener estadísticas de combustible: {str(e)}")
            raise ErrorConsulta(f"Error al obtener estadísticas: {str(e)}")