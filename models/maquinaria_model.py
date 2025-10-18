from PySide6.QtCore import QObject, Slot, Signal, Property, QDate
from bd_conecciones.bd_maquinaria import GestorMaquinaria
import json
from datetime import datetime
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('maquinaria_model')
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
            print(f"=== REGISTRAR MANTENIMIENTO ===")
            print(f"JSON recibido: {mantenimiento_data_json}")
            
            # Convertir el string JSON a diccionario
            mantenimiento_data = json.loads(mantenimiento_data_json)
            print(f"Datos parseados: {mantenimiento_data}")
            
            # ✅ MANEJO SIMPLIFICADO DE FECHAS
            # Solo procesar fecha si está presente y el estado es "Completado"
            if 'fecha_realizada' in mantenimiento_data:
                fecha_str = mantenimiento_data['fecha_realizada']
                
                # Si es string vacío o None, eliminar del diccionario
                if not fecha_str or fecha_str.strip() == "":
                    mantenimiento_data.pop('fecha_realizada', None)
                    print("Fecha eliminada por estar vacía")
                else:
                    # Validar formato de fecha
                    try:
                        datetime.strptime(fecha_str, '%Y-%m-%d')
                        print(f"Fecha válida: {fecha_str}")
                        # Mantener como string, no convertir
                    except ValueError:
                        print(f"Formato de fecha inválido: {fecha_str}")
                        mantenimiento_data.pop('fecha_realizada', None)
            
            print(f"Datos finales para BD: {mantenimiento_data}")
            
            success, id_resultado = self._gestor.registrar_mantenimiento(mantenimiento_data)
            
            if success:
                print(f"Mantenimiento registrado con ID: {id_resultado}")
                self.cargar_mantenimientos()
                self.cargar_maquinaria()
            else:
                print("Error al registrar mantenimiento en BD")
                
            return success
            
        except Exception as e:
            print(f"Error al registrar mantenimiento: {str(e)}")
            print(f"Tipo de error: {type(e).__name__}")
            import traceback
            print(f"Traceback: {traceback.format_exc()}")
            return False
    @Slot(int, str, result=bool)
    def actualizar_mantenimiento(self, id_mantenimiento, mantenimiento_data_json):
        """Actualiza un mantenimiento existente"""
        try:
            print(f"=== ACTUALIZAR MANTENIMIENTO ID: {id_mantenimiento} ===")
            print(f"JSON recibido: {mantenimiento_data_json}")
            
            # Convertir el string JSON a diccionario
            mantenimiento_data = json.loads(mantenimiento_data_json)
            print(f"Datos parseados: {mantenimiento_data}")
            
            # ✅ MANEJO SIMPLIFICADO DE FECHAS
            if 'fecha_realizada' in mantenimiento_data:
                fecha_str = mantenimiento_data['fecha_realizada']
                
                # Si es string vacío, convertir a None para la BD
                if not fecha_str or fecha_str.strip() == "":
                    mantenimiento_data['fecha_realizada'] = None
                    print("Fecha establecida como None")
                else:
                    # Validar formato y mantener como string
                    try:
                        datetime.strptime(fecha_str, '%Y-%m-%d')
                        print(f"Fecha válida: {fecha_str}")
                        # No convertir a objeto date, mantener como string
                    except ValueError:
                        print(f"Formato de fecha inválido: {fecha_str}, estableciendo como None")
                        mantenimiento_data['fecha_realizada'] = None
            
            print(f"Datos finales para BD: {mantenimiento_data}")
            
            success = self._gestor.actualizar_mantenimiento(id_mantenimiento, mantenimiento_data)
            
            if success:
                print("Mantenimiento actualizado exitosamente")
                self.cargar_mantenimientos()
                self.cargar_maquinaria()
            else:
                print("Error al actualizar mantenimiento en BD")
                
            return success
            
        except Exception as e:
            print(f"Error al actualizar mantenimiento: {str(e)}")
            print(f"Tipo de error: {type(e).__name__}")
            import traceback
            print(f"Traceback: {traceback.format_exc()}")
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
                self.comprasChanged.emit()
                self.resumenCombustibleChanged.emit()
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
    @Slot(int, str, result=bool)
    def cambiar_estado_maquinaria(self, id_maquinaria, nuevo_estado):
        """Cambia el estado de una maquinaria"""
        try:
            success = self._gestor.cambiar_estado_maquinaria(id_maquinaria, nuevo_estado)
            if success:
                self.cargar_maquinaria()
                self.cargar_mantenimientos()  # Recargar por si afecta mantenimientos
            return success
        except Exception as e:
            print(f"Error al cambiar estado de maquinaria: {str(e)}")
            return False
    
    @Slot(result=dict)
    def obtener_estadisticas_estados(self):
        """Obtiene estadísticas detalladas de los estados de maquinaria"""
        try:
            estadisticas = {
                "total_equipos": len(self._maquinaria),
                "operativos": 0,
                "en_mantenimiento": 0,
                "fuera_servicio": 0,
                "inactivos": 0,
                "con_mantenimientos_pendientes": 0
            }
            
            # Contar por estados
            for maquina in self._maquinaria:
                if not maquina.get("activo", True):
                    estadisticas["inactivos"] += 1
                    continue
                    
                estado = maquina.get("estado", "Operativo")
                if estado == "Operativo":
                    estadisticas["operativos"] += 1
                elif estado == "En mantenimiento":
                    estadisticas["en_mantenimiento"] += 1
                elif estado == "Fuera de servicio":
                    estadisticas["fuera_servicio"] += 1
            
            # Contar equipos con mantenimientos pendientes
            equipos_con_pendientes = set()
            for mantenimiento in self._mantenimientos:
                if mantenimiento.get("estado") == "Programado":
                    equipos_con_pendientes.add(mantenimiento.get("id_maquinaria"))
            
            estadisticas["con_mantenimientos_pendientes"] = len(equipos_con_pendientes)
            
            return estadisticas
        except Exception as e:
            print(f"Error al obtener estadísticas de estados: {str(e)}")
            return {}
    
    @Slot(int, result=bool)
    def puede_operar_maquinaria(self, id_maquinaria):
        """Verifica si una maquinaria puede operar (no tiene mantenimientos pendientes)"""
        try:
            # Buscar la maquinaria
            maquina = None
            for m in self._maquinaria:
                if m["id_maquinaria"] == id_maquinaria:
                    maquina = m
                    break
            
            if not maquina or not maquina.get("activo", True):
                return False
            
            if maquina.get("estado") != "Operativo":
                return False
            
            # Verificar mantenimientos pendientes
            for mantenimiento in self._mantenimientos:
                if (mantenimiento.get("id_maquinaria") == id_maquinaria and 
                    mantenimiento.get("estado") == "Programado"):
                    return False
            
            return True
        except Exception as e:
            print(f"Error al verificar si puede operar maquinaria: {str(e)}")
            return False

    @Slot(result=list)
    def obtener_equipos_disponibles_mantenimiento(self):
        """Obtiene lista de equipos que pueden recibir mantenimiento"""
        try:
            equipos_disponibles = []
            
            for maquina in self._maquinaria:
                # Solo equipos activos pueden recibir mantenimiento
                if maquina.get("activo", True):
                    equipos_disponibles.append({
                        "id_maquinaria": maquina["id_maquinaria"],
                        "nombre": maquina["nombre"],
                        "codigo": maquina["codigo"],
                        "estado": maquina.get("estado", "Operativo"),
                        "tipo": maquina.get("tipo", "")
                    })
            
            return equipos_disponibles
        except Exception as e:
            print(f"Error al obtener equipos disponibles para mantenimiento: {str(e)}")
            return []

    @Slot(int, result=list)
    def obtener_historial_estados(self, id_maquinaria):
        """Obtiene el historial de cambios de estado basado en mantenimientos"""
        try:
            historial = []
            
            # Obtener mantenimientos de esta maquinaria ordenados por fecha
            mantenimientos_maquina = []
            for m in self._mantenimientos:
                if m.get("id_maquinaria") == id_maquinaria:
                    mantenimientos_maquina.append(m)
            
            # Ordenar por fecha (los que tienen fecha primero, luego por ID)
            mantenimientos_maquina.sort(key=lambda x: (
                x.get("fecha_realizada") or "9999-12-31",
                x.get("id_mantenimiento", 0)
            ))
            
            for mantenimiento in mantenimientos_maquina:
                evento = {
                    "fecha": mantenimiento.get("fecha_realizada", "Pendiente"),
                    "tipo_evento": "mantenimiento",
                    "estado_mantenimiento": mantenimiento.get("estado", ""),
                    "descripcion": mantenimiento.get("descripcion", ""),
                    "tipo_mantenimiento": mantenimiento.get("tipo", ""),
                    "costo": mantenimiento.get("costo_total", 0)
                }
                historial.append(evento)
            
            return historial
        except Exception as e:
            print(f"Error al obtener historial de estados: {str(e)}")
            return []
    @Slot(int, result=bool)
    def eliminar_maquinaria_fisica(self, id_maquinaria):
        """
        ⚠️ ELIMINACIÓN FÍSICA - SOLO PARA CASOS EXCEPCIONALES
        
        Esta función elimina permanentemente un equipo de la base de datos.
        SOLO debe usarse en casos excepcionales como:
        - Datos ingresados incorrectamente
        - Equipos duplicados por error
        - Corrección de errores administrativos
        
        ⚠️ ADVERTENCIA: Esta acción NO se puede deshacer y afecta la auditoría
        """
        try:
            print(f"⚠️ ELIMINACIÓN FÍSICA solicitada para maquinaria ID: {id_maquinaria}")
            
            # Verificaciones de seguridad antes de eliminar
            maquina_encontrada = None
            for m in self._maquinaria:
                if m["id_maquinaria"] == id_maquinaria:
                    maquina_encontrada = m
                    break
            
            if not maquina_encontrada:
                print(f"❌ Error: Maquinaria {id_maquinaria} no encontrada")
                return False
            
            print(f"⚠️ Eliminando físicamente: {maquina_encontrada['codigo']} - {maquina_encontrada['nombre']}")
            
            # Realizar eliminación física en la base de datos
            success = self._gestor.eliminar_maquinaria(id_maquinaria)
            
            if success:
                print(f"✅ Maquinaria {id_maquinaria} eliminada físicamente de la base de datos")
                # Registrar en log de auditoría (si existe)
                self._registrar_eliminacion_auditoria(maquina_encontrada)
                
                # Recargar datos
                self.cargar_maquinaria()
                self.cargar_mantenimientos()
            else:
                print(f"❌ Error al eliminar físicamente maquinaria {id_maquinaria}")
                
            return success
            
        except Exception as e:
            print(f"❌ Error en eliminación física de maquinaria: {str(e)}")
            return False

    def _registrar_eliminacion_auditoria(self, maquina_data):
        """
        Registra la eliminación física en un log de auditoría.
        Esto es importante para mantener rastro de qué se eliminó y cuándo.
        """
        try:
            from datetime import datetime
            
            log_entry = {
                "fecha": datetime.now().isoformat(),
                "accion": "ELIMINACION_FISICA",
                "usuario": "admin",  # Obtener usuario actual del sistema
                "equipo_eliminado": {
                    "id": maquina_data["id_maquinaria"],
                    "codigo": maquina_data["codigo"],
                    "nombre": maquina_data["nombre"],
                    "tipo": maquina_data["tipo"],
                    "estado_final": maquina_data["estado"]
                },
                "razon": "Eliminación física solicitada por administrador"
            }
            
            print(f"📋 AUDITORÍA: {log_entry}")
            
            # Aquí podrías guardar en una tabla de auditoría
            # self._gestor.registrar_auditoria(log_entry)
            
        except Exception as e:
            print(f"⚠️ Error al registrar eliminación en auditoría: {str(e)}")

    @Slot(result=list)
    def obtener_equipos_candidatos_eliminacion(self):
        """
        Obtiene equipos que podrían ser candidatos para eliminación física.
        
        Criterios:
        - Estado "Fuera de servicio" por mucho tiempo
        - Sin mantenimientos recientes
        - Equipos duplicados
        """
        try:
            candidatos = []
            
            for maquina in self._maquinaria:
                if not maquina.get("activo", True):
                    continue  # Ya están "eliminados" (soft delete)
                
                # Criterio 1: Fuera de servicio
                if maquina.get("estado") == "Fuera de servicio":
                    # Verificar si tiene mantenimientos recientes
                    mantenimientos_recientes = 0
                    for m in self._mantenimientos:
                        if (m.get("id_maquinaria") == maquina["id_maquinaria"] and
                            m.get("fecha_realizada") and
                            m.get("fecha_realizada") != "Pendiente"):
                            mantenimientos_recientes += 1
                    
                    candidatos.append({
                        "id_maquinaria": maquina["id_maquinaria"],
                        "codigo": maquina["codigo"],
                        "nombre": maquina["nombre"],
                        "estado": maquina["estado"],
                        "razon_candidato": f"Fuera de servicio, {mantenimientos_recientes} mantenimientos en historial",
                        "riesgo": "medio" if mantenimientos_recientes == 0 else "alto"
                    })
            
            return candidatos
            
        except Exception as e:
            print(f"Error al obtener candidatos para eliminación: {str(e)}")
            return []

    @Slot(result=dict)
    def obtener_reporte_auditoria_equipos(self):
        """
        Genera un reporte de auditoría con estadísticas de equipos.
        Útil para justificar decisiones de eliminación.
        """
        try:
            from datetime import datetime, timedelta
            
            reporte = {
                "fecha_reporte": datetime.now().isoformat(),
                "total_equipos": len(self._maquinaria),
                "equipos_activos": 0,
                "equipos_inactivos": 0,
                "por_estado": {
                    "Operativo": 0,
                    "En mantenimiento": 0,
                    "Fuera de servicio": 0
                },
                "mantenimientos_ultimo_mes": 0,
                "equipos_sin_mantenimiento": []
            }
            
            fecha_mes_pasado = (datetime.now() - timedelta(days=30)).strftime('%Y-%m-%d')
            
            for maquina in self._maquinaria:
                if maquina.get("activo", True):
                    reporte["equipos_activos"] += 1
                    estado = maquina.get("estado", "Operativo")
                    if estado in reporte["por_estado"]:
                        reporte["por_estado"][estado] += 1
                    
                    # Verificar mantenimientos recientes
                    tiene_mantenimiento_reciente = False
                    for m in self._mantenimientos:
                        if (m.get("id_maquinaria") == maquina["id_maquinaria"] and
                            m.get("fecha_realizada") and
                            m.get("fecha_realizada") > fecha_mes_pasado):
                            tiene_mantenimiento_reciente = True
                            reporte["mantenimientos_ultimo_mes"] += 1
                            break
                    
                    if not tiene_mantenimiento_reciente:
                        reporte["equipos_sin_mantenimiento"].append({
                            "codigo": maquina["codigo"],
                            "nombre": maquina["nombre"],
                            "estado": estado
                        })
                else:
                    reporte["equipos_inactivos"] += 1
            
            return reporte
            
        except Exception as e:
            print(f"Error al generar reporte de auditoría: {str(e)}")
            return {}
    @Slot(result=int)
    def obtener_usuario_actual(self):
        """Obtiene el ID del usuario actual desde el archivo de sesión creado por login"""
        try:
            import json
            with open("current_user.json", "r") as f:
                user_data = json.load(f)
                user_id = user_data.get("id_usuario")
                if user_id:
                    nombre = user_data.get("nombre", "Usuario")
                    logger.info(f"Usuario logueado: {nombre} (ID: {user_id})")
                    return int(user_id)
                else:
                    raise ValueError("Archivo de sesión corrupto: no contiene id_usuario")
                    
        except FileNotFoundError:
            logger.error("ERROR: No hay sesión activa. El usuario debe hacer login primero.")
            raise ValueError("No hay sesión activa - haga login primero")
        except Exception as e:
            logger.error(f"ERROR de sesión: {e}")
            raise ValueError(f"Error de sesión: {str(e)}")

    @Slot()
    def diagnosticar_datos(self):
        """Función de diagnóstico para verificar los datos cargados"""
        try:
            print("=== DIAGNÓSTICO PYTHON - MODELO ===")
            print(f"Cantidad de equipos en self._maquinaria: {len(self._maquinaria)}")
            print(f"Tipo de self._maquinaria: {type(self._maquinaria)}")
            
            if self._maquinaria:
                print("=== PRIMEROS 3 EQUIPOS ===")
                for i, maquina in enumerate(self._maquinaria[:3]):
                    print(f"--- Equipo {i+1} ---")
                    print(f"  id_maquinaria: {maquina.get('id_maquinaria')} (tipo: {type(maquina.get('id_maquinaria'))})")
                    print(f"  codigo: {maquina.get('codigo')} (tipo: {type(maquina.get('codigo'))})")
                    print(f"  nombre: {maquina.get('nombre')} (tipo: {type(maquina.get('nombre'))})")
                    print(f"  activo: {maquina.get('activo')} (tipo: {type(maquina.get('activo'))})")
                    print(f"  estado: {maquina.get('estado')} (tipo: {type(maquina.get('estado'))})")
            
            # Estadísticas
            activos = sum(1 for m in self._maquinaria if m.get('activo'))
            inactivos = len(self._maquinaria) - activos
            print(f"📊 Equipos activos: {activos}")
            print(f"📊 Equipos inactivos: {inactivos}")
            
            print("=== FIN DIAGNÓSTICO PYTHON ===")
            
        except Exception as e:
            print(f"❌ Error en diagnóstico: {str(e)}")

    @Slot()
    def verificar_estructura_bd(self):
        """Verifica la estructura de la base de datos"""
        try:
            print("=== VERIFICANDO ESTRUCTURA BD ===")
            self._gestor.verificar_estructura_bd()
            print("=== FIN VERIFICACIÓN BD ===")
        except Exception as e:
            print(f"❌ Error al verificar estructura BD: {str(e)}")

    @Slot()
    def recargar_con_diagnostico(self):
        """Recarga los datos con información de diagnóstico detallada"""
        try:
            print("=== RECARGA CON DIAGNÓSTICO ===")
            
            # Limpiar datos actuales
            self._maquinaria = []
            self.maquinariaChanged.emit()
            
            # Recargar desde BD con diagnóstico
            print("🔄 Cargando desde base de datos...")
            self._maquinaria = self._gestor.obtener_maquinaria()
            
            print(f"✅ Datos cargados en Python: {len(self._maquinaria)} equipos")
            
            # Emitir señal para actualizar QML
            self.maquinariaChanged.emit()
            
            print("📡 Señal maquinariaChanged emitida")
            print("=== FIN RECARGA ===")
            
        except Exception as e:
            print(f"❌ Error en recarga con diagnóstico: {str(e)}")

    @Slot(result=dict)
    def obtener_estadisticas_debug(self):
        """Obtiene estadísticas detalladas para debugging"""
        try:
            stats = {
                "total_equipos": len(self._maquinaria),
                "equipos_activos": sum(1 for m in self._maquinaria if m.get('activo')),
                "equipos_inactivos": sum(1 for m in self._maquinaria if not m.get('activo')),
                "por_estado": {},
                "tipos_activo": {},
                "ejemplos": []
            }
            
            # Contar por estado (solo activos)
            for m in self._maquinaria:
                if m.get('activo'):
                    estado = m.get('estado', 'Sin estado')
                    stats["por_estado"][estado] = stats["por_estado"].get(estado, 0) + 1
            
            # Tipos de datos del campo 'activo'
            for m in self._maquinaria:
                tipo = str(type(m.get('activo')).__name__)
                valor = str(m.get('activo'))
                clave = f"{tipo}:{valor}"
                stats["tipos_activo"][clave] = stats["tipos_activo"].get(clave, 0) + 1
            
            # Algunos ejemplos
            for i, m in enumerate(self._maquinaria[:5]):
                stats["ejemplos"].append({
                    "index": i,
                    "codigo": m.get('codigo'),
                    "activo": m.get('activo'),
                    "tipo_activo": str(type(m.get('activo')).__name__),
                    "estado": m.get('estado')
                })
            
            return stats
            
        except Exception as e:
            print(f"❌ Error al obtener estadísticas debug: {str(e)}")
            return {}
