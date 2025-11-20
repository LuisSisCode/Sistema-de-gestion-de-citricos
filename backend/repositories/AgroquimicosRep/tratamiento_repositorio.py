# backend/repositories/AgroquimicosRep/tratamiento_repositorio.py
"""
Repositorio para gestión de tratamientos fitosanitarios
"""

import logging
from datetime import datetime
from typing import List, Optional, Dict, Tuple
from backend.core.repositorio_base import RepositorioBase
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)


class TratamientoRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de Tratamientos Fitosanitarios"""
    
    def __init__(self):
        super().__init__()
        self.tabla = "TratamientosFitosanitarios"
    
    # ==================== CONSULTAS ====================
    
    @cacheable('tratamientos', ttl=get_ttl('tratamientos'))
    def obtener_todos(self) -> List[Dict]:
        """Obtiene todos los tratamientos"""
        query = """
        SELECT t.id_tratamiento, t.id_ciclo, c.id_parcela, p.nombre as nombre_parcela,
               t.id_tipo_plaga, tp.nombre as nombre_plaga, t.id_mezcla, m.nombre as nombre_mezcla,
               t.fecha_aplicacion, t.area_tratada, t.metodo_aplicacion, t.cantidad_agua,
               t.costo_total, t.realizado_por, e.nombre as nombre_empleado, t.observaciones
        FROM TratamientosFitosanitarios t
        LEFT JOIN CiclosProduccion c ON t.id_ciclo = c.id_ciclo
        LEFT JOIN Parcelas p ON c.id_parcela = p.id_parcela
        LEFT JOIN TiposPlagasMalezas tp ON t.id_tipo_plaga = tp.id_tipo
        LEFT JOIN MezclasAgroquimicos m ON t.id_mezcla = m.id_mezcla
        LEFT JOIN Empleados e ON t.realizado_por = e.id_empleado
        ORDER BY t.fecha_aplicacion DESC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                tratamientos = []
                for row in cursor.fetchall():
                    tratamiento = {
                        'id_tratamiento': row.id_tratamiento,
                        'id_ciclo': row.id_ciclo,
                        'id_parcela': row.id_parcela,
                        'nombre_parcela': row.nombre_parcela,
                        'id_tipo_plaga': row.id_tipo_plaga,
                        'nombre_plaga': row.nombre_plaga,
                        'id_mezcla': row.id_mezcla,
                        'nombre_mezcla': row.nombre_mezcla,
                        'fecha_aplicacion': self._formatear_fecha(row.fecha_aplicacion),
                        'area_tratada': float(row.area_tratada) if row.area_tratada else 0.0,
                        'metodo_aplicacion': row.metodo_aplicacion,
                        'cantidad_agua': float(row.cantidad_agua) if row.cantidad_agua else 0.0,
                        'costo_total': float(row.costo_total) if row.costo_total else 0.0,
                        'realizado_por': row.realizado_por,
                        'nombre_empleado': row.nombre_empleado,
                        'observaciones': row.observaciones
                    }
                    tratamientos.append(tratamiento)
                
                logger.info(f"Se obtuvieron {len(tratamientos)} tratamientos")
                return tratamientos
                
        except Exception as e:
            logger.error(f"Error al obtener tratamientos: {str(e)}")
            return []
    
    def obtener_por_id(self, id_tratamiento: int) -> Optional[Dict]:
        """Obtiene un tratamiento específico por su ID"""
        query = """
        SELECT t.id_tratamiento, t.id_ciclo, c.id_parcela, p.nombre as nombre_parcela,
               t.id_tipo_plaga, tp.nombre as nombre_plaga, t.id_mezcla, m.nombre as nombre_mezcla,
               t.fecha_aplicacion, t.area_tratada, t.metodo_aplicacion, t.cantidad_agua,
               t.costo_total, t.realizado_por, e.nombre as nombre_empleado, t.observaciones
        FROM TratamientosFitosanitarios t
        LEFT JOIN CiclosProduccion c ON t.id_ciclo = c.id_ciclo
        LEFT JOIN Parcelas p ON c.id_parcela = p.id_parcela
        LEFT JOIN TiposPlagasMalezas tp ON t.id_tipo_plaga = tp.id_tipo
        LEFT JOIN MezclasAgroquimicos m ON t.id_mezcla = m.id_mezcla
        LEFT JOIN Empleados e ON t.realizado_por = e.id_empleado
        WHERE t.id_tratamiento = ?
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_tratamiento,))
                row = cursor.fetchone()
                
                if not row:
                    return None
                
                return {
                    'id_tratamiento': row.id_tratamiento,
                    'id_ciclo': row.id_ciclo,
                    'id_parcela': row.id_parcela,
                    'nombre_parcela': row.nombre_parcela,
                    'id_tipo_plaga': row.id_tipo_plaga,
                    'nombre_plaga': row.nombre_plaga,
                    'id_mezcla': row.id_mezcla,
                    'nombre_mezcla': row.nombre_mezcla,
                    'fecha_aplicacion': self._formatear_fecha(row.fecha_aplicacion),
                    'area_tratada': float(row.area_tratada) if row.area_tratada else 0.0,
                    'metodo_aplicacion': row.metodo_aplicacion,
                    'cantidad_agua': float(row.cantidad_agua) if row.cantidad_agua else 0.0,
                    'costo_total': float(row.costo_total) if row.costo_total else 0.0,
                    'realizado_por': row.realizado_por,
                    'nombre_empleado': row.nombre_empleado,
                    'observaciones': row.observaciones
                }
                
        except Exception as e:
            logger.error(f"Error al obtener tratamiento {id_tratamiento}: {str(e)}")
            return None
    
    def obtener_por_ciclo(self, id_ciclo: int) -> List[Dict]:
        """Obtiene tratamientos por ciclo de producción"""
        query = """
        SELECT t.id_tratamiento, t.fecha_aplicacion, t.area_tratada,
               t.metodo_aplicacion, t.costo_total, tp.nombre as nombre_plaga,
               m.nombre as nombre_mezcla, e.nombre as nombre_empleado
        FROM TratamientosFitosanitarios t
        LEFT JOIN TiposPlagasMalezas tp ON t.id_tipo_plaga = tp.id_tipo
        LEFT JOIN MezclasAgroquimicos m ON t.id_mezcla = m.id_mezcla
        LEFT JOIN Empleados e ON t.realizado_por = e.id_empleado
        WHERE t.id_ciclo = ?
        ORDER BY t.fecha_aplicacion DESC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_ciclo,))
                
                tratamientos = []
                for row in cursor.fetchall():
                    tratamiento = {
                        'id_tratamiento': row.id_tratamiento,
                        'fecha_aplicacion': self._formatear_fecha(row.fecha_aplicacion),
                        'area_tratada': float(row.area_tratada) if row.area_tratada else 0.0,
                        'metodo_aplicacion': row.metodo_aplicacion,
                        'costo_total': float(row.costo_total) if row.costo_total else 0.0,
                        'nombre_plaga': row.nombre_plaga,
                        'nombre_mezcla': row.nombre_mezcla,
                        'nombre_empleado': row.nombre_empleado
                    }
                    tratamientos.append(tratamiento)
                
                return tratamientos
                
        except Exception as e:
            logger.error(f"Error al obtener tratamientos por ciclo {id_ciclo}: {str(e)}")
            return []
    
    # ==================== INSERCIÓN ====================
    
    @cache_invalidator('tratamientos')
    def crear(self, datos: Dict) -> Tuple[bool, Optional[int]]:
        """Crea un nuevo tratamiento fitosanitario"""
        query = """
        INSERT INTO TratamientosFitosanitarios 
        (id_ciclo, id_tipo_plaga, id_mezcla, fecha_aplicacion, area_tratada,
         metodo_aplicacion, cantidad_agua, costo_total, realizado_por, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        try:
            valores = (
                datos['id_ciclo'],
                datos.get('id_tipo_plaga'),
                datos.get('id_mezcla'),
                datos.get('fecha_aplicacion', datetime.now().strftime('%Y-%m-%d')),
                datos.get('area_tratada', 0.0),
                datos.get('metodo_aplicacion'),
                datos.get('cantidad_agua'),
                datos.get('costo_total', 0.0),
                datos['realizado_por'],
                datos.get('observaciones')
            )
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                id_tratamiento = self._obtener_ultimo_id()
                logger.info(f"Tratamiento creado con ID: {id_tratamiento}")
                return True, id_tratamiento
                
        except Exception as e:
            logger.error(f"Error al crear tratamiento: {str(e)}")
            return False, None
    
    # ==================== ACTUALIZACIÓN ====================
    
    @cache_invalidator('tratamientos')
    def actualizar(self, id_tratamiento: int, datos: Dict) -> bool:
        """Actualiza un tratamiento existente"""
        try:
            campos_actualizar = []
            valores = []
            
            campos_permitidos = ['id_ciclo', 'id_tipo_plaga', 'id_mezcla', 'fecha_aplicacion',
                               'area_tratada', 'metodo_aplicacion', 'cantidad_agua', 
                               'costo_total', 'realizado_por', 'observaciones']
            
            for campo in campos_permitidos:
                if campo in datos:
                    campos_actualizar.append(f"{campo} = ?")
                    valores.append(datos[campo])
            
            if not campos_actualizar:
                logger.warning("No hay campos para actualizar")
                return False
            
            valores.append(id_tratamiento)
            query = f"UPDATE TratamientosFitosanitarios SET {', '.join(campos_actualizar)} WHERE id_tratamiento = ?"
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Tratamiento {id_tratamiento} actualizado. Filas afectadas: {filas_afectadas}")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al actualizar tratamiento {id_tratamiento}: {str(e)}")
            return False
    
    # ==================== ELIMINACIÓN ====================
    
    @cache_invalidator('tratamientos')
    def eliminar(self, id_tratamiento: int) -> bool:
        """Elimina un tratamiento"""
        query = "DELETE FROM TratamientosFitosanitarios WHERE id_tratamiento = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_tratamiento,))
                conn.commit()
                
                filas_afectadas = cursor.rowcount
                logger.info(f"Tratamiento {id_tratamiento} eliminado")
                return filas_afectadas > 0
                
        except Exception as e:
            logger.error(f"Error al eliminar tratamiento {id_tratamiento}: {str(e)}")
            return False
    
    # ==================== CONSULTAS ESPECIALIZADAS ====================
    
    def obtener_estadisticas_por_mes(self, año: int, id_ciclo: Optional[int] = None) -> List[Dict]:
        """Obtiene estadísticas de tratamientos por mes"""
        query = """
        SELECT 
            MONTH(fecha_aplicacion) as mes,
            COUNT(*) as total_tratamientos,
            SUM(area_tratada) as area_total,
            AVG(costo_total) as costo_promedio
        FROM TratamientosFitosanitarios
        WHERE YEAR(fecha_aplicacion) = ?
        """
        
        params = [año]
        
        if id_ciclo:
            query += " AND id_ciclo = ?"
            params.append(id_ciclo)
        
        query += " GROUP BY MONTH(fecha_aplicacion) ORDER BY mes"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, params)
                
                estadisticas = []
                for row in cursor.fetchall():
                    estadistica = {
                        'mes': row.mes,
                        'total_tratamientos': row.total_tratamientos,
                        'area_total': float(row.area_total) if row.area_total else 0.0,
                        'costo_promedio': float(row.costo_promedio) if row.costo_promedio else 0.0
                    }
                    estadisticas.append(estadistica)
                
                return estadisticas
                
        except Exception as e:
            logger.error(f"Error al obtener estadísticas por mes: {str(e)}")
            return []