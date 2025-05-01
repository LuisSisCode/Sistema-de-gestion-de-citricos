from PySide6.QtCore import QObject, Slot, Signal, Property, QDate
from bd_maquinaria import GestorMaquinaria
import json
from datetime import datetime

class MaquinariaModel(QObject):
    maquinariaChanged = Signal()
    mantenimientosChanged = Signal()
    usosChanged = Signal()
    comprasChanged = Signal()
    resumenCombustibleChanged = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._gestor = GestorMaquinaria()
        self._maquinaria = []
        self._mantenimientos = []
        self._usos = []
        self._compras = []
        self._resumen_combustible = {}
        
        # Cargar datos iniciales
        self.cargar_maquinaria()
        self.cargar_mantenimientos()
        self.cargar_compras_combustible()
        self.cargar_resumen_combustible()
    
    @Property(list, notify=maquinariaChanged)
    def maquinaria(self):
        return self._maquinaria
    
    @Property(list, notify=mantenimientosChanged)
    def mantenimientos(self):
        return self._mantenimientos
    
    @Property(list, notify=usosChanged)
    def usos(self):
        return self._usos
    
    @Property(list, notify=comprasChanged)
    def compras(self):
        return self._compras
    
    @Property(dict, notify=resumenCombustibleChanged)
    def resumen_combustible(self):
        return self._resumen_combustible
    
    @Slot()
    def cargar_maquinaria(self):
        """Carga la lista de maquinaria desde la base de datos"""
        try:
            self._maquinaria = self._gestor.obtener_maquinaria()
            self.maquinariaChanged.emit()
        except Exception as e:
            print(f"Error al cargar maquinaria: {str(e)}")
    
    @Slot()
    def cargar_mantenimientos(self, id_maquinaria=None):
        """Carga la lista de mantenimientos desde la base de datos"""
        try:
            self._mantenimientos = self._gestor.obtener_mantenimientos(id_maquinaria)
            self.mantenimientosChanged.emit()
        except Exception as e:
            print(f"Error al cargar mantenimientos: {str(e)}")
    
    @Slot(int)
    def cargar_mantenimientos_por_maquinaria(self, id_maquinaria):
        """Carga los mantenimientos para una maquinaria específica"""
        self.cargar_mantenimientos(id_maquinaria)
    
    @Slot(int)
    def cargar_usos_maquinaria(self, id_maquinaria=None):
        """Carga la lista de usos de maquinaria desde la base de datos"""
        try:
            self._usos = self._gestor.obtener_usos_maquinaria(id_maquinaria)
            self.usosChanged.emit()
        except Exception as e:
            print(f"Error al cargar usos de maquinaria: {str(e)}")
    
    @Slot(str)
    def cargar_compras_combustible(self, filtro_json=None):
        """Carga la lista de compras de combustible desde la base de datos"""
        try:
            filtro = json.loads(filtro_json) if filtro_json else None
            self._compras = self._gestor.obtener_compras_combustible(filtro)
            self.comprasChanged.emit()
        except Exception as e:
            print(f"Error al cargar compras de combustible: {str(e)}")
    
    @Slot(str)
    def cargar_resumen_combustible(self, periodo='mes'):
        """Carga el resumen de combustible para un período específico"""
        try:
            self._resumen_combustible = self._gestor.obtener_resumen_combustible(periodo)
            self.resumenCombustibleChanged.emit()
        except Exception as e:
            print(f"Error al cargar resumen de combustible: {str(e)}")
    
    @Slot(str, result=bool)
    def agregar_maquinaria(self, maquinaria_data_json):
        """Agrega un nuevo equipo de maquinaria a la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            maquinaria_data = json.loads(maquinaria_data_json)
            success, _ = self._gestor.agregar_maquinaria(maquinaria_data)
            if success:
                self.cargar_maquinaria()
            return success
        except Exception as e:
            print(f"Error al agregar maquinaria: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_maquinaria(self, id_maquinaria, maquinaria_data_json):
        """Actualiza un equipo de maquinaria existente"""
        try:
            # Convertir el string JSON a diccionario
            maquinaria_data = json.loads(maquinaria_data_json)
            success = self._gestor.actualizar_maquinaria(id_maquinaria, maquinaria_data)
            if success:
                self.cargar_maquinaria()
            return success
        except Exception as e:
            print(f"Error al actualizar maquinaria: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_maquinaria(self, id_maquinaria):
        """Elimina un equipo de maquinaria existente"""
        try:
            success = self._gestor.eliminar_maquinaria(id_maquinaria)
            if success:
                self.cargar_maquinaria()
            return success
        except Exception as e:
            print(f"Error al eliminar maquinaria: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def desactivar_maquinaria(self, id_maquinaria):
        """Desactiva un equipo de maquinaria en lugar de eliminarlo físicamente"""
        try:
            success = self._gestor.desactivar_maquinaria(id_maquinaria)
            if success:
                self.cargar_maquinaria()
            return success
        except Exception as e:
            print(f"Error al desactivar maquinaria: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def registrar_mantenimiento(self, mantenimiento_data_json):
        """Registra un nuevo mantenimiento en la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            mantenimiento_data = json.loads(mantenimiento_data_json)
            
            # Convertir la fecha si viene como string
            if 'fecha_realizada' in mantenimiento_data and isinstance(mantenimiento_data['fecha_realizada'], str):
                try:
                    fecha = QDate.fromString(mantenimiento_data['fecha_realizada'], "yyyy-MM-dd")
                    mantenimiento_data['fecha_realizada'] = fecha.toPython()
                except:
                    # Si no se puede convertir, dejar la fecha como None
                    mantenimiento_data['fecha_realizada'] = None
            
            success, _ = self._gestor.registrar_mantenimiento(mantenimiento_data)
            if success:
                self.cargar_mantenimientos()
                # Recargar maquinaria para reflejar cambios en el estado
                self.cargar_maquinaria()
            return success
        except Exception as e:
            print(f"Error al registrar mantenimiento: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_mantenimiento(self, id_mantenimiento, mantenimiento_data_json):
        """Actualiza un mantenimiento existente"""
        try:
            # Convertir el string JSON a diccionario
            mantenimiento_data = json.loads(mantenimiento_data_json)
            
            # Convertir la fecha si viene como string
            if 'fecha_realizada' in mantenimiento_data and isinstance(mantenimiento_data['fecha_realizada'], str):
                try:
                    fecha = QDate.fromString(mantenimiento_data['fecha_realizada'], "yyyy-MM-dd")
                    mantenimiento_data['fecha_realizada'] = fecha.toPython()
                except:
                    # Si no se puede convertir, dejar la fecha como None
                    mantenimiento_data['fecha_realizada'] = None
            
            success = self._gestor.actualizar_mantenimiento(id_mantenimiento, mantenimiento_data)
            if success:
                self.cargar_mantenimientos()
                # Recargar maquinaria para reflejar cambios en el estado
                self.cargar_maquinaria()
            return success
        except Exception as e:
            print(f"Error al actualizar mantenimiento: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def registrar_uso_maquinaria(self, uso_data_json):
        """Registra un nuevo uso de maquinaria en la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            uso_data = json.loads(uso_data_json)
            
            # Convertir fechas si vienen como string
            if 'fecha_inicio' in uso_data and isinstance(uso_data['fecha_inicio'], str):
                try:
                    fecha = datetime.strptime(uso_data['fecha_inicio'], "%Y-%m-%d %H:%M:%S")
                    uso_data['fecha_inicio'] = fecha
                except:
                    # Si no se puede convertir, usar la fecha actual
                    uso_data['fecha_inicio'] = datetime.now()
            
            if 'fecha_fin' in uso_data and isinstance(uso_data['fecha_fin'], str):
                try:
                    fecha = datetime.strptime(uso_data['fecha_fin'], "%Y-%m-%d %H:%M:%S")
                    uso_data['fecha_fin'] = fecha
                except:
                    # Si no se puede convertir, dejar como None
                    uso_data['fecha_fin'] = None
            
            success, _ = self._gestor.registrar_uso_maquinaria(uso_data)
            if success:
                self.cargar_usos_maquinaria()
            return success
        except Exception as e:
            print(f"Error al registrar uso de maquinaria: {str(e)}")
            return False
    
    @Slot(int, str, float, result=bool)
    def finalizar_uso_maquinaria(self, id_uso, fecha_fin_str=None, combustible_consumido=None):
        """Finaliza un registro de uso de maquinaria"""
        try:
            fecha_fin = None
            if fecha_fin_str:
                try:
                    fecha_fin = datetime.strptime(fecha_fin_str, "%Y-%m-%d %H:%M:%S")
                except:
                    # Si no se puede convertir, usar la fecha actual
                    fecha_fin = datetime.now()
            else:
                fecha_fin = datetime.now()
            
            success = self._gestor.finalizar_uso_maquinaria(id_uso, fecha_fin, combustible_consumido)
            if success:
                self.cargar_usos_maquinaria()
                # Actualizar el resumen de combustible si se registró consumo
                if combustible_consumido:
                    self.cargar_resumen_combustible()
            return success
        except Exception as e:
            print(f"Error al finalizar uso de maquinaria: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def registrar_compra_combustible(self, compra_data_json):
        """Registra una nueva compra de combustible en la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            compra_data = json.loads(compra_data_json)
            
            # Convertir la fecha si viene como string
            if 'fecha_compra' in compra_data and isinstance(compra_data['fecha_compra'], str):
                try:
                    fecha = QDate.fromString(compra_data['fecha_compra'], "yyyy-MM-dd")
                    compra_data['fecha_compra'] = fecha.toPython()
                except:
                    # Si no se puede convertir, usar la fecha actual
                    compra_data['fecha_compra'] = datetime.now().date()
            
            success, _ = self._gestor.registrar_compra_combustible(compra_data)
            if success:
                self.cargar_compras_combustible()
                self.cargar_resumen_combustible()
            return success
        except Exception as e:
            print(f"Error al registrar compra de combustible: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_compra_combustible(self, id_compra, compra_data_json):
        """Actualiza una compra de combustible existente"""
        try:
            # Convertir el string JSON a diccionario
            compra_data = json.loads(compra_data_json)
            
            # Convertir la fecha si viene como string
            if 'fecha_compra' in compra_data and isinstance(compra_data['fecha_compra'], str):
                try:
                    fecha = QDate.fromString(compra_data['fecha_compra'], "yyyy-MM-dd")
                    compra_data['fecha_compra'] = fecha.toPython()
                except:
                    # Si no se puede convertir, dejar la fecha como None
                    compra_data['fecha_compra'] = None
            
            success = self._gestor.actualizar_compra_combustible(id_compra, compra_data)
            if success:
                self.cargar_compras_combustible()
                self.cargar_resumen_combustible()
            return success
        except Exception as e:
            print(f"Error al actualizar compra de combustible: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_compra_combustible(self, id_compra):
        """Elimina una compra de combustible existente"""
        try:
            success = self._gestor.eliminar_compra_combustible(id_compra)
            if success:
                self.cargar_compras_combustible()
                self.cargar_resumen_combustible()
            return success
        except Exception as e:
            print(f"Error al eliminar compra de combustible: {str(e)}")
            return False
    
    @Slot(result=dict)
    def obtener_estados_maquinaria(self):
        """Obtiene el conteo de maquinaria por estado"""
        try:
            estados = {
                "Operativo": 0,
                "En mantenimiento": 0,
                "Fuera de servicio": 0
            }
            
            for maquina in self._maquinaria:
                if maquina["estado"] in estados:
                    estados[maquina["estado"]] += 1
                
            return estados
        except Exception as e:
            print(f"Error al obtener estados de maquinaria: {str(e)}")
            return {}
    
    @Slot(str, result=float)
    def obtener_gasto_total_combustible(self, periodo='mes'):
        """Obtiene el gasto total en combustible para un período específico"""
        try:
            total = 0
            resumen = self._gestor.obtener_resumen_combustible(periodo)
            
            for tipo, datos in resumen.items():
                total += datos.get('total_costo', 0)
            
            return total
        except Exception as e:
            print(f"Error al obtener gasto total de combustible: {str(e)}")
            return 0
    
    @Slot(result=dict)
    def obtener_resumen_mantenimiento(self):
        """Obtiene estadísticas de mantenimiento"""
        try:
            resumen = {
                "preventivos": 0,
                "correctivos": 0,
                "programados": 0,
                "completados": 0,
                "costo_total": 0
            }
            
            for mantenimiento in self._mantenimientos:
                if mantenimiento["tipo"] == "Preventivo":
                    resumen["preventivos"] += 1
                elif mantenimiento["tipo"] == "Correctivo":
                    resumen["correctivos"] += 1
                
                if mantenimiento["estado"] == "Programado":
                    resumen["programados"] += 1
                elif mantenimiento["estado"] == "Completado":
                    resumen["completados"] += 1
                
                resumen["costo_total"] += mantenimiento.get("costo_total", 0)
            
            return resumen
        except Exception as e:
            print(f"Error al obtener resumen de mantenimiento: {str(e)}")
            return {}
    
    @Slot(int, result=dict)
    def obtener_detalles_maquinaria(self, id_maquinaria):
        """Obtiene detalles completos de una maquinaria, incluyendo historial"""
        try:
            # Buscar la maquinaria
            maquina = None
            for m in self._maquinaria:
                if m["id_maquinaria"] == id_maquinaria:
                    maquina = m
                    break
            
            if not maquina:
                return {}
            
            # Obtener mantenimientos
            mantenimientos = self._gestor.obtener_mantenimientos(id_maquinaria)
            
            # Obtener usos
            usos = self._gestor.obtener_usos_maquinaria(id_maquinaria)
            
            # Calcular estadísticas
            total_mantenimientos = len(mantenimientos)
            costo_mantenimientos = sum(m.get("costo_total", 0) for m in mantenimientos)
            total_usos = len(usos)
            combustible_consumido = sum(u.get("combustible_consumido", 0) for u in usos if u.get("combustible_consumido") is not None)
            
            detalles = {
                "maquinaria": maquina,
                "estadisticas": {
                    "total_mantenimientos": total_mantenimientos,
                    "costo_mantenimientos": costo_mantenimientos,
                    "total_usos": total_usos,
                    "combustible_consumido": combustible_consumido
                },
                "mantenimientos": mantenimientos,
                "usos": usos
            }
            
            return detalles
        except Exception as e:
            print(f"Error al obtener detalles de maquinaria: {str(e)}")
            return {}