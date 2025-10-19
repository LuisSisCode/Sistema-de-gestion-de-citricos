from PySide6.QtCore import QObject, Slot, Signal, Property
#from bd_conecciones.bd_agricultores_parcelas import GestorAgricultoresParcelas
from backend import GestionServicio
import json

class AgricultoresParcelasModels(QObject):
    agricultoresChanged = Signal()
    parcelasChanged = Signal()
    propietariosChanged = Signal()
    operacionCompleta = Signal(str, bool, str)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.gestion = GestionServicio()
        #self._gestor = GestorAgricultoresParcelas()
        #Datos
        self._agricultores = []
        self._parcelas = []
        self._propietarios = []
        
        # Cargar datos iniciales
        #self.cargar_agricultores()
        #self.cargar_parcelas()
        #self.cargar_propietarios()

        # Estado de paginación
        self._pagina_actual_agricultores = 1
        self._total_paginas_agricultores = 1
        self._pagina_actual_parcelas = 1
        self._total_paginas_parcelas = 1
    
    @Property(list, notify=agricultoresChanged)
    def agricultores(self):
        return self._agricultores
    
    @Property(list, notify=parcelasChanged)
    def parcelas(self):
        return self._parcelas
    
    @Property(list, notify=propietariosChanged)
    def propietarios(self):
        return self._propietarios
    
    @Property(int, notify=agricultoresChanged)
    def paginaActualAgricultores(self):
        return self._pagina_actual_agricultores
    
    @Property(int, notify=agricultoresChanged)
    def totalPaginasAgricultores(self):
        return self._total_paginas_agricultores
    
    @Property(int, notify=parcelasChanged)
    def paginaActualParcelas(self):
        return self._pagina_actual_parcelas
    
    @Property(int, notify=parcelasChanged)
    def totalPaginasParcelas(self):
        return self._total_paginas_parcelas
    
    @Slot(int)
    def cargar_agricultores_pagina(self, pagina):
        """Carga agricultores con paginación usando servicios."""
        try:
            resultado = self.gestion.obtener_datos_paginados('agricultores', pagina, 10)
            
            self._agricultores = resultado.get('agricultores', [])
            self._pagina_actual_agricultores = resultado.get('pagina_actual', 1)
            self._total_paginas_agricultores = resultado.get('total_paginas', 1)
            
            self.agricultoresChanged.emit()
            print(f"Página {pagina} de agricultores cargada exitosamente")
            
        except Exception as e:
            print(f"Error al cargar agricultores página {pagina}: {str(e)}")
            self._agricultores = []
            self.agricultoresChanged.emit()
    
    def cargar_parcelas_pagina(self, pagina, propietario_id=0):
        """Carga parcelas con paginación usando servicios."""
        try:
            filtros = {'propietario_id': propietario_id} if propietario_id > 0 else None
            resultado = self.gestion.obtener_datos_paginados('parcelas', pagina, 6, filtros)
            
            self._parcelas = resultado.get('parcelas', [])
            self._pagina_actual_parcelas = resultado.get('pagina_actual', 1)
            self._total_paginas_parcelas = resultado.get('total_paginas', 1)
            
            self.parcelasChanged.emit()
            print(f"Página {pagina} de parcelas cargada exitosamente")
            
        except Exception as e:
            print(f"Error al cargar parcelas página {pagina}: {str(e)}")
            self._parcelas = []
            self.parcelasChanged.emit()
    
    @Slot(str, result=bool)
    def agregar_agricultor(self, agricultor_json):
        """Agrega un nuevo agricultor usando servicios."""
        try:
            datos_agricultor = json.loads(agricultor_json)
            resultado = self.gestion.procesar_operacion_agricultor('crear', {'agricultor': datos_agricultor})
            
            if resultado['exito']:
                # Recargar página actual
                self.cargar_agricultores_pagina(self._pagina_actual_agricultores)
                
                # Actualizar propietarios si es necesario
                if resultado.get('es_propietario', False):
                    self.cargar_propietarios()
                
                self.operacionCompleta.emit('crear_agricultor', True, resultado['mensaje'])
                return True
            else:
                self.operacionCompleta.emit('crear_agricultor', False, resultado['mensaje'])
                return False
                
        except Exception as e:
            print(f"Error al agregar agricultor: {str(e)}")
            self.operacionCompleta.emit('crear_agricultor', False, 'Error interno del sistema')
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_agricultor(self, id_agricultor, agricultor_json):
        """Actualiza un agricultor usando servicios."""
        try:
            datos_agricultor = json.loads(agricultor_json)
            resultado = self.gestion.procesar_operacion_agricultor('actualizar', {
                'id_agricultor': id_agricultor,
                'agricultor': datos_agricultor
            })
            
            if resultado['exito']:
                self.cargar_agricultores_pagina(self._pagina_actual_agricultores)
                
                if resultado.get('requiere_actualizacion_propietarios', False):
                    self.cargar_propietarios()
                
                self.operacionCompleta.emit('actualizar_agricultor', True, resultado['mensaje'])
                return True
            else:
                self.operacionCompleta.emit('actualizar_agricultor', False, resultado['mensaje'])
                return False
                
        except Exception as e:
            print(f"Error al actualizar agricultor: {str(e)}")
            self.operacionCompleta.emit('actualizar_agricultor', False, 'Error interno del sistema')
            return False
    
    @Slot(int, result='QVariant')
    def eliminar_agricultor(self, id_agricultor):
        """Elimina un agricultor usando servicios - retorna resultado detallado."""
        try:
            resultado = self.gestion.procesar_operacion_agricultor('eliminar', {'id_agricultor': id_agricultor})
            
            if resultado['exito']:
                self.cargar_agricultores_pagina(self._pagina_actual_agricultores)
                
                if resultado.get('requiere_actualizacion_propietarios', False):
                    self.cargar_propietarios()
                
                self.operacionCompleta.emit('eliminar_agricultor', True, resultado['mensaje'])
            else:
                self.operacionCompleta.emit('eliminar_agricultor', False, resultado['mensaje'])
            
            return resultado
            
        except Exception as e:
            print(f"Error al eliminar agricultor: {str(e)}")
            resultado_error = {
                'exito': False,
                'mensaje': 'Error interno del sistema',
                'tipo_error': 'interno'
            }
            self.operacionCompleta.emit('eliminar_agricultor', False, resultado_error['mensaje'])
            return resultado_error
    
    @Slot(int, result=bool)
    def desactivar_agricultor(self, id_agricultor):
        """Desactiva un agricultor en lugar de eliminarlo físicamente"""
        try:
            success = self._gestor.desactivar_agricultor(id_agricultor)
            if success:
                self.cargar_agricultores()
                self.cargar_propietarios()  # Actualizar la lista de propietarios
            return success
        except Exception as e:
            print(f"Error al desactivar agricultor: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def agregar_parcela(self, parcela_json):
        """Agrega una nueva parcela usando servicios."""
        try:
            datos_parcela = json.loads(parcela_json)
            resultado = self.gestion.procesar_operacion_parcela('crear', {'parcela': datos_parcela})
            
            if resultado['exito']:
                self.cargar_parcelas_pagina(self._pagina_actual_parcelas)
                self.operacionCompleta.emit('crear_parcela', True, resultado['mensaje'])
                return True
            else:
                self.operacionCompleta.emit('crear_parcela', False, resultado['mensaje'])
                return False
                
        except Exception as e:
            print(f"Error al agregar parcela: {str(e)}")
            self.operacionCompleta.emit('crear_parcela', False, 'Error interno del sistema')
            return False
    
    
    
    @Slot(int, str, result=bool)
    def actualizar_parcela(self, id_parcela, parcela_json):
        """Actualiza una parcela usando servicios."""
        try:
            datos_parcela = json.loads(parcela_json)
            resultado = self.gestion.procesar_operacion_parcela('actualizar', {
                'id_parcela': id_parcela,
                'parcela': datos_parcela
            })
            
            if resultado['exito']:
                self.cargar_parcelas_pagina(self._pagina_actual_parcelas)
                self.operacionCompleta.emit('actualizar_parcela', True, resultado['mensaje'])
                return True
            else:
                self.operacionCompleta.emit('actualizar_parcela', False, resultado['mensaje'])
                return False
                
        except Exception as e:
            print(f"Error al actualizar parcela: {str(e)}")
            self.operacionCompleta.emit('actualizar_parcela', False, 'Error interno del sistema')
            return False
    @Slot(int, result=bool)
    def eliminar_parcela(self, id_parcela):
        """Elimina una parcela usando servicios."""
        try:
            resultado = self.gestion.procesar_operacion_parcela('eliminar', {'id_parcela': id_parcela})
            
            if resultado['exito']:
                self.cargar_parcelas_pagina(self._pagina_actual_parcelas)
                self.operacionCompleta.emit('eliminar_parcela', True, resultado['mensaje'])
                return True
            else:
                self.operacionCompleta.emit('eliminar_parcela', False, resultado['mensaje'])
                return False
                
        except Exception as e:
            print(f"Error al eliminar parcela: {str(e)}")
            self.operacionCompleta.emit('eliminar_parcela', False, 'Error interno del sistema')
            return False
    @Slot(int, int, result=bool)
    def transferir_parcela(self, id_parcela, nuevo_propietario_id):
        """Transfiere una parcela a otro propietario."""
        try:
            resultado = self.gestion.procesar_operacion_parcela('transferir', {
                'id_parcela': id_parcela,
                'nuevo_propietario_id': nuevo_propietario_id
            })
            
            if resultado['exito']:
                self.cargar_parcelas_pagina(self._pagina_actual_parcelas)
                self.operacionCompleta.emit('transferir_parcela', True, resultado['mensaje'])
                return True
            else:
                self.operacionCompleta.emit('transferir_parcela', False, resultado['mensaje'])
                return False
                
        except Exception as e:
            print(f"Error al transferir parcela: {str(e)}")
            self.operacionCompleta.emit('transferir_parcela', False, 'Error interno del sistema')
            return False
    # ----------METODOS DE BUSQUEDA --------------------
    # Métodos adicionales para filtrado que pueden ser útiles desde QML
    
    @Slot(str, result=list)
    def filtrar_agricultores_por_nombre(self, texto):
        """Busca agricultores usando servicios."""
        try:
            return self.gestion.buscar_datos('agricultores', texto)
        except Exception as e:
            print(f"Error en búsqueda de agricultores: {str(e)}")
            return []
    
    @Slot(str, result=list)
    def filtrar_parcelas_por_nombre(self, texto):
        """Busca parcelas usando servicios."""
        try:
            return self.gestion.buscar_datos('parcelas', texto)
        except Exception as e:
            print(f"Error en búsqueda de parcelas: {str(e)}")
            return []
    
    @Slot(int, result=list)
    def obtener_parcelas_por_propietario(self, propietario_id):
        """Obtiene parcelas de un propietario específico."""
        try:
            return self.gestion.parcela_servicio.obtener_parcelas_por_propietario(propietario_id)
        except Exception as e:
            print(f"Error al obtener parcelas por propietario: {str(e)}")
            return []
    # -------------- METODOS DE CARGA INICIAL --------------
    @Slot()
    def cargar_agricultores(self):
        """Carga primera página de agricultores."""
        self.cargar_agricultores_pagina(1)

    @Slot()
    def cargar_parcelas(self):
        """Carga primera página de parcelas."""
        self.cargar_parcelas_pagina(1)
    
    @Slot()
    def cargar_propietarios(self):
        """Carga lista de propietarios."""
        try:
            self._propietarios = self.gestion.agricultor_servicio.obtener_propietarios_activos()
            self.propietariosChanged.emit()
            print(f"Propietarios cargados: {len(self._propietarios)}")
        except Exception as e:
            print(f"Error al cargar propietarios: {str(e)}")
            self._propietarios = []
            self.propietariosChanged.emit()
    # --------------- NAVEGACION DE PAGINAS ------------------
    @Slot()
    def pagina_anterior_agricultores(self):
        if self._pagina_actual_agricultores > 1:
            self.cargar_agricultores_pagina(self._pagina_actual_agricultores - 1)

    @Slot()
    def pagina_siguiente_agricultores(self):
        if self._pagina_actual_agricultores < self._total_paginas_agricultores:
            self.cargar_agricultores_pagina(self._pagina_actual_agricultores + 1)
        
    @Slot()
    def pagina_anterior_parcelas(self):
        if self._pagina_actual_parcelas > 1:
            self.cargar_parcelas_pagina(self._pagina_actual_parcelas - 1)
    
    @Slot()
    def pagina_siguiente_parcelas(self):
        if self._pagina_actual_parcelas < self._total_paginas_parcelas:
            self.cargar_parcelas_pagina(self._pagina_actual_parcelas + 1)
    
    # -------------------- METODOS Y REPORTES DE ESTADISTICAS -----------------
    @Slot(result='QVariant')
    def obtener_dashboard_completo(self):
        """Obtiene información completa para dashboard."""
        try:
            return self.gestion.obtener_dashboard_completo()
        except Exception as e:
            print(f"Error al obtener dashboard: {str(e)}")
            return {}
        
    @Slot(int, result='QVariant')
    def analizar_propietario(self, id_propietario):
        """Analiza estado completo de un propietario."""
        try:
            return self.gestion.analizar_estado_propietario(id_propietario)
        except Exception as e:
            print(f"Error al analizar propietario: {str(e)}")
            return {}
    
    @Slot(result='QVariant')
    def generar_reporte_completo(self):
        """Genera reporte completo del sistema."""
        try:
            return self.gestion.generar_reporte_completo()
        except Exception as e:
            print(f"Error al generar reporte: {str(e)}")
            return {}
        
    @Slot(result='QVariant')
    def validar_integridad_sistema(self):
        """Valida integridad completa del sistema."""
        try:
            return self.gestion.validar_integridad_sistema()
        except Exception as e:
            print(f"Error al validar integridad: {str(e)}")
            return {}
    
    # Para que 
    @Slot(str, result=bool)  # ✅ CORRECTO
    def agregar_problema(self, problema_json):
        """Agrega un nuevo problema reportado"""
        try:
            problema_data = json.loads(problema_json)
            # Por ahora solo logging, implementar BD después
            print(f"Problema reportado: {problema_data}")
            return True
        except Exception as e:
            print(f"Error al agregar problema: {e}")
            return False
    @Slot(str, result=bool)  # ✅ CORRECTO  
    def agregar_cosecha_programada(self, cosecha_json):
        """Agrega una nueva cosecha programada"""
        try:
            cosecha_data = json.loads(cosecha_json)
            # Por ahora solo logging, implementar BD después
            print(f"Cosecha programada: {cosecha_data}")
            return True
        except Exception as e:
            print(f"Error al programar cosecha: {e}")
            return False

    @Slot(result=str)
    def obtener_wms_url(self):
        """Devuelve la URL WMS de GeoServer"""
        return "http://localhost:8080/geoserver/wms"