"""
Servicio de Movimientos Financieros
Capa de lógica de negocio - Validaciones y orquestación para Finanzas.
"""

import logging
from typing import List, Dict, Optional
from datetime import date
# Importar el Repositorio que acabamos de crear
from backend.repositories.FinanzasRep.movimiento_financiero_repositorio import MovimientoFinancieroRepositorio
# Importar utilidades de caché (tomando el patrón de tu cliente_service.py)
from backend.core.cache_system import cacheable, cache_invalidator, get_ttl

logger = logging.getLogger('movimiento_financiero_service')

class MovimientoFinancieroService:
    """
    Servicio de lógica de negocio para la gestión de Ingresos y Egresos.
    """
    
    def __init__(self):
        """Inicializa el servicio con su repositorio."""
        self.repo = MovimientoFinancieroRepositorio()
        logger.info("✅ MovimientoFinancieroService inicializado.")
        
    # ==================== REGISTRO MANUAL (Gastos Generales/Capital) ====================
    
    @cache_invalidator('balance_general')
    @cache_invalidator('movimientos_recientes')
    def registrar_movimiento_manual(self, data: Dict) -> int:
        """
        Registra un movimiento ingresado directamente por el usuario (ej. Factura de Luz, Aporte de Capital).
        
        Args:
            data: Diccionario con {fecha_movimiento, monto, es_gasto, id_categoria, descripcion}.
            
        Returns:
            ID del movimiento creado.
        """
        # 1. Validaciones de negocio:
        if data.get('monto', 0) <= 0:
            raise ValueError("El monto debe ser positivo.")
        
        # 2. El registro manual NO lleva origen operativo (id_origen y tabla_origen son NULL)
        try:
            new_id = self.repo.crear_movimiento(
                fecha_movimiento=data['fecha_movimiento'],
                monto=data['monto'],
                es_gasto=data['es_gasto'],
                id_categoria=data['id_categoria'],
                descripcion=data.get('descripcion'),
                id_origen=None,
                tabla_origen=None
            )
            logger.info(f"✅ Movimiento manual creado: ID {new_id}")
            return new_id
        except Exception as e:
            logger.error(f"❌ Error en servicio al registrar movimiento manual: {str(e)}")
            raise

    # ==================== REGISTRO AUTOMÁTICO (Operaciones) ====================

    @cache_invalidator('balance_general')
    @cache_invalidator('movimientos_recientes')
    def registrar_movimiento_automatico(self, 
                                        fecha_movimiento: date,
                                        monto: float,
                                        es_gasto: bool,
                                        id_categoria: int,
                                        id_origen: int,
                                        tabla_origen: str,
                                        descripcion: Optional[str] = None) -> int:
        """
        Registra un movimiento que proviene de otra operación (ej. Compra de Combustible, Venta).
        Este método será llamado desde otros servicios (MaquinariaService, VentaService).
        
        IMPORTANTE: Se asume que la lógica de validación de la operación principal (ej. la compra) 
        ya se ejecutó antes de llamar a este método.
        """
        try:
            # *NO* se valida el origen aquí, eso es responsabilidad del servicio que llama.
            new_id = self.repo.crear_movimiento(
                fecha_movimiento=fecha_movimiento,
                monto=monto,
                es_gasto=es_gasto,
                id_categoria=id_categoria,
                descripcion=descripcion,
                id_origen=id_origen,
                tabla_origen=tabla_origen
            )
            logger.info(f"✅ Movimiento automático creado: ID {new_id} desde {tabla_origen}:{id_origen}")
            return new_id
        except Exception as e:
            logger.error(f"❌ Error en servicio al registrar movimiento automático: {str(e)}")
            raise

    # ==================== CONSULTAS Y ANÁLISIS ====================

    @cacheable('balance_general', ttl=get_ttl('general'))
    def obtener_balance_actual(self) -> float:
        """Obtiene el balance total del sistema (Ingresos - Egresos) con caché."""
        try:
            balance = self.repo.obtener_balance_total()
            logger.info(f"✅ Balance general obtenido: {balance}")
            return balance
        except Exception as e:
            logger.error(f"❌ Error en servicio al obtener balance: {str(e)}")
            return 0.0

    @cacheable('movimientos_recientes', ttl=get_ttl('general'))
    def obtener_movimientos_para_qml(self) -> List[Dict]:
        """Obtiene todos los movimientos para la vista de tabla en QML."""
        return self.repo.obtener_todos_movimientos()
        
    @cacheable('categorias_financieras', ttl=get_ttl('catalogos'))
    def obtener_categorias(self) -> List[Dict]:
        """Obtiene el catálogo de CategoriasFinancieras."""
        return self.repo.obtener_categorias()