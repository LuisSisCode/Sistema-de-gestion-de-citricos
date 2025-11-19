"""
Modelo de Maquinaria Modernizado
Utiliza los nuevos servicios para interactuar con la lógica de negocio.
Compatible con QML para la interfaz de usuario.
"""

from PySide6.QtCore import QObject, Slot, Signal, Property
import json
import logging

from backend.services.MaquinariaServ.maquinaria_service import MaquinariaService
from backend.services.MaquinariaServ.mantenimiento_service import MantenimientoService
from backend.services.MaquinariaServ.combustible_service import CombustibleService

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('maquinaria_model')


class MaquinariaModel(QObject):
    """
    Modelo de maquinaria para la interfaz QML.
    Actúa como puente entre la UI y los servicios de backend.
    """
    
    # Señales para notificar cambios a QML
    maquinariaChanged = Signal()
    mantenimientosChanged = Signal()
    comprasChanged = Signal()
    resumenCombustibleChanged = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        
        # Inicializar servicios
        self.maquinaria_service = MaquinariaService()
        self.mantenimiento_service = MantenimientoService()
        self.combustible_service = CombustibleService()
        
        # Datos en memoria para QML
        self._maquinaria = []
        self._mantenimientos = []
        self._compras = []
        self._resumen_combustible = {}
        
        # Cargar datos iniciales
        self.cargar_maquinaria()
        self.cargar_mantenimientos()
        self.cargar_compras_combustible()
        self.cargar_resumen_combustible()
        
        logger.info("MaquinariaModel inicializado con nuevos servicios")
    
    # ==================== PROPERTIES ====================
    
    @Property(list, notify=maquinariaChanged)
    def maquinaria(self):
        """Lista de maquinaria para QML"""
        return self._maquinaria
    
    @Property(list, notify=mantenimientosChanged)
    def mantenimientos(self):
        """Lista de mantenimientos para QML"""
        return self._mantenimientos
    
    @Property(list, notify=comprasChanged)
    def compras(self):
        """Lista de compras de combustible para QML"""
        return self._compras
    
    @Property(dict, notify=resumenCombustibleChanged)
    def resumen_combustible(self):
        """Resumen de combustible para QML"""
        return self._resumen_combustible
    
    # ==================== MAQUINARIA ====================
    
    @Slot()
    def cargar_maquinaria(self):
        """Carga la lista de maquinaria desde el servicio"""
        try:
            self._maquinaria = self.maquinaria_service.obtener_maquinaria()
            self.maquinariaChanged.emit()
            logger.info(f"Maquinaria cargada: {len(self._maquinaria)} equipos")
        except Exception as e:
            logger.error(f"Error al cargar maquinaria: {str(e)}")
            self._maquinaria = []
            self.maquinariaChanged.emit()
    
    @Slot(str, result=bool)
    def agregar_maquinaria(self, maquinaria_data_json):
        """
        Agrega un nuevo equipo de maquinaria.
        
        Args:
            maquinaria_data_json: JSON string con datos del equipo
            
        Returns:
            True si se agregó exitosamente
        """
        try:
            datos = json.loads(maquinaria_data_json)
            exito, id_generado, mensaje = self.maquinaria_service.agregar_maquinaria(datos)
            
            if exito:
                logger.info(f"Equipo agregado: ID {id_generado}")
                self.cargar_maquinaria()
                return True
            else:
                logger.warning(f"No se pudo agregar equipo: {mensaje}")
                return False
                
        except Exception as e:
            logger.error(f"Error al agregar maquinaria: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_maquinaria(self, id_maquinaria, maquinaria_data_json):
        """
        Actualiza un equipo de maquinaria existente.
        
        Args:
            id_maquinaria: ID del equipo
            maquinaria_data_json: JSON string con datos a actualizar
            
        Returns:
            True si se actualizó exitosamente
        """
        try:
            datos = json.loads(maquinaria_data_json)
            exito, mensaje = self.maquinaria_service.actualizar_maquinaria(id_maquinaria, datos)
            
            if exito:
                logger.info(f"Equipo actualizado: ID {id_maquinaria}")
                self.cargar_maquinaria()
                return True
            else:
                logger.warning(f"No se pudo actualizar equipo: {mensaje}")
                return False
                
        except Exception as e:
            logger.error(f"Error al actualizar maquinaria: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_maquinaria(self, id_maquinaria):
        """
        Elimina (desactiva) un equipo de maquinaria.
        
        Args:
            id_maquinaria: ID del equipo
            
        Returns:
            True si se eliminó exitosamente
        """
        try:
            exito, mensaje = self.maquinaria_service.eliminar_maquinaria(id_maquinaria)
            
            if exito:
                logger.info(f"Equipo eliminado: ID {id_maquinaria}")
                self.cargar_maquinaria()
                return True
            else:
                logger.warning(f"No se pudo eliminar equipo: {mensaje}")
                return False
                
        except Exception as e:
            logger.error(f"Error al eliminar maquinaria: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def desactivar_maquinaria(self, id_maquinaria):
        """
        Desactiva un equipo de maquinaria.
        
        Args:
            id_maquinaria: ID del equipo
            
        Returns:
            True si se desactivó exitosamente
        """
        try:
            exito, mensaje = self.maquinaria_service.desactivar_maquinaria(id_maquinaria)
            
            if exito:
                logger.info(f"Equipo desactivado: ID {id_maquinaria}")
                self.cargar_maquinaria()
                return True
            else:
                logger.warning(f"No se pudo desactivar equipo: {mensaje}")
                return False
                
        except Exception as e:
            logger.error(f"Error al desactivar maquinaria: {str(e)}")
            return False
    
    # ==================== MANTENIMIENTOS ====================
    
    @Slot()
    @Slot(int)
    def cargar_mantenimientos(self, id_maquinaria=None):
        """
        Carga la lista de mantenimientos desde el servicio.
        
        Args:
            id_maquinaria: ID de maquinaria para filtrar (opcional)
        """
        try:
            self._mantenimientos = self.mantenimiento_service.obtener_mantenimientos(id_maquinaria)
            self.mantenimientosChanged.emit()
            logger.info(f"Mantenimientos cargados: {len(self._mantenimientos)}")
        except Exception as e:
            logger.error(f"Error al cargar mantenimientos: {str(e)}")
            self._mantenimientos = []
            self.mantenimientosChanged.emit()
    
    @Slot(int)
    def cargar_mantenimientos_por_maquinaria(self, id_maquinaria):
        """Alias para compatibilidad con código existente"""
        self.cargar_mantenimientos(id_maquinaria)
    
    @Slot(str, result=bool)
    def registrar_mantenimiento(self, mantenimiento_data_json):
        """
        Registra un nuevo mantenimiento.
        
        Args:
            mantenimiento_data_json: JSON string con datos del mantenimiento
            
        Returns:
            True si se registró exitosamente
        """
        try:
            logger.info(f"=== REGISTRAR MANTENIMIENTO ===")
            logger.info(f"JSON recibido: {mantenimiento_data_json}")
            
            datos = json.loads(mantenimiento_data_json)
            logger.info(f"Datos parseados: {datos}")
            
            exito, id_generado, mensaje = self.mantenimiento_service.registrar_mantenimiento(datos)
            
            if exito:
                logger.info(f"Mantenimiento registrado: ID {id_generado}")
                self.cargar_mantenimientos()
                # Recargar maquinaria si cambió el estado
                if datos.get('estado') in ['En proceso', 'Completado']:
                    self.cargar_maquinaria()
                return True
            else:
                logger.warning(f"No se pudo registrar mantenimiento: {mensaje}")
                return False
                
        except Exception as e:
            logger.error(f"Error al registrar mantenimiento: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_mantenimiento(self, id_mantenimiento, mantenimiento_data_json):
        """
        Actualiza un mantenimiento existente.
        
        Args:
            id_mantenimiento: ID del mantenimiento
            mantenimiento_data_json: JSON string con datos a actualizar
            
        Returns:
            True si se actualizó exitosamente
        """
        try:
            datos = json.loads(mantenimiento_data_json)
            exito, mensaje = self.mantenimiento_service.actualizar_mantenimiento(id_mantenimiento, datos)
            
            if exito:
                logger.info(f"Mantenimiento actualizado: ID {id_mantenimiento}")
                self.cargar_mantenimientos()
                # Recargar maquinaria si cambió el estado
                if 'estado' in datos:
                    self.cargar_maquinaria()
                return True
            else:
                logger.warning(f"No se pudo actualizar mantenimiento: {mensaje}")
                return False
                
        except Exception as e:
            logger.error(f"Error al actualizar mantenimiento: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_mantenimiento(self, id_mantenimiento):
        """
        Elimina un mantenimiento.
        
        Args:
            id_mantenimiento: ID del mantenimiento
            
        Returns:
            True si se eliminó exitosamente
        """
        try:
            exito, mensaje = self.mantenimiento_service.eliminar_mantenimiento(id_mantenimiento)
            
            if exito:
                logger.info(f"Mantenimiento eliminado: ID {id_mantenimiento}")
                self.cargar_mantenimientos()
                self.cargar_maquinaria()  # Actualizar estado de maquinaria
                return True
            else:
                logger.warning(f"No se pudo eliminar mantenimiento: {mensaje}")
                return False
                
        except Exception as e:
            logger.error(f"Error al eliminar mantenimiento: {str(e)}")
            return False
    
    # ==================== COMBUSTIBLE ====================
    
    @Slot()
    @Slot(str)
    def cargar_compras_combustible(self, filtro_json=None):
        """
        Carga la lista de compras de combustible.
        
        Args:
            filtro_json: JSON string con filtros (opcional)
        """
        try:
            filtros = json.loads(filtro_json) if filtro_json else None
            self._compras = self.combustible_service.obtener_compras(filtros)
            self.comprasChanged.emit()
            logger.info(f"Compras de combustible cargadas: {len(self._compras)}")
        except Exception as e:
            logger.error(f"Error al cargar compras de combustible: {str(e)}")
            self._compras = []
            self.comprasChanged.emit()
    
    @Slot(str, result=bool)
    def registrar_compra_combustible(self, compra_data_json):
        """
        Registra una nueva compra de combustible.
        
        Args:
            compra_data_json: JSON string con datos de la compra
            
        Returns:
            True si se registró exitosamente
        """
        try:
            datos = json.loads(compra_data_json)
            exito, id_generado, mensaje = self.combustible_service.registrar_compra(datos)
            
            if exito:
                logger.info(f"Compra de combustible registrada: ID {id_generado}")
                self.cargar_compras_combustible()
                self.cargar_resumen_combustible()
                return True
            else:
                logger.warning(f"No se pudo registrar compra: {mensaje}")
                return False
                
        except Exception as e:
            logger.error(f"Error al registrar compra de combustible: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_compra_combustible(self, id_compra, compra_data_json):
        """
        Actualiza una compra de combustible existente.
        
        Args:
            id_compra: ID de la compra
            compra_data_json: JSON string con datos a actualizar
            
        Returns:
            True si se actualizó exitosamente
        """
        try:
            datos = json.loads(compra_data_json)
            exito, mensaje = self.combustible_service.actualizar_compra(id_compra, datos)
            
            if exito:
                logger.info(f"Compra de combustible actualizada: ID {id_compra}")
                self.cargar_compras_combustible()
                self.cargar_resumen_combustible()
                return True
            else:
                logger.warning(f"No se pudo actualizar compra: {mensaje}")
                return False
                
        except Exception as e:
            logger.error(f"Error al actualizar compra de combustible: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_compra_combustible(self, id_compra):
        """
        Elimina una compra de combustible.
        
        Args:
            id_compra: ID de la compra
            
        Returns:
            True si se eliminó exitosamente
        """
        try:
            exito, mensaje = self.combustible_service.eliminar_compra(id_compra)
            
            if exito:
                logger.info(f"Compra de combustible eliminada: ID {id_compra}")
                self.cargar_compras_combustible()
                self.cargar_resumen_combustible()
                return True
            else:
                logger.warning(f"No se pudo eliminar compra: {mensaje}")
                return False
                
        except Exception as e:
            logger.error(f"Error al eliminar compra de combustible: {str(e)}")
            return False
    
    @Slot(str)
    def cargar_resumen_combustible(self, periodo='mes'):
        """
        Carga el resumen de combustible para un período específico.
        
        Args:
            periodo: Período ('mes', 'trimestre', 'año')
        """
        try:
            self._resumen_combustible = self.combustible_service.obtener_resumen(periodo)
            self.resumenCombustibleChanged.emit()
            logger.info(f"Resumen de combustible cargado para período: {periodo}")
        except Exception as e:
            logger.error(f"Error al cargar resumen de combustible: {str(e)}")
            self._resumen_combustible = {}
            self.resumenCombustibleChanged.emit()
    
    # ==================== UTILIDADES Y ESTADÍSTICAS ====================
    
    @Slot(result=dict)
    def obtener_estadisticas_maquinaria(self):
        """Obtiene estadísticas completas de maquinaria"""
        try:
            return self.maquinaria_service.obtener_estadisticas_completas()
        except Exception as e:
            logger.error(f"Error al obtener estadísticas: {str(e)}")
            return {}
    
    @Slot(result=dict)
    def obtener_estadisticas_combustible(self):
        """Obtiene estadísticas de combustible"""
        try:
            return self.combustible_service.obtener_estadisticas()
        except Exception as e:
            logger.error(f"Error al obtener estadísticas de combustible: {str(e)}")
            return {}
    
    @Slot(result=list)
    def obtener_candidatos_eliminacion(self):
        """Obtiene equipos candidatos para eliminación"""
        try:
            return self.maquinaria_service.obtener_candidatos_eliminacion()
        except Exception as e:
            logger.error(f"Error al obtener candidatos: {str(e)}")
            return []
    
    @Slot(result=dict)
    def obtener_reporte_auditoria_equipos(self):
        """Genera un reporte de auditoría de equipos"""
        try:
            return self.maquinaria_service.generar_reporte_auditoria()
        except Exception as e:
            logger.error(f"Error al generar reporte de auditoría: {str(e)}")
            return {}
    
    @Slot(result=int)
    def obtener_usuario_actual(self):
        """Obtiene el ID del usuario actual desde el archivo de sesión"""
        try:
            with open("current_user.json", "r") as f:
                user_data = json.load(f)
                user_id = user_data.get("id_usuario")
                if user_id:
                    logger.info(f"Usuario actual: {user_data.get('nombre', 'Usuario')} (ID: {user_id})")
                    return int(user_id)
                else:
                    raise ValueError("Archivo de sesión corrupto")
        except FileNotFoundError:
            logger.error("No hay sesión activa")
            raise ValueError("No hay sesión activa - haga login primero")
        except Exception as e:
            logger.error(f"Error de sesión: {e}")
            raise ValueError(f"Error de sesión: {str(e)}")
    
    # ==================== DIAGNÓSTICO Y DEBUG ====================
    
    @Slot()
    def diagnosticar_datos(self):
        """Función de diagnóstico para verificar los datos cargados"""
        try:
            logger.info("=== DIAGNÓSTICO PYTHON - MODELO ===")
            logger.info(f"Cantidad de equipos: {len(self._maquinaria)}")
            logger.info(f"Cantidad de mantenimientos: {len(self._mantenimientos)}")
            logger.info(f"Cantidad de compras: {len(self._compras)}")
            
            if self._maquinaria:
                logger.info("=== PRIMEROS 3 EQUIPOS ===")
                for i, maq in enumerate(self._maquinaria[:3]):
                    logger.info(f"--- Equipo {i+1} ---")
                    logger.info(f"  Código: {maq.get('codigo')}")
                    logger.info(f"  Nombre: {maq.get('nombre')}")
                    logger.info(f"  Activo: {maq.get('activo')} (tipo: {type(maq.get('activo'))})")
            
            activos = sum(1 for m in self._maquinaria if m.get('activo'))
            logger.info(f"📊 Equipos activos: {activos}/{len(self._maquinaria)}")
            logger.info("=== FIN DIAGNÓSTICO ===")
            
        except Exception as e:
            logger.error(f"❌ Error en diagnóstico: {str(e)}")
    
    @Slot()
    def verificar_estructura_bd(self):
        """Verifica la estructura de la base de datos"""
        try:
            logger.info("=== VERIFICANDO ESTRUCTURA BD ===")
            verificacion = self.maquinaria_service.verificar_estructura_bd()
            logger.info(f"Verificación: {verificacion}")
            logger.info("=== FIN VERIFICACIÓN ===")
        except Exception as e:
            logger.error(f"❌ Error al verificar estructura: {str(e)}")
    
    @Slot()
    def recargar_con_diagnostico(self):
        """Recarga los datos con información de diagnóstico detallada"""
        try:
            logger.info("=== RECARGA CON DIAGNÓSTICO ===")
            
            # Limpiar y recargar
            self._maquinaria = []
            self.maquinariaChanged.emit()
            
            logger.info("🔄 Cargando desde servicios...")
            self.cargar_maquinaria()
            
            logger.info(f"✅ Datos cargados: {len(self._maquinaria)} equipos")
            logger.info("=== FIN RECARGA ===")
            
        except Exception as e:
            logger.error(f"❌ Error en recarga: {str(e)}")
    
    @Slot(result=dict)
    def obtener_estadisticas_debug(self):
        """Obtiene estadísticas detalladas para debugging"""
        try:
            stats = {
                'total_equipos': len(self._maquinaria),
                'equipos_activos': sum(1 for m in self._maquinaria if m.get('activo')),
                'equipos_inactivos': sum(1 for m in self._maquinaria if not m.get('activo')),
                'total_mantenimientos': len(self._mantenimientos),
                'total_compras': len(self._compras)
            }
            
            logger.info(f"Estadísticas debug: {stats}")
            return stats
            
        except Exception as e:
            logger.error(f"❌ Error al obtener estadísticas debug: {str(e)}")
            return {}