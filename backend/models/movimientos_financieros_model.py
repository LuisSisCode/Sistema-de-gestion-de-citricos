# C:\AgroIchilo\backend\models\movimientos_financieros_model.py (CÓDIGO CORREGIDO)

import logging
from PySide6.QtCore import QObject, Slot, Signal, Property # QVariantAnimation es reemplazado
from typing import List, Dict
from datetime import date # Necesario para registrarMovimientoManual

from backend.services.FinanzasServ.movimiento_financiero_service import MovimientoFinancieroService
from backend.utils.formatters import date_to_iso # Asumo que esta utilidad existe

logger = logging.getLogger('MovimientosFinancierosModel')

class MovimientosFinancierosModel(QObject):
    """
    Modelo Qt para la gestión de Ingresos y Egresos.
    Responsabilidad: Exponer datos y operaciones a QML.
    """
    
    # ==================== SEÑALES ====================
    movimientosActualizados = Signal() 
    balanceCambiado = Signal()
    categoriasCargadas = Signal()
    errorOcurrido = Signal(str)
    operacionExitosa = Signal(str)
    
    def __init__(self):
        super().__init__()
        # Inicialización protegida (del paso anterior)
        try:
            self.service = MovimientoFinancieroService()
            self._movimientos = []
            self._balance_actual = 0.0
            self._categorias = [] 
            logger.info("✅ MovimientosFinancierosModel inicializado correctamente")
        except Exception as e:
            logger.error(f"❌ FALLO CRÍTICO al inicializar el modelo de Finanzas: {str(e)}")
            raise e
            
    # ==================== PROPIEDADES QML (El Foco de la Corrección) ====================
    
    @Property(list, notify=movimientosActualizados) # Usamos 'list' para arrays
    def movimientos(self) -> List[Dict]:
        return self._movimientos

    @Property(list, notify=categoriasCargadas) # Usamos 'list' para arrays
    def categorias(self) -> List[Dict]:
        return self._categorias
        
    @Property(float, notify=balanceCambiado)
    def balance_actual(self) -> float:
        return self._balance_actual

    # ==================== SLOTS (Funcionalidad expuesta a QML) ====================
    
    @Slot()
    def obtenerMovimientos(self):
        """Obtiene y actualiza la lista de movimientos."""
        try:
            self._movimientos = self.service.obtener_movimientos()
            logger.info(f"✅ Obtenidos {len(self._movimientos)} movimientos.")
            self.movimientosActualizados.emit()
        except Exception as e:
            self.errorOcurrido.emit(f"Error al obtener movimientos: {str(e)}")
            logger.error(f"❌ Error al obtener movimientos: {str(e)}")

    @Slot()
    def obtenerCategorias(self):
        """Obtiene y actualiza la lista de categorías."""
        try:
            self._categorias = self.service.obtener_categorias()
            logger.info(f"✅ Obtenidas {len(self._categorias)} categorías.")
            self.categoriasCargadas.emit()
        except Exception as e:
            self.errorOcurrido.emit(f"Error al obtener categorías: {str(e)}")
            logger.error(f"❌ Error al obtener categorías: {str(e)}")

    @Slot()
    def obtenerBalance(self):
        """Actualiza el balance actual."""
        try:
            self._balance_actual = self.service.obtener_balance_actual()
            logger.info(f"✅ Balance actual actualizado: {self._balance_actual}")
            self.balanceCambiado.emit()
        except Exception as e:
            self.errorOcurrido.emit(f"Error al obtener balance: {str(e)}")
            logger.error(f"❌ Error al obtener balance: {str(e)}")

    @Slot(str, float, bool, int, str, result=bool)
    def registrarMovimientoManual(self, fecha_movimiento: str, monto: float, es_gasto: bool, id_categoria: int, 
                                  descripcion: str = "") -> bool:
        """
        Registra un ingreso o egreso que NO está vinculado a una operación (ej. capital, servicios).
        """
        try:
            # Preparar los datos para el servicio
            data = {
                'fecha_movimiento': date.fromisoformat(fecha_movimiento),
                'monto': monto,
                'es_gasto': es_gasto,
                'id_categoria': id_categoria,
                'descripcion': descripcion
            }
            
            new_id = self.service.registrar_movimiento_manual(data)
            
            # Recargar datos después de la inserción
            self.obtenerMovimientos()
            self.obtenerBalance()
            
            self.operacionExitosa.emit(f"Movimiento (ID: {new_id}) registrado con éxito.")
            return True
        except ValueError as e:
            self.errorOcurrido.emit(f"Error de validación: {str(e)}")
            return False
        except Exception as e:
            msg = f"Error inesperado al registrar movimiento: {str(e)}"
            logger.error(f"❌ {msg}")
            self.errorOcurrido.emit(msg)
            return False