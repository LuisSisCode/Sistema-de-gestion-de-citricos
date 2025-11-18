# backend/repositories/AgroquimicosRep/tratamiento_repositorio.py
"""
Repositorio para gestión de Tratamientos Fitosanitarios
Maneja el acceso a datos de la tabla TratamientosFitosanitarios, 
TiposPlagasMalezas y CiclosProduccion
"""

import logging
from datetime import date
from typing import List, Dict, Optional, Tuple
from backend.core.repositorio_base import RepositorioBase
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger(__name__)


class TratamientoRepositorio(RepositorioBase):
    """Repositorio para operaciones CRUD de Tratamientos Fitosanitarios"""
    
    def __init__(self):
        super().__init__()
        self.tabla = "TratamientosFitosanitarios"
    
    # ==================== CONSULTAS DE TRATAMIENTOS ====================
    
    @cacheable('tratamientos', ttl=get_ttl('tratamientos'))
    def obtener_todos(self) -> List[Dict]:
        """
        Obtiene todos los tratamientos fitosanitarios
        
        Returns:
            List[Dict]: Lista de tratamientos con sus datos completos
        """
        query = """
        SELECT t.id_tratamiento, t.id_ciclo, t.id_tipo_plaga, t.fecha_aplicacion,
               t.area_tratada, t.metodo_aplicacion, t.id_mezcla, 
               t.cantidad_agua, t.costo_total, t.realizado_por,
               t.observaciones,
               tp.nombre as nombre_plaga, tp.categoria as categoria_plaga,
               m.nombre as nombre_mezcla,
               c.fecha_siembra, p.nombre as parcela
        FROM TratamientosFitosanitarios t
        LEFT JOIN TiposPlagasMalezas tp ON t.id_tipo_plaga = tp.id_tipo
        LEFT JOIN MezclasAgroquimicos m ON t.id_mezcla = m.id_mezcla
        LEFT JOIN CiclosProduccion c ON t.id_ciclo = c.id_ciclo
        LEFT JOIN Parcelas p ON c.id_parcela = p.id_parcela
        ORDER BY t.fecha_aplicacion DESC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                tratamientos = []
                for row in cursor.fetchall():
                    # Formatear fecha de aplicación
                    fecha_aplicacion = None
                    if row.fecha_aplicacion:
                        if isinstance(row.fecha_aplicacion, str):
                            fecha_aplicacion = row.fecha_aplicacion
                        else:
                            fecha_aplicacion = row.fecha_aplicacion.strftime('%Y-%m-%d')
                    
                    # Formatear fecha de siembra
                    fecha_siembra = None
                    if row.fecha_siembra:
                        if isinstance(row.fecha_siembra, str):
                            fecha_siembra = row.fecha_siembra
                        else:
                            fecha_siembra = row.fecha_siembra.strftime('%Y-%m-%d')
                    
                    tratamiento = {
                        'id_tratamiento': row.id_tratamiento,
                        'id_ciclo': row.id_ciclo,
                        'id_tipo_plaga': row.id_tipo_plaga,
                        'fecha_aplicacion': fecha_aplicacion,
                        'area_tratada': float(row.area_tratada) if row.area_tratada else 0.0,
                        'metodo_aplicacion': row.metodo_aplicacion,
                        'id_mezcla': row.id_mezcla,
                        'cantidad_agua': float(row.cantidad_agua) if row.cantidad_agua else 0.0,
                        'costo_total': float(row.costo_total) if row.costo_total else 0.0,
                        'realizado_por': row.realizado_por,
                        'observaciones': row.observaciones,
                        'nombre_plaga': row.nombre_plaga,
                        'categoria_plaga': row.categoria_plaga,
                        'nombre_mezcla': row.nombre_mezcla,
                        'fecha_siembra': fecha_siembra,
                        'parcela': row.parcela
                    }
                    tratamientos.append(tratamiento)
                
                logger.info(f"Se obtuvieron {len(tratamientos)} tratamientos de la base de datos")
                return tratamientos
                
        except Exception as e:
            logger.error(f"Error al obtener tratamientos: {str(e)}")
            return []
    
    def obtener_por_id(self, id_tratamiento: int) -> Optional[Dict]:
        """
        Obtiene un tratamiento específico por su ID
        
        Args:
            id_tratamiento: ID del tratamiento a buscar
            
        Returns:
            Dict: Datos del tratamiento o None si no existe
        """
        query = """
        SELECT t.id_tratamiento, t.id_ciclo, t.id_tipo_plaga, t.fecha_aplicacion,
               t.area_tratada, t.metodo_aplicacion, t.id_mezcla, 
               t.cantidad_agua, t.costo_total, t.realizado_por,
               t.observaciones,
               tp.nombre as nombre_plaga, tp.categoria as categoria_plaga,
               m.nombre as nombre_mezcla,
               c.fecha_siembra, p.nombre as parcela
        FROM TratamientosFitosanitarios t
        LEFT JOIN TiposPlagasMalezas tp ON t.id_tipo_plaga = tp.id_tipo
        LEFT JOIN MezclasAgroquimicos m ON t.id_mezcla = m.id_mezcla
        LEFT JOIN CiclosProduccion c ON t.id_ciclo = c.id_ciclo
        LEFT JOIN Parcelas p ON c.id_parcela = p.id_parcela
        WHERE t.id_tratamiento = ?
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_tratamiento,))
                row = cursor.fetchone()
                
                if not row:
                    return None
                
                # Formatear fechas
                fecha_aplicacion = None
                if row.fecha_aplicacion:
                    if isinstance(row.fecha_aplicacion, str):
                        fecha_aplicacion = row.fecha_aplicacion
                    else:
                        fecha_aplicacion = row.fecha_aplicacion.strftime('%Y-%m-%d')
                
                fecha_siembra = None
                if row.fecha_siembra:
                    if isinstance(row.fecha_siembra, str):
                        fecha_siembra = row.fecha_siembra
                    else:
                        fecha_siembra = row.fecha_siembra.strftime('%Y-%m-%d')
                
                return {
                    'id_tratamiento': row.id_tratamiento,
                    'id_ciclo': row.id_ciclo,
                    'id_tipo_plaga': row.id_tipo_plaga,
                    'fecha_aplicacion': fecha_aplicacion,
                    'area_tratada': float(row.area_tratada) if row.area_tratada else 0.0,
                    'metodo_aplicacion': row.metodo_aplicacion,
                    'id_mezcla': row.id_mezcla,
                    'cantidad_agua': float(row.cantidad_agua) if row.cantidad_agua else 0.0,
                    'costo_total': float(row.costo_total) if row.costo_total else 0.0,
                    'realizado_por': row.realizado_por,
                    'observaciones': row.observaciones,
                    'nombre_plaga': row.nombre_plaga,
                    'categoria_plaga': row.categoria_plaga,
                    'nombre_mezcla': row.nombre_mezcla,
                    'fecha_siembra': fecha_siembra,
                    'parcela': row.parcela
                }
                
        except Exception as e:
            logger.error(f"Error al obtener tratamiento {id_tratamiento}: {str(e)}")
            return None
    
    def obtener_por_ciclo(self, id_ciclo: int) -> List[Dict]:
        """
        Obtiene todos los tratamientos de un ciclo específico
        
        Args:
            id_ciclo: ID del ciclo de producción
            
        Returns:
            List[Dict]: Lista de tratamientos del ciclo
        """
        query = """
        SELECT t.id_tratamiento, t.id_ciclo, t.id_tipo_plaga, t.fecha_aplicacion,
               t.area_tratada, t.metodo_aplicacion, t.id_mezcla, t.cantidad_agua,
               t.costo_total, tp.nombre as nombre_plaga, m.nombre as nombre_mezcla
        FROM TratamientosFitosanitarios t
        LEFT JOIN TiposPlagasMalezas tp ON t.id_tipo_plaga = tp.id_tipo
        LEFT JOIN MezclasAgroquimicos m ON t.id_mezcla = m.id_mezcla
        WHERE t.id_ciclo = ?
        ORDER BY t.fecha_aplicacion DESC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_ciclo,))
                
                tratamientos = []
                for row in cursor.fetchall():
                    fecha_aplicacion = None
                    if row.fecha_aplicacion:
                        if isinstance(row.fecha_aplicacion, str):
                            fecha_aplicacion = row.fecha_aplicacion
                        else:
                            fecha_aplicacion = row.fecha_aplicacion.strftime('%Y-%m-%d')
                    
                    tratamiento = {
                        'id_tratamiento': row.id_tratamiento,
                        'id_ciclo': row.id_ciclo,
                        'id_tipo_plaga': row.id_tipo_plaga,
                        'fecha_aplicacion': fecha_aplicacion,
                        'area_tratada': float(row.area_tratada) if row.area_tratada else 0.0,
                        'metodo_aplicacion': row.metodo_aplicacion,
                        'id_mezcla': row.id_mezcla,
                        'cantidad_agua': float(row.cantidad_agua) if row.cantidad_agua else 0.0,
                        'costo_total': float(row.costo_total) if row.costo_total else 0.0,
                        'nombre_plaga': row.nombre_plaga,
                        'nombre_mezcla': row.nombre_mezcla
                    }
                    tratamientos.append(tratamiento)
                
                return tratamientos
                
        except Exception as e:
            logger.error(f"Error al obtener tratamientos del ciclo {id_ciclo}: {str(e)}")
            return []
    
    def obtener_por_rango_fechas(self, fecha_inicio: date, fecha_fin: date) -> List[Dict]:
        """
        Obtiene tratamientos dentro de un rango de fechas
        
        Args:
            fecha_inicio: Fecha inicial
            fecha_fin: Fecha final
            
        Returns:
            List[Dict]: Lista de tratamientos en el rango
        """
        query = """
        SELECT t.id_tratamiento, t.fecha_aplicacion, t.area_tratada, 
               t.costo_total, tp.nombre as nombre_plaga, m.nombre as nombre_mezcla,
               p.nombre as parcela
        FROM TratamientosFitosanitarios t
        LEFT JOIN TiposPlagasMalezas tp ON t.id_tipo_plaga = tp.id_tipo
        LEFT JOIN MezclasAgroquimicos m ON t.id_mezcla = m.id_mezcla
        LEFT JOIN CiclosProduccion c ON t.id_ciclo = c.id_ciclo
        LEFT JOIN Parcelas p ON c.id_parcela = p.id_parcela
        WHERE t.fecha_aplicacion BETWEEN ? AND ?
        ORDER BY t.fecha_aplicacion DESC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (fecha_inicio, fecha_fin))
                
                tratamientos = []
                for row in cursor.fetchall():
                    fecha_aplicacion = None
                    if row.fecha_aplicacion:
                        if isinstance(row.fecha_aplicacion, str):
                            fecha_aplicacion = row.fecha_aplicacion
                        else:
                            fecha_aplicacion = row.fecha_aplicacion.strftime('%Y-%m-%d')
                    
                    tratamiento = {
                        'id_tratamiento': row.id_tratamiento,
                        'fecha_aplicacion': fecha_aplicacion,
                        'area_tratada': float(row.area_tratada) if row.area_tratada else 0.0,
                        'costo_total': float(row.costo_total) if row.costo_total else 0.0,
                        'nombre_plaga': row.nombre_plaga,
                        'nombre_mezcla': row.nombre_mezcla,
                        'parcela': row.parcela
                    }
                    tratamientos.append(tratamiento)
                
                return tratamientos
                
        except Exception as e:
            logger.error(f"Error al obtener tratamientos por rango de fechas: {str(e)}")
            return []
    
    # ==================== TIPOS DE PLAGAS ====================
    
    @cacheable('tipos_plagas', ttl=7200)  # Cache de 2 horas
    def obtener_tipos_plagas(self) -> List[Dict]:
        """
        Obtiene todos los tipos de plagas y malezas
        
        Returns:
            List[Dict]: Lista de tipos de plagas
        """
        query = """
        SELECT id_tipo, nombre, descripcion, categoria, activo
        FROM TiposPlagasMalezas
        WHERE activo = 1
        ORDER BY nombre
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                tipos = []
                for row in cursor.fetchall():
                    tipo = {
                        'id_tipo': row.id_tipo,
                        'nombre': row.nombre,
                        'descripcion': row.descripcion,
                        'categoria': row.categoria,
                        'activo': bool(row.activo)
                    }
                    tipos.append(tipo)
                
                logger.info(f"Se obtuvieron {len(tipos)} tipos de plagas de la base de datos")
                return tipos
                
        except Exception as e:
            logger.error(f"Error al obtener tipos de plagas: {str(e)}")
            return []
    
    # ==================== CICLOS ACTIVOS ====================
    
    @cacheable('ciclos_activos', ttl=900)  # Cache de 15 minutos
    def obtener_ciclos_activos(self) -> List[Dict]:
        """
        Obtiene los ciclos de producción activos para los tratamientos
        
        Returns:
            List[Dict]: Lista de ciclos activos
        """
        query = """
        SELECT c.id_ciclo, c.fecha_siembra, c.estado, c.area_sembrada,
               p.nombre as parcela, p.ubicacion,
               v.nombre as variedad, t.nombre as tipo_cultivo
        FROM CiclosProduccion c
        JOIN Parcelas p ON c.id_parcela = p.id_parcela
        JOIN VariedadesCultivo v ON c.id_variedad = v.id_variedad
        JOIN TiposCultivo t ON v.id_tipo_cultivo = t.id_tipo_cultivo
        WHERE c.estado NOT IN ('Finalizado', 'Cancelado')
        ORDER BY c.fecha_siembra DESC
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query)
                
                ciclos = []
                for row in cursor.fetchall():
                    fecha_siembra = None
                    if row.fecha_siembra:
                        if isinstance(row.fecha_siembra, str):
                            fecha_siembra = row.fecha_siembra
                        else:
                            fecha_siembra = row.fecha_siembra.strftime('%Y-%m-%d')
                    
                    ciclo = {
                        'id_ciclo': row.id_ciclo,
                        'fecha_siembra': fecha_siembra,
                        'estado': row.estado,
                        'area_sembrada': float(row.area_sembrada) if row.area_sembrada else 0.0,
                        'parcela': row.parcela,
                        'ubicacion': row.ubicacion,
                        'variedad': row.variedad,
                        'tipo_cultivo': row.tipo_cultivo,
                        'descripcion': f"{row.tipo_cultivo} - {row.variedad} ({row.parcela})"
                    }
                    ciclos.append(ciclo)
                
                logger.info(f"Se obtuvieron {len(ciclos)} ciclos activos de la base de datos")
                return ciclos
                
        except Exception as e:
            logger.error(f"Error al obtener ciclos activos: {str(e)}")
            return []
    
    # ==================== INSERCIÓN ====================
    
    @cache_invalidator('tratamientos')
    @cache_invalidator('estadisticas')
    def crear(self, datos: Dict) -> Tuple[bool, Optional[int]]:
        """
        Crea un nuevo tratamiento fitosanitario
        
        Args:
            datos: Diccionario con los datos del tratamiento
                - id_ciclo (int): ID del ciclo de producción
                - id_tipo_plaga (int, optional): ID del tipo de plaga
                - fecha_aplicacion (date): Fecha de aplicación
                - area_tratada (float): Área tratada en hectáreas
                - metodo_aplicacion (str, optional): Método usado
                - id_mezcla (int, optional): ID de la mezcla utilizada
                - cantidad_agua (float, optional): Cantidad de agua en litros
                - costo_total (float, optional): Costo total del tratamiento
                - realizado_por (str): Persona que realizó el tratamiento
                - observaciones (str, optional): Observaciones adicionales
                
        Returns:
            Tuple[bool, Optional[int]]: (Éxito, ID del tratamiento creado)
        """
        query = """
        INSERT INTO TratamientosFitosanitarios 
        (id_ciclo, id_tipo_plaga, fecha_aplicacion, area_tratada, metodo_aplicacion,
         id_mezcla, cantidad_agua, costo_total, 
         realizado_por, observaciones)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        try:
            valores = (
                datos['id_ciclo'],
                datos.get('id_tipo_plaga'),
                datos['fecha_aplicacion'],
                datos['area_tratada'],
                datos.get('metodo_aplicacion'),
                datos.get('id_mezcla'),
                datos.get('cantidad_agua'),
                datos.get('costo_total', 0.0),
                datos['realizado_por'],
                datos.get('observaciones')
            )
            
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, valores)
                conn.commit()
                
                # Obtener el ID generado
                cursor.execute("SELECT @@IDENTITY AS ID")
                id_tratamiento = cursor.fetchone()[0]
                
                logger.info(f"Tratamiento creado correctamente con ID: {id_tratamiento}")
                return True, id_tratamiento
                
        except Exception as e:
            logger.error(f"Error al crear tratamiento: {str(e)}")
            return False, None
    
    # ==================== ACTUALIZACIÓN ====================
    
    @cache_invalidator('tratamientos')
    @cache_invalidator('estadisticas')
    def actualizar(self, id_tratamiento: int, datos: Dict) -> bool:
        """
        Actualiza un tratamiento existente
        
        Args:
            id_tratamiento: ID del tratamiento a actualizar
            datos: Diccionario con los campos a actualizar
            
        Returns:
            bool: True si se actualizó correctamente
        """
        try:
            campos_actualizar = []
            valores = []
            
            # Construir dinámicamente los campos a actualizar
            campos_permitidos = [
                'id_tipo_plaga', 'fecha_aplicacion', 'area_tratada', 
                'metodo_aplicacion', 'id_mezcla',
                'cantidad_agua', 'costo_total', 'realizado_por', 'observaciones'
            ]
            
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
    @cache_invalidator('estadisticas')
    def eliminar(self, id_tratamiento: int) -> bool:
        """
        Elimina un tratamiento de la base de datos
        
        Args:
            id_tratamiento: ID del tratamiento a eliminar
            
        Returns:
            bool: True si se eliminó correctamente
        """
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
    
    # ==================== UTILIDADES ====================
    
    def contar_tratamientos(self, id_ciclo: Optional[int] = None) -> int:
        """
        Cuenta el total de tratamientos
        
        Args:
            id_ciclo: Si se especifica, cuenta solo tratamientos de ese ciclo
            
        Returns:
            int: Cantidad de tratamientos
        """
        query = "SELECT COUNT(*) FROM TratamientosFitosanitarios"
        params = []
        
        if id_ciclo:
            query += " WHERE id_ciclo = ?"
            params.append(id_ciclo)
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, params)
                return cursor.fetchone()[0]
                
        except Exception as e:
            logger.error(f"Error al contar tratamientos: {str(e)}")
            return 0
    
    def calcular_costo_total_ciclo(self, id_ciclo: int) -> float:
        """
        Calcula el costo total de tratamientos de un ciclo
        
        Args:
            id_ciclo: ID del ciclo
            
        Returns:
            float: Costo total
        """
        query = """
        SELECT SUM(costo_total) 
        FROM TratamientosFitosanitarios 
        WHERE id_ciclo = ?
        """
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_ciclo,))
                resultado = cursor.fetchone()[0]
                return float(resultado) if resultado else 0.0
                
        except Exception as e:
            logger.error(f"Error al calcular costo total: {str(e)}")
            return 0.0
    
    def existe(self, id_tratamiento: int) -> bool:
        """
        Verifica si un tratamiento existe
        
        Args:
            id_tratamiento: ID del tratamiento
            
        Returns:
            bool: True si existe
        """
        query = "SELECT COUNT(*) FROM TratamientosFitosanitarios WHERE id_tratamiento = ?"
        
        try:
            with self.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute(query, (id_tratamiento,))
                return cursor.fetchone()[0] > 0
                
        except Exception as e:
            logger.error(f"Error al verificar existencia de tratamiento {id_tratamiento}: {str(e)}")
            return False