"""
Repositorio de Movimientos Financieros
Capa de acceso a datos - Solo queries SQL para Ingresos y Egresos.
"""

import logging
from typing import List, Dict, Optional
from datetime import date
# Asumiendo que esta es la ruta a tu conexión a BD
from backend.core.database import DatabaseConnection 
from backend.core.repositorio_base import RepositorioBase # Si tienes una clase base

logger = logging.getLogger('movimiento_financiero_repositorio')

class MovimientoFinancieroRepositorio:
    """
    Repositorio para acceso a datos de Movimientos Financieros (Ingresos y Egresos).
    """
    
    def __init__(self):
        """Inicializa la conexión a la base de datos."""
        try:
            self.db = DatabaseConnection()
            logger.info("✅ MovimientoFinancieroRepositorio inicializado.")
        except Exception as e:
            logger.error(f"❌ Error al inicializar Repositorio Financiero: {str(e)}")
            raise

    # ==================== OPERACIONES CRUD ====================
    
    def crear_movimiento(self, 
                         fecha_movimiento: date,
                         monto: float,
                         es_gasto: bool,
                         id_categoria: int,
                         descripcion: Optional[str] = None,
                         id_origen: Optional[int] = None,
                         tabla_origen: Optional[str] = None) -> int:
        """
        Registra un nuevo movimiento financiero (Ingreso o Egreso) en la BD.

        Devuelve el ID del movimiento creado.
        """
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                
                query = """
                INSERT INTO MovimientosFinancieros (
                    fecha_movimiento, monto, es_gasto, id_categoria, 
                    descripcion, id_origen, tabla_origen
                )
                VALUES (?, ?, ?, ?, ?, ?, ?);
                SELECT SCOPE_IDENTITY();
                """
                
                params = (
                    fecha_movimiento, monto, es_gasto, id_categoria, 
                    descripcion, id_origen, tabla_origen
                )
                
                cursor.execute(query, params)
                new_id = int(cursor.fetchone()[0])
                conn.commit()
                logger.info(f"✅ Movimiento (ID: {new_id}) creado exitosamente. Tipo: {'EGRESO' if es_gasto else 'INGRESO'}")
                return new_id
                
        except Exception as e:
            logger.error(f"❌ Error al crear movimiento financiero: {str(e)}")
            raise

    def obtener_todos_movimientos(self) -> List[Dict]:
        """Obtiene todos los movimientos financieros con su categoría."""
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                query = """
                SELECT 
                    mf.id_movimiento, mf.fecha_movimiento, mf.monto, mf.es_gasto, 
                    mf.descripcion, mf.fecha_registro,
                    cf.nombre as categoria_nombre, cf.tipo as categoria_tipo,
                    mf.tabla_origen, mf.id_origen
                FROM 
                    MovimientosFinancieros mf
                JOIN 
                    CategoriasFinancieras cf ON mf.id_categoria = cf.id_categoria
                ORDER BY 
                    mf.fecha_movimiento DESC, mf.fecha_registro DESC;
                """
                cursor.execute(query)
                # Asumiendo que tienes un helper para mapear resultados a dicts
                return self.db.map_results_to_dict(cursor.fetchall(), [
                    'id_movimiento', 'fecha_movimiento', 'monto', 'es_gasto', 
                    'descripcion', 'fecha_registro', 'categoria_nombre', 
                    'categoria_tipo', 'tabla_origen', 'id_origen'
                ])
        except Exception as e:
            logger.error(f"❌ Error al obtener movimientos: {str(e)}")
            return []

    # ==================== CONSULTAS DE REPORTE ====================

    def obtener_balance_total(self) -> float:
        """Calcula el balance financiero total (Ingresos - Egresos)."""
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                # Suma de Ingresos - Suma de Egresos
                query = """
                SELECT 
                    SUM(CASE WHEN es_gasto = 0 THEN monto ELSE 0 END) -
                    SUM(CASE WHEN es_gasto = 1 THEN monto ELSE 0 END) AS balance
                FROM 
                    MovimientosFinancieros;
                """
                cursor.execute(query)
                result = cursor.fetchone()
                return float(result[0]) if result and result[0] is not None else 0.0
        except Exception as e:
            logger.error(f"❌ Error al calcular balance total: {str(e)}")
            return 0.0
            
    def obtener_categorias(self) -> List[Dict]:
        """Obtiene todas las categorías financieras para ComboBoxes en QML."""
        try:
            with self.db.get_connection() as conn:
                cursor = conn.cursor()
                query = "SELECT id_categoria, nombre, tipo FROM CategoriasFinancieras ORDER BY tipo DESC, nombre ASC"
                cursor.execute(query)
                return self.db.map_results_to_dict(cursor.fetchall(), ['id_categoria', 'nombre', 'tipo'])
        except Exception as e:
            logger.error(f"❌ Error al obtener categorías: {str(e)}")
            return []
