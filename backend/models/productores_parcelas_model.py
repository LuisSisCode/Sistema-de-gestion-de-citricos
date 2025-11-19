from PySide6.QtCore import QObject, Slot, Signal, Property
from backend.services.ProductorParcelaServ.productor_servicio import ProductorServicio
from backend.services.ProductorParcelaServ.parcela_servicio import ParcelaServicio
import json

class ProductoresParcelasModels(QObject):
    productoresChanged = Signal()
    parcelasChanged = Signal()
    propietariosChanged = Signal()
    operacionCompleta = Signal(str, bool, str)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self.productor_servicio = ProductorServicio()
        self.parcela_servicio = ParcelaServicio()

        #Datos
        self._productores = []
        self._parcelas = []
        self._propietarios = []

        # Estado de paginación
        self._pagina_actual_productores = 1
        self._total_paginas_productores = 1
        self._pagina_actual_parcelas = 1
        self._total_paginas_parcelas = 1
    
    @Property(list, notify=productoresChanged)
    def productores(self):
        return self._productores
    
    @Property(list, notify=parcelasChanged)
    def parcelas(self):
        return self._parcelas
    
    @Property(int, notify=productoresChanged)
    def paginaActualProductores(self):
        return self._pagina_actual_productores
    
    @Property(int, notify=productoresChanged)
    def totalPaginasProductores(self):
        return self._total_paginas_productores
    
    @Property(int, notify=parcelasChanged)
    def paginaActualParcelas(self):
        return self._pagina_actual_parcelas
    
    @Property(int, notify=parcelasChanged)
    def totalPaginasParcelas(self):
        return self._total_paginas_parcelas
    
    @Slot(int)
    def cargar_productores_pagina(self, pagina):
        """Carga productores con paginación usando servicios."""
        try:
            resultado = self.productor_servicio.obtener_productores_paginado(pagina, 6)
            
            if resultado['exito']:
                datos = resultado['datos']
                self._productores = datos.get('productores', [])
                self._pagina_actual_productores = datos.get('pagina_actual', 1)
                self._total_paginas_productores = datos.get('total_paginas', 1)
                
                self.productoresChanged.emit()
                print(f"Página {pagina} de productores cargada exitosamente")
            else:
                print(f"Error al cargar productores página {pagina}: {resultado['mensaje']}")
                self._productores = []
                self.productoresChanged.emit()
            
        except Exception as e:
            print(f"Error al cargar productores página {pagina}: {str(e)}")
            self._productores = []
            self.productoresChanged.emit()

    @Slot(int)
    def cargar_parcelas_pagina(self, pagina, propietario_id=0):
        """Carga parcelas con paginación usando servicios."""
        try:
            resultado = self.parcela_servicio.obtener_parcelas_paginado(
                pagina, 6, propietario_id if propietario_id > 0 else None
            )
            
            if resultado['exito']:
                datos = resultado['datos']
                self._parcelas = datos.get('parcelas', [])
                self._pagina_actual_parcelas = datos.get('pagina_actual', 1)
                self._total_paginas_parcelas = datos.get('total_paginas', 1)
                
                self.parcelasChanged.emit()
                print(f"Página {pagina} de parcelas cargada exitosamente")
            else:
                print(f"Error al cargar parcelas página {pagina}: {resultado['mensaje']}")
                self._parcelas = []
                self.parcelasChanged.emit()
            
        except Exception as e:
            print(f"Error al cargar parcelas página {pagina}: {str(e)}")
            self._parcelas = []
            self.parcelasChanged.emit()
    
    @Slot(str, result=bool)
    def agregar_productor(self, productor_json):
        """Agrega un nuevo productor usando servicios."""
        try:
            datos_productor = json.loads(productor_json)
            resultado = self.productor_servicio.crear_productor(datos_productor)
            
            if resultado['exito']:
                from PySide6.QtCore import QTimer
                QTimer.singleShot(0, lambda: self.cargar_productores_pagina(self._pagina_actual_productores))
                
                self.operacionCompleta.emit('crear_productor', True, resultado['mensaje'])
                return True
            else:
                self.operacionCompleta.emit('crear_productor', False, resultado['mensaje'])
                return False
                
        except Exception as e:
            print(f"Error al agregar productor: {str(e)}")
            self.operacionCompleta.emit('crear_productor', False, 'Error interno del sistema')
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_productor(self, id_productor, productor_json):
        """Actualiza un productor usando servicios."""
        try:
            datos_productor = json.loads(productor_json)
            resultado = self.productor_servicio.actualizar_productor(id_productor, datos_productor)
            
            if resultado['exito']:
                from PySide6.QtCore import QTimer
                QTimer.singleShot(0, lambda: self.cargar_productores_pagina(self._pagina_actual_productores))
                
                self.operacionCompleta.emit('actualizar_productor', True, resultado['mensaje'])
                return True
            else:
                self.operacionCompleta.emit('actualizar_productor', False, resultado['mensaje'])
                return False
                
        except Exception as e:
            print(f"Error al actualizar productor: {str(e)}")
            self.operacionCompleta.emit('actualizar_productor', False, 'Error interno del sistema')
            return False
    
    @Slot(int, result='QVariant')
    def eliminar_productor(self, id_productor):
        """Elimina un productor usando servicios - retorna resultado detallado."""
        try:
            resultado = self.productor_servicio.eliminar_productor(id_productor)
            
            if resultado['exito']:
                self.cargar_productores_pagina(self._pagina_actual_productores)
                
                self.operacionCompleta.emit('eliminar_productor', True, resultado['mensaje'])
            else:
                self.operacionCompleta.emit('eliminar_productor', False, resultado['mensaje'])
            
            return resultado
            
        except Exception as e:
            print(f"Error al eliminar productor: {str(e)}")
            resultado_error = {
                'exito': False,
                'mensaje': 'Error interno del sistema',
                'tipo_error': 'interno'
            }
            self.operacionCompleta.emit('eliminar_productor', False, resultado_error['mensaje'])
            return resultado_error
    
    @Slot(int, result=bool)
    def desactivar_productor(self, id_productor):
        """Desactiva un productor en lugar de eliminarlo físicamente"""
        try:
            # Nota: El servicio actual usa desactivar como eliminación lógica
            resultado = self.productor_servicio.eliminar_productor(id_productor)
            if resultado['exito']:
                self.cargar_productores_pagina(self._pagina_actual_productores)
            return resultado['exito']
        except Exception as e:
            print(f"Error al desactivar productor: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def agregar_parcela(self, parcela_json):
        """Agrega una nueva parcela usando servicios."""
        try:
            datos_parcela = json.loads(parcela_json)
            resultado = self.parcela_servicio.crear_parcela(datos_parcela)
            
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
            resultado = self.parcela_servicio.actualizar_parcela(id_parcela, datos_parcela)
            
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
            resultado = self.parcela_servicio.eliminar_parcela(id_parcela)
            
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
    
    # ----------METODOS DE BUSQUEDA --------------------
    
    @Slot(str, result=list)
    def filtrar_productores_por_nombre(self, texto):
        """Busca productores usando servicios."""
        try:
            resultado = self.productor_servicio.buscar_productores(texto)
            return resultado.get('datos', []) if resultado['exito'] else []
        except Exception as e:
            print(f"Error en búsqueda de productores: {str(e)}")
            return []
    
    @Slot(str, result=list)
    def filtrar_parcelas_por_nombre(self, texto):
        """Busca parcelas usando servicios."""
        try:
            resultado = self.parcela_servicio.buscar_parcelas(texto)
            return resultado.get('datos', []) if resultado['exito'] else []
        except Exception as e:
            print(f"Error en búsqueda de parcelas: {str(e)}")
            return []
    
    @Slot(int, result=list)
    def obtener_parcelas_por_propietario(self, propietario_id):
        """Obtiene parcelas de un propietario específico."""
        try:
            resultado = self.parcela_servicio.obtener_parcelas_por_propietario(propietario_id)
            return resultado.get('datos', []) if resultado['exito'] else []
        except Exception as e:
            print(f"Error al obtener parcelas por propietario: {str(e)}")
            return []
    
    # -------------- METODOS DE CARGA INICIAL --------------
    @Slot()
    def cargar_productores(self):
        """Carga primera página de productores."""
        self.cargar_productores_pagina(1)

    @Slot()
    def cargar_parcelas(self):
        """Carga primera página de parcelas."""
        self.cargar_parcelas_pagina(1)
    

    # --------------- NAVEGACION DE PAGINAS ------------------
    @Slot()
    def pagina_anterior_productores(self):
        if self._pagina_actual_productores > 1:
            self.cargar_productores_pagina(self._pagina_actual_productores - 1)

    @Slot()
    def pagina_siguiente_productores(self):
        if self._pagina_actual_productores < self._total_paginas_productores:
            self.cargar_productores_pagina(self._pagina_actual_productores + 1)
        
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
            # Combinar estadísticas de productores y parcelas
            stats_productores = self.productor_servicio.obtener_estadisticas_productores()
            stats_parcelas = self.parcela_servicio.obtener_estadisticas_parcelas()
            
            dashboard = {
                'productores': stats_productores.get('datos', {}) if stats_productores['exito'] else {},
                'parcelas': stats_parcelas.get('datos', {}) if stats_parcelas['exito'] else {},
                'timestamp': self._get_timestamp()
            }
            
            return dashboard
            
        except Exception as e:
            print(f"Error al obtener dashboard: {str(e)}")
            return {}
        
    @Slot(int, result='QVariant')
    def analizar_propietario(self, id_propietario):
        """Analiza estado completo de un propietario."""
        try:
            # Obtener información del productor
            resultado_productor = self.productor_servicio.obtener_productor_por_id(id_propietario)
            
            if not resultado_productor['exito']:
                return {}
            
            # Obtener parcelas del propietario
            resultado_parcelas = self.parcela_servicio.obtener_parcelas_por_propietario(id_propietario)
            
            analisis = {
                'productor': resultado_productor.get('datos', {}),
                'parcelas': resultado_parcelas.get('datos', []),
                'estadisticas': {
                    'total_parcelas': len(resultado_parcelas.get('datos', [])),
                    'area_total': sum(p.get('area', 0) for p in resultado_parcelas.get('datos', [])),
                    'parcelas_con_coordenadas': sum(1 for p in resultado_parcelas.get('datos', []) 
                                                  if p.get('tiene_coordenadas', False))
                }
            }
            
            return analisis
            
        except Exception as e:
            print(f"Error al analizar propietario: {str(e)}")
            return {}
    
    @Slot(result='QVariant')
    def generar_reporte_completo(self):
        """Genera reporte completo del sistema."""
        try:
            # Obtener reportes de productores y parcelas
            reporte_productores = self.productor_servicio.obtener_reporte_productores_parcelas()
            reporte_parcelas = self.parcela_servicio.obtener_resumen_parcelas()
            
            reporte_completo = {
                'productores': reporte_productores.get('datos', []) if reporte_productores['exito'] else [],
                'parcelas': reporte_parcelas.get('datos', {}) if reporte_parcelas['exito'] else {},
                'top_productores': self.productor_servicio.obtener_top_productores_por_area(10).get('datos', []),
                'parcelas_sin_coordenadas': self.parcela_servicio.obtener_parcelas_sin_coordenadas().get('datos', []),
                'timestamp': self._get_timestamp()
            }
            
            return reporte_completo
            
        except Exception as e:
            print(f"Error al generar reporte: {str(e)}")
            return {}
    
    @Slot(str, result=bool)
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
    
    @Slot(str, result=bool)  
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

    def _get_timestamp(self):
        """Obtiene timestamp actual en formato ISO."""
        from datetime import datetime
        return datetime.now().isoformat()