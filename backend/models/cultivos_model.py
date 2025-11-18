from PySide6.QtCore import QObject, Slot, Signal, Property
from backend.services import (
    TipoCultivoServicio, 
    VariedadCultivoServicio,
    CicloProduccionServicio,
    GestionCultivoServicio
)
from backend.services.CultivosServ.lote_cosecha_servicio import LoteCosechaServicio
from backend.services.CultivosServ.analisis_rentabilidad_servicio import AnalisisRentabilidadServicio
import json
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

class CultivosModel(QObject):
    # Señales existentes
    tiposCultivoChanged = Signal()
    variedadesChanged = Signal()
    ciclosProduccionChanged = Signal()
    estadisticasChanged = Signal()
    
    # NUEVAS SEÑALES A AGREGAR:
    dashboardEjecutivoChanged = Signal()
    estadisticasAvanzadasChanged = Signal()
    prediccionesChanged = Signal()
    alertasChanged = Signal()
    busquedaGlobalChanged = Signal()
    validacionIntegridadChanged = Signal()
    reportesChanged = Signal()

    lotesCosechaChanged = Signal()
    lotesDisponiblesChanged = Signal()
    cosechaRegistradaSignal = Signal(dict) 
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._tipo_servicio = TipoCultivoServicio()
        self._variedad_servicio = VariedadCultivoServicio()
        self._ciclo_servicio = CicloProduccionServicio()
        self._gestion_servicio = GestionCultivoServicio()

        self._lote_servicio = LoteCosechaServicio()

        # Propiedades existentes
        self._tipos_cultivo = []
        self._variedades = []
        self._ciclos_produccion = []
        self._estadisticas = {}

        self._lotes_cosecha = []
        self._lotes_disponibles = []
        self._categorias_calidad = []
        
        # NUEVAS PROPIEDADES A AGREGAR:
        self._dashboard_ejecutivo = {}
        self._estadisticas_avanzadas = {}
        self._predicciones = {}
        self._alertas = []
        self._busqueda_global = {}
        self._validacion_integridad = {}
        self._reportes = {}
        
        # Cargar datos (USAR NUEVOS MÉTODOS)
        self.cargar_tipos_cultivo()
        self.cargar_variedades()
        self.cargar_ciclos_produccion()
        self.cargar_estadisticas()

        self.cargar_lotes_cosecha()
        self.cargar_categorias_calidad()

        self.cargar_dashboard_ejecutivo()
        self.cargar_alertas_sistema()
    # Propertys
    @Property(list, notify=tiposCultivoChanged)
    def tipos_cultivo(self):
        return self._tipos_cultivo
    
    @Property(list, notify=variedadesChanged)
    def variedades(self):
        return self._variedades
    
    @Property(list, notify=ciclosProduccionChanged)
    def ciclos_produccion(self):
        return self._ciclos_produccion
    
    @Property(dict, notify=estadisticasChanged)
    def estadisticas(self):
        return self._estadisticas
    # Nuevas Propiedades
    @Property(dict, notify=dashboardEjecutivoChanged)
    def dashboard_ejecutivo(self):
        return self._dashboard_ejecutivo

    @Property(dict, notify=estadisticasAvanzadasChanged)
    def estadisticas_avanzadas(self):
        return self._estadisticas_avanzadas

    @Property(dict, notify=prediccionesChanged)
    def predicciones(self):
        return self._predicciones

    @Property(list, notify=alertasChanged)
    def alertas(self):
        return self._alertas

    @Property(dict, notify=busquedaGlobalChanged)
    def busqueda_global(self):
        return self._busqueda_global

    @Property(dict, notify=validacionIntegridadChanged)
    def validacion_integridad(self):
        return self._validacion_integridad

    @Property(dict, notify=reportesChanged)
    def reportes(self):
        return self._reportes
    
    @Property(list, notify=lotesCosechaChanged)
    def lotes_cosecha(self):
        return self._lotes_cosecha
    
    @Property(list, notify=lotesDisponiblesChanged)
    def lotes_disponibles(self):
        return self._lotes_disponibles
    
    @Property(list, notify=lotesCosechaChanged)
    def categorias_calidad(self):
        return self._categorias_calidad

    
    @Slot()
    def cargar_tipos_cultivo(self):
        """Carga la lista de tipos de cultivo desde la base de datos"""
        try:
            self._tipos_cultivo = self._tipo_servicio.obtener_tipos_cultivo_activos()
            self.tiposCultivoChanged.emit()
        except Exception as e:
            print(f"Error al cargar tipos de cultivo: {str(e)}")
    
    @Slot()
    def cargar_variedades(self):
        """Carga la lista de variedades desde la base de datos"""
        try:
            self._variedades = self._variedad_servicio.obtener_variedades_cultivo()
            self.variedadesChanged.emit()
        except Exception as e:
            print(f"Error al cargar variedades: {str(e)}")
    
    @Slot(int)
    def cargar_variedades_por_tipo(self, id_tipo_cultivo):
        """Carga las variedades para un tipo de cultivo específico"""
        try:
            self._variedades = self._variedad_servicio.obtener_variedades_por_tipo(id_tipo_cultivo)
            self.variedadesChanged.emit()
            print(f"Variedades por tipo {id_tipo_cultivo}: {len(self._variedades)}")
        except Exception as e:
            print(f"Error al cargar variedades por tipo: {str(e)}")
            self._variedades = []
            self.variedadesChanged.emit()
    
    @Slot()
    def cargar_ciclos_produccion(self):
        """Carga la lista de ciclos de producción desde la base de datos"""
        try:
            self._ciclos_produccion = self._ciclo_servicio.obtener_ciclos_paginado(0)
            self.ciclosProduccionChanged.emit()
            print(f"Ciclos de producción cargados: {len(self._ciclos_produccion)}")
        except Exception as e:
            print(f"Error al cargar ciclos de producción: {str(e)}")
            self._ciclos_produccion = []
            self.ciclosProduccionChanged.emit()
    
    @Slot(int)
    def cargar_ciclos_por_parcela(self, id_parcela):
        """Carga los ciclos de producción para una parcela específica"""
        try:
            self._ciclos_produccion = self._ciclo_servicio.obtener_ciclos_produccion(id_parcela=id_parcela)
            self.ciclosProduccionChanged.emit()
        except Exception as e:
            print(f"Error al cargar ciclos por parcela: {str(e)}")
    
    @Slot(str)
    def cargar_ciclos_por_estado(self, estado):
        """Carga los ciclos de producción filtrados por estado"""
        try:
            self._ciclos_produccion = self._ciclo_servicio.obtener_ciclos_por_estado(estado)
            self.ciclosProduccionChanged.emit()
        except Exception as e:
            print(f"Error al cargar ciclos por estado: {str(e)}")
    
    @Slot()
    def cargar_estadisticas(self):
        """Carga las estadísticas de cultivos desde la base de datos"""
        try:
            self._estadisticas = self._gestion_servicio.relacion_repo.obtener_estadisticas_generales()
            self.estadisticasChanged.emit()
            print("Estadísticas cargadas correctamente")
        except Exception as e:
            print(f"Error al cargar estadísticas: {str(e)}")
            self._estadisticas = {}
            self.estadisticasChanged.emit()
    
    @Slot(str, result=bool)
    def agregar_tipo_cultivo(self, tipo_data_json):
        """Agrega un nuevo tipo de cultivo a la base de datos"""
        try:
            tipo_data = json.loads(tipo_data_json)
            resultado = self._tipo_servicio.crear_tipo_cultivo(tipo_data)
            
            if resultado.get('exito'):
                self.cargar_tipos_cultivo()
                self.cargar_estadisticas()
                print(f"Tipo de cultivo creado: {resultado.get('mensaje', 'Éxito')}")
                return True
            else:
                print(f"Error al crear tipo: {resultado.get('mensaje', 'Error desconocido')}")
                return False
        except Exception as e:
            print(f"Error al agregar tipo de cultivo: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_tipo_cultivo(self, id_tipo_cultivo, tipo_data_json):
        """Actualiza un tipo de cultivo existente"""
        try:
            tipo_data = json.loads(tipo_data_json)
            resultado = self._tipo_servicio.actualizar_tipo_cultivo(id_tipo_cultivo, tipo_data)
            
            if resultado.get('exito'):
                self.cargar_tipos_cultivo()
                self.cargar_estadisticas()
                print(f"Tipo de cultivo actualizado: {resultado.get('mensaje', 'Éxito')}")
                return True
            else:
                print(f"Error al actualizar tipo: {resultado.get('mensaje', 'Error desconocido')}")
                return False
        except Exception as e:
            print(f"Error al actualizar tipo de cultivo: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_tipo_cultivo(self, id_tipo_cultivo):
        """Elimina un tipo de cultivo existente"""
        try:
            resultado = self._tipo_servicio.eliminar_tipo_cultivo(id_tipo_cultivo)
            
            if resultado.get('exito'):
                self.cargar_tipos_cultivo()
                self.cargar_estadisticas()
                print(f"Tipo de cultivo eliminado: {resultado.get('mensaje', 'Éxito')}")
                return True
            else:
                print(f"Error al eliminar tipo: {resultado.get('mensaje', 'Error desconocido')}")
                return False
        except Exception as e:
            print(f"Error al eliminar tipo de cultivo: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def desactivar_tipo_cultivo(self, id_tipo_cultivo):
        """Desactiva un tipo de cultivo en lugar de eliminarlo físicamente"""
        try:
            # Usar el método de eliminación que ya maneja la desactivación
            return self.eliminar_tipo_cultivo(id_tipo_cultivo)
        except Exception as e:
            print(f"Error al desactivar tipo de cultivo: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def agregar_variedad_cultivo(self, variedad_data_json):
        """Agrega una nueva variedad de cultivo a la base de datos"""
        try:
            variedad_data = json.loads(variedad_data_json)
            resultado = self._variedad_servicio.crear_variedad_cultivo(variedad_data)
            
            if resultado.get('exito'):
                self.cargar_variedades()
                self.cargar_estadisticas()
                print(f"Variedad creada: {resultado.get('mensaje', 'Éxito')}")
                return True
            else:
                print(f"Error al crear variedad: {resultado.get('mensaje', 'Error desconocido')}")
                return False
        except Exception as e:
            print(f"Error al agregar variedad de cultivo: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_variedad_cultivo(self, id_variedad, variedad_data_json):
        """Actualiza una variedad de cultivo existente"""
        try:
            variedad_data = json.loads(variedad_data_json)
            resultado = self._variedad_servicio.actualizar_variedad_cultivo(id_variedad, variedad_data)
            
            if resultado.get('exito'):
                self.cargar_variedades()
                self.cargar_estadisticas()
                print(f"Variedad actualizada: {resultado.get('mensaje', 'Éxito')}")
                return True
            else:
                print(f"Error al actualizar variedad: {resultado.get('mensaje', 'Error desconocido')}")
                return False
        except Exception as e:
            print(f"Error al actualizar variedad de cultivo: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_variedad_cultivo(self, id_variedad):
        """Elimina una variedad de cultivo existente"""
        try:
            resultado = self._variedad_servicio.eliminar_variedad_cultivo(id_variedad)
            
            if resultado.get('exito'):
                self.cargar_variedades()
                self.cargar_estadisticas()
                print(f"Variedad eliminada: {resultado.get('mensaje', 'Éxito')}")
                return True
            else:
                print(f"Error al eliminar variedad: {resultado.get('mensaje', 'Error desconocido')}")
                return False
        except Exception as e:
            print(f"Error al eliminar variedad de cultivo: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def desactivar_variedad_cultivo(self, id_variedad):
        """Desactiva una variedad de cultivo en lugar de eliminarla físicamente"""
        try:
            return self.eliminar_variedad_cultivo(id_variedad)
        except Exception as e:
            print(f"Error al desactivar variedad de cultivo: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def agregar_ciclo_produccion(self, ciclo_data_json):
        """Agrega un nuevo ciclo de producción a la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            ciclo_data = json.loads(ciclo_data_json)
            success, _ = self._ciclo_servicio.crear_ciclo_produccion_ciclo_produccion(ciclo_data)
            if success:
                self.cargar_ciclos_produccion()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al agregar ciclo de producción: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_ciclo_produccion(self, id_ciclo, ciclo_data_json):
        """Actualiza un ciclo de producción existente"""
        try:
            # Convertir el string JSON a diccionario
            ciclo_data = json.loads(ciclo_data_json)
            success = self._ciclo_servicio.actualizar_ciclo_produccion(id_ciclo, ciclo_data)
            if success:
                self.cargar_ciclos_produccion()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al actualizar ciclo de producción: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_ciclo_produccion(self, id_ciclo):
        """Elimina un ciclo de producción existente"""
        try:
            success = self._ciclo_servicio.eliminar_ciclo_produccion(id_ciclo)
            if success:
                self.cargar_ciclos_produccion()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al eliminar ciclo de producción: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def cambiar_estado_ciclo(self, id_ciclo, nuevo_estado):
        """Cambia el estado de un ciclo de producción"""
        try:
            success = self._ciclo_servicio.cambiar_estado_ciclo(id_ciclo, nuevo_estado)
            if success:
                self.cargar_ciclos_produccion()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al cambiar estado del ciclo: {str(e)}")
            return False
    
    @Slot(int, result=list)
    def obtener_tipos_cultivo_lista(self):
        """Devuelve la lista de tipos de cultivo como una lista para usar en combobox"""
        tipos_lista = []
        for tipo in self._tipos_cultivo:
            if tipo['activo']:
                tipos_lista.append({
                    'value': tipo['id_tipo_cultivo'],
                    'text': tipo['nombre']
                })
        return tipos_lista
    
    @Slot(int, result=list)
    def obtener_variedades_por_tipo_lista(self, id_tipo_cultivo):
        """Devuelve la lista de variedades para un tipo como una lista para usar en combobox"""
        variedades_lista = []
        self.cargar_variedades_por_tipo(id_tipo_cultivo)
        for variedad in self._variedades:
            if variedad['activo']:
                variedades_lista.append({
                    'value': variedad['id_variedad'],
                    'text': variedad['nombre']
                })
        return variedades_lista
    
    @Slot(result=list)
    def obtener_estados_ciclo_lista(self):
        """Devuelve la lista de estados posibles para ciclos de producción"""
        return [
            {'value': 'Planificado', 'text': 'Planificado'},
            {'value': 'En Preparación', 'text': 'En Preparación'},
            {'value': 'Sembrado', 'text': 'Sembrado'},
            {'value': 'En Desarrollo', 'text': 'En Desarrollo'},
            {'value': 'En Cosecha', 'text': 'En Cosecha'},
            {'value': 'Finalizado', 'text': 'Finalizado'},
            {'value': 'Cancelado', 'text': 'Cancelado'}
        ]
    @Slot()
    def cargar_dashboard_ejecutivo(self):
        """Carga el dashboard ejecutivo completo con KPIs y análisis."""
        try:
            dashboard = self._gestion_servicio.obtener_dashboard_ejecutivo()
            self._dashboard_ejecutivo = dashboard
            self.dashboardEjecutivoChanged.emit()
            print(f"Dashboard ejecutivo cargado: {len(dashboard)} secciones")
        except Exception as e:
            print(f"Error al cargar dashboard ejecutivo: {str(e)}")
            self._dashboard_ejecutivo = {'error': str(e)}
            self.dashboardEjecutivoChanged.emit()
    @Slot()
    def cargar_estadisticas_avanzadas(self):
        """Carga estadísticas avanzadas de todos los servicios."""
        try:
            estadisticas = {
                'tipos_cultivo': self._tipo_servicio.obtener_estadisticas_tipos_cultivo(),
                'variedades': self._variedad_servicio.obtener_estadisticas_variedades(),
                'ciclos_produccion': self._ciclo_servicio.obtener_estadisticas_ciclos(),
                'timestamp': self._get_timestamp()
            }
            self._estadisticas_avanzadas = estadisticas
            self.estadisticasAvanzadasChanged.emit()
        except Exception as e:
            print(f"Error al cargar estadísticas avanzadas: {str(e)}")

    @Slot()
    def cargar_predicciones_sistema(self):
        """Carga predicciones y análisis de tendencias."""
        try:
            predicciones = self._gestion_servicio.analizar_tendencias_predictivas()
            self._predicciones = predicciones
            self.prediccionesChanged.emit()
        except Exception as e:
            print(f"Error al cargar predicciones: {str(e)}")
    
    @Slot()
    def cargar_alertas_sistema(self):
        """Carga alertas del sistema de cultivos."""
        try:
            dashboard = self._gestion_servicio.obtener_dashboard_ejecutivo()
            alertas = dashboard.get('alertas_ejecutivas', [])
            self._alertas = alertas
            self.alertasChanged.emit()
        except Exception as e:
            print(f"Error al cargar alertas: {str(e)}")
            self._alertas = [{'tipo': 'error', 'mensaje': str(e)}]
            self.alertasChanged.emit()
        
    @Slot(str)
    def buscar_global_cultivos(self, texto_busqueda):
        """Busca en todo el sistema de cultivos."""
        try:
            if len(texto_busqueda.strip()) < 2:
                self._busqueda_global = {'resultados': [], 'total': 0}
                self.busquedaGlobalChanged.emit()
                return

            # Usar servicios individuales para búsquedas
            tipos = self._tipo_servicio.buscar_tipos_cultivo(texto_busqueda)
            variedades = self._variedad_servicio.buscar_variedades(texto_busqueda)
            
            # Organizar resultados
            resultados = {
                'tipos_cultivo': tipos,
                'variedades': variedades,
                'total_resultados': len(tipos) + len(variedades),
                'termino_busqueda': texto_busqueda
            }
            
            self._busqueda_global = resultados
            self.busquedaGlobalChanged.emit()
            
        except Exception as e:
            print(f"Error en búsqueda global: {str(e)}")

    @Slot(str, result=list)
    def buscar_tipos_cultivo_avanzado(self, texto_busqueda):
        """Búsqueda avanzada de tipos de cultivo con información enriquecida."""
        try:
            tipos = self._tipo_servicio.buscar_tipos_cultivo(texto_busqueda)
            return tipos
        except Exception as e:
            print(f"Error en búsqueda avanzada de tipos: {str(e)}")
            return []

    @Slot(str, result=list)
    def buscar_variedades_avanzado(self, texto_busqueda):
        """Búsqueda avanzada de variedades con información enriquecida."""
        try:
            variedades = self._variedad_servicio.buscar_variedades(texto_busqueda)
            return variedades
        except Exception as e:
            print(f"Error en búsqueda avanzada de variedades: {str(e)}")
            return []

    # ==================== OPERACIONES COORDINADAS ====================

    @Slot(str, str, str, result=bool)
    def ejecutar_operacion_coordinada(self, operacion, entidad, datos_json):
        """Ejecuta operaciones que requieren coordinación entre servicios."""
        try:
            datos = json.loads(datos_json)
            resultado = self._gestion_servicio.procesar_operacion_coordinada(operacion, entidad, datos)
            
            if resultado.get('exito'):
                # Actualizar datos relevantes
                self._actualizar_datos_segun_operacion(operacion, entidad)
                return True
            else:
                print(f"Operación falló: {resultado.get('mensaje', 'Error desconocido')}")
                return False
                
        except Exception as e:
            print(f"Error en operación coordinada: {str(e)}")
            return False

    # ==================== PAGINACIÓN AVANZADA ====================

    @Slot(int, int, result=dict)
    def obtener_tipos_cultivo_paginado(self, pagina, por_pagina):
        """Obtiene tipos de cultivo con paginación y datos enriquecidos."""
        try:
            resultado = self._tipo_servicio.obtener_tipos_cultivo_paginado(pagina, por_pagina)
            return resultado
        except Exception as e:
            print(f"Error en paginación de tipos: {str(e)}")
            return {'tipos_cultivo': [], 'total_registros': 0, 'total_paginas': 0}

    @Slot(int, int, result=dict)
    def obtener_variedades_paginado(self, pagina, por_pagina):
        """Obtiene variedades con paginación"""
        try:
            resultado = self._variedad_servicio.obtener_variedades_paginado(pagina, por_pagina, None)
            print(f"Paginación variedades - Página {pagina}: {len(resultado.get('variedades', []))} elementos")
            return resultado
        except Exception as e:
            print(f"Error en paginación de variedades: {str(e)}")
            return {
                'variedades': [],
                'total_registros': 0,
                'total_paginas': 0,
                'pagina_actual': 1
            }

    @Slot(int, int, str, result=dict)
    def obtener_ciclos_paginado_con_filtros(self, pagina, por_pagina, filtros_json):
        """Obtiene ciclos con paginación y filtros avanzados."""
        try:
            filtros = json.loads(filtros_json) if filtros_json else None
            resultado = self._ciclo_servicio.obtener_ciclos_paginado(pagina, por_pagina, filtros)
            return resultado
        except Exception as e:
            print(f"Error en paginación de ciclos: {str(e)}")
            return {'ciclos': [], 'total_registros': 0, 'total_paginas': 0}

    # ==================== GESTIÓN DE ESTADOS AVANZADA ====================

    @Slot(int, str, str, result=bool)
    def avanzar_estado_ciclo_coordinado(self, id_ciclo, nuevo_estado, datos_adicionales_json):
        """Avanza el estado de un ciclo con validaciones de flujo de trabajo."""
        try:
            datos_adicionales = json.loads(datos_adicionales_json) if datos_adicionales_json else None
            resultado = self._ciclo_servicio.avanzar_estado_ciclo(id_ciclo, nuevo_estado, datos_adicionales)
            
            if resultado.get('exito'):
                self.cargar_ciclos_produccion()
                self.cargar_estadisticas()
                self.cargar_alertas_sistema()
                return True
            else:
                print(f"Error avanzando estado: {resultado.get('mensaje')}")
                return False
                
        except Exception as e:
            print(f"Error en avance de estado coordinado: {str(e)}")
            return False

    @Slot(int, str, result=bool)
    def finalizar_ciclo_coordinado(self, id_ciclo, datos_finalizacion_json):
        """Finaliza un ciclo con datos de cosecha y análisis."""
        try:
            datos_finalizacion = json.loads(datos_finalizacion_json)
            resultado = self._ciclo_servicio.finalizar_ciclo_produccion(id_ciclo, datos_finalizacion)
            
            if resultado.get('exito'):
                self.cargar_ciclos_produccion()
                self.cargar_estadisticas()
                self.cargar_dashboard_ejecutivo()
                print(f"Ciclo finalizado. Eficiencia temporal: {resultado.get('eficiencia_tiempo', 'N/A')}%")
                return True
            else:
                print(f"Error finalizando ciclo: {resultado.get('mensaje')}")
                return False
                
        except Exception as e:
            print(f"Error en finalización coordinada: {str(e)}")
            return False

    # ==================== VALIDACIÓN Y INTEGRIDAD ====================

    @Slot(int, result=dict)
    def verificar_estado_tipo_cultivo(self, id_tipo_cultivo):
        """Verifica el estado completo de un tipo de cultivo."""
        try:
            estado = self._tipo_servicio.verificar_estado_tipo_cultivo(id_tipo_cultivo)
            return estado if estado else {}
        except Exception as e:
            print(f"Error verificando estado de tipo: {str(e)}")
            return {}

    @Slot(int, result=dict)
    def verificar_estado_variedad(self, id_variedad):
        """Verifica el estado completo de una variedad."""
        try:
            estado = self._variedad_servicio.verificar_estado_variedad(id_variedad)
            return estado if estado else {}
        except Exception as e:
            print(f"Error verificando estado de variedad: {str(e)}")
            return {}

    # ==================== REPORTES EJECUTIVOS ====================

    @Slot(str, str)
    def generar_reporte_ejecutivo(self, tipo_reporte, filtros_json):
        """Genera reportes ejecutivos específicos."""
        try:
            filtros = json.loads(filtros_json) if filtros_json else None
            reporte = self._gestion_servicio.generar_reporte_ejecutivo(tipo_reporte, filtros)
            
            self._reportes[tipo_reporte] = reporte
            self.reportesChanged.emit()
            
            print(f"Reporte '{tipo_reporte}' generado exitosamente")
            
        except Exception as e:
            print(f"Error generando reporte {tipo_reporte}: {str(e)}")

    @Slot(result=dict)
    def obtener_recomendaciones_optimizacion(self):
        """Obtiene recomendaciones para optimizar el sistema."""
        try:
            recomendaciones = self._gestion_servicio.generar_recomendaciones_optimizacion()
            return recomendaciones
        except Exception as e:
            print(f"Error obteniendo recomendaciones: {str(e)}")
            return {}

    # ==================== ANÁLISIS ESPECÍFICOS ====================

    @Slot(result=list)
    def obtener_ciclos_activos_monitoreados(self):
        """Obtiene ciclos activos con información de monitoreo."""
        try:
            ciclos_data = self._ciclo_servicio.obtener_ciclos_activos_enriquecidos()
            return ciclos_data.get('ciclos_por_estado', {})
        except Exception as e:
            print(f"Error obteniendo ciclos monitoreados: {str(e)}")
            return {}

    @Slot(str, result=list)
    def obtener_ciclos_por_estado_avanzado(self, estado):
        """Obtiene ciclos por estado con información enriquecida."""
        try:
            ciclos = self._ciclo_servicio.obtener_ciclos_por_estado(estado)
            return ciclos
        except Exception as e:
            print(f"Error obteniendo ciclos por estado: {str(e)}")
            return []

    @Slot(int, result=list)
    def obtener_variedades_por_tipo_enriquecidas(self, id_tipo_cultivo):
        """Obtiene variedades por tipo con información enriquecida."""
        try:
            variedades = self._variedad_servicio.obtener_variedades_por_tipo(id_tipo_cultivo)
            return variedades
        except Exception as e:
            print(f"Error obteniendo variedades enriquecidas: {str(e)}")
            return []

    @Slot(float, result=list)
    def obtener_variedades_alto_rendimiento(self, rendimiento_minimo):
        """Obtiene variedades con alto rendimiento."""
        try:
            variedades = self._variedad_servicio.obtener_variedades_alto_rendimiento(rendimiento_minimo)
            return variedades
        except Exception as e:
            print(f"Error obteniendo variedades de alto rendimiento: {str(e)}")
            return []

    @Slot(int, int, result=list)
    def obtener_tipos_por_tiempo_cosecha(self, tiempo_min, tiempo_max):
        """Obtiene tipos de cultivo filtrados por tiempo de cosecha."""
        try:
            tipos = self._tipo_servicio.obtener_tipos_por_tiempo_cosecha(tiempo_min, tiempo_max)
            return tipos
        except Exception as e:
            print(f"Error obteniendo tipos por tiempo: {str(e)}")
            return []

    # ==================== MÉTODOS DE UTILIDAD ====================

    @Slot(result=dict)
    def obtener_resumen_tipos_dashboard(self):
        """Obtiene resumen de tipos para dashboard."""
        try:
            resumen = self._tipo_servicio.obtener_resumen_tipos_cultivo()
            return resumen
        except Exception as e:
            print(f"Error obteniendo resumen de tipos: {str(e)}")
            return {}

    @Slot(result=dict)
    def obtener_resumen_variedades_dashboard(self):
        """Obtiene resumen de variedades para dashboard."""
        try:
            resumen = self._variedad_servicio.obtener_resumen_variedades()
            return resumen
        except Exception as e:
            print(f"Error obteniendo resumen de variedades: {str(e)}")
            return {}
        
    # ==================== MÉTODOS DE CARGA DE COSECHAS ====================
    
    @Slot()
    def cargar_lotes_cosecha(self):
        """Carga la lista de lotes de cosecha desde la base de datos"""
        try:
            resultado = self._lote_servicio.obtener_lotes_paginado(1, 100)  # Primeras 100
            self._lotes_cosecha = resultado.get('lotes', [])
            self.lotesCosechaChanged.emit()
            print(f"Lotes de cosecha cargados: {len(self._lotes_cosecha)}")
        except Exception as e:
            print(f"Error al cargar lotes de cosecha: {str(e)}")
            self._lotes_cosecha = []
            self.lotesCosechaChanged.emit()
    
    @Slot()
    def cargar_lotes_disponibles_venta(self):
        """Carga lotes disponibles para venta"""
        try:
            self._lotes_disponibles = self._lote_servicio.obtener_lotes_disponibles_venta()
            self.lotesDisponiblesChanged.emit()
            print(f"Lotes disponibles para venta: {len(self._lotes_disponibles)}")
        except Exception as e:
            print(f"Error al cargar lotes disponibles: {str(e)}")
            self._lotes_disponibles = []
            self.lotesDisponiblesChanged.emit()
    
    @Slot()
    def cargar_categorias_calidad(self):
        """Carga las categorías de calidad disponibles"""
        try:
            # Simulación - en tu BD real, tendrías un repositorio para esto
            self._categorias_calidad = [
                {'id_categoria': 1, 'nombre': 'Primera Calidad', 'descripcion': 'Producto premium'},
                {'id_categoria': 2, 'nombre': 'Segunda Calidad', 'descripcion': 'Producto estándar'},
                {'id_categoria': 3, 'nombre': 'Tercera Calidad', 'descripcion': 'Producto básico'},
                {'id_categoria': 4, 'nombre': 'Descarte', 'descripcion': 'Para procesamiento'}
            ]
            self.lotesCosechaChanged.emit()
        except Exception as e:
            print(f"Error al cargar categorías de calidad: {str(e)}")
            self._categorias_calidad = []   

    @Slot()
    def actualizar_todos_los_datos(self):
        """Actualiza todos los datos del modelo."""
        try:
            # Datos básicos
            self.cargar_tipos_cultivo()
            self.cargar_variedades()
            self.cargar_ciclos_produccion()
            self.cargar_estadisticas()
            
            # Datos avanzados
            self.cargar_dashboard_ejecutivo()
            self.cargar_estadisticas_avanzadas()
            self.cargar_alertas_sistema()
            
            print("Todos los datos actualizados exitosamente")
            
        except Exception as e:
            print(f"Error actualizando datos: {str(e)}")

    def _actualizar_datos_segun_operacion(self, operacion, entidad):
        """Actualiza datos específicos según la operación realizada."""
        if entidad == 'tipo_cultivo':
            self.cargar_tipos_cultivo()
        elif entidad == 'variedad':
            self.cargar_variedades()
        elif entidad == 'ciclo':
            self.cargar_ciclos_produccion()
        
        # Siempre actualizar estadísticas y dashboard
        self.cargar_estadisticas()
        self.cargar_dashboard_ejecutivo()

    def _get_timestamp(self):
        """Obtiene timestamp actual."""
        from datetime import datetime
        return datetime.now().isoformat()

    # ==================== MÉTODOS DE COMPATIBILIDAD ====================
    # Estos métodos reemplazan los existentes para usar los nuevos servicios

    def cargar_tipos_cultivo_nuevo(self):
        """
        REEMPLAZA el método cargar_tipos_cultivo existente.
        Usar el nuevo servicio en lugar del gestor antiguo.
        """
        try:
            tipos_activos = self._tipo_servicio.obtener_tipos_cultivo_activos()
            self._tipos_cultivo = tipos_activos
            self.tiposCultivoChanged.emit()
        except Exception as e:
            print(f"Error al cargar tipos de cultivo con nuevo servicio: {str(e)}")

    def cargar_variedades_nuevo(self):
        """
        REEMPLAZA el método cargar_variedades existente.
        Usar el nuevo servicio en lugar del gestor antiguo.
        """
        try:
            variedades_todas = self._variedad_servicio.obtener_variedades()  # 0 = todas
            self._variedades = variedades_todas
            self.variedadesChanged.emit()
        except Exception as e:
            print(f"Error al cargar variedades con nuevo servicio: {str(e)}")

    def cargar_variedades_por_tipo_nuevo(self, id_tipo_cultivo):
        """
        REEMPLAZA el método cargar_variedades_por_tipo existente.
        """
        try:
            variedades = self._variedad_servicio.obtener_variedades_por_tipo(id_tipo_cultivo)
            self._variedades = variedades
            self.variedadesChanged.emit()
        except Exception as e:
            print(f"Error al cargar variedades por tipo con nuevo servicio: {str(e)}")

    def cargar_ciclos_produccion_nuevo(self):
        """
        REEMPLAZA el método cargar_ciclos_produccion existente.
        """
        try:
            ciclos_activos = self._ciclo_servicio.obtener_ciclos_activos_enriquecidos()
            # Convertir a formato plano para compatibilidad
            ciclos_lista = []
            for estado, ciclos in ciclos_activos.get('ciclos_por_estado', {}).items():
                ciclos_lista.extend(ciclos)
            
            self._ciclos_produccion = ciclos_lista
            self.ciclosProduccionChanged.emit()
        except Exception as e:
            print(f"Error al cargar ciclos con nuevo servicio: {str(e)}")

    # ==================== CONFIGURACIONES ADICIONALES ====================

    @Slot(result=list)
    def obtener_configuracion_dashboard(self):
        """Obtiene configuración para widgets del dashboard."""
        return [
            {'tipo': 'kpi', 'titulo': 'Tipos Activos', 'key': 'tipos_activos'},
            {'tipo': 'kpi', 'titulo': 'Ciclos en Proceso', 'key': 'ciclos_activos'},
            {'tipo': 'kpi', 'titulo': 'Área Total', 'key': 'area_total', 'unidad': 'ha'},
            {'tipo': 'kpi', 'titulo': 'Tasa de Éxito', 'key': 'tasa_exito', 'unidad': '%'},
            {'tipo': 'grafico', 'titulo': 'Distribución por Estado', 'key': 'distribucion_estados'},
            {'tipo': 'tabla', 'titulo': 'Top Variedades', 'key': 'top_variedades'}
        ]

    @Slot(result=dict)
    def obtener_configuracion_formularios(self):
        """Obtiene configuración para formularios dinámicos."""
        return {
            'tipo_cultivo': {
                'campos': ['nombre', 'descripcion', 'tiempo_cosecha_min', 'tiempo_cosecha_max'],
                'validaciones': {'nombre': {'required': True, 'min_length': 3}}
            },
            'variedad': {
                'campos': ['id_tipo_cultivo', 'nombre', 'tiempo_produccion', 'resistencia_zona'],
                'validaciones': {'nombre': {'required': True}, 'id_tipo_cultivo': {'required': True}}
            },
            'ciclo': {
                'campos': ['id_parcela', 'id_variedad', 'fecha_siembra', 'area_sembrada', 'densidad_siembra'],
                'validaciones': {'id_parcela': {'required': True}, 'area_sembrada': {'required': True, 'min_value': 0}}
            }
        }
    @Slot(int, int, result=dict)
    def obtener_tipos_paginado(self, pagina, por_pagina):
        """Obtiene tipos de cultivo con paginación"""
        try:
            resultado = self._tipo_servicio.obtener_tipos_cultivo_paginado(pagina, por_pagina)
            print(f"Paginación tipos - Página {pagina}: {len(resultado.get('tipos_cultivo', []))} elementos")
            return resultado
        except Exception as e:
            print(f"Error en paginación de tipos: {str(e)}")
            return {
                'tipos_cultivo': [],
                'total_registros': 0,
                'total_paginas': 0,
                'pagina_actual': 1
            }
    @Slot(int, int, result=dict)
    def obtener_ciclos_paginado(self, pagina, por_pagina):
        """Obtiene ciclos de producción con paginación"""
        try:
            resultado = self._ciclo_servicio.obtener_ciclos_paginado(pagina, por_pagina, None)
            print(f"Paginación ciclos - Página {pagina}: {len(resultado.get('ciclos', []))} elementos")
            return resultado
        except Exception as e:
            print(f"Error en paginación de ciclos: {str(e)}")
            return {
                'ciclos': [],
                'total_registros': 0,
                'total_paginas': 0,
                'pagina_actual': 1
            }
    # ==================== MÉTODOS PRINCIPALES DE COSECHA ====================
    
    @Slot(int, str, int, result=bool)
    def finalizar_ciclo_con_registro_cosecha(self, id_ciclo, datos_cosecha_json, id_usuario):
        """
        Finaliza un ciclo de producción registrando la cosecha.
        
        Args:
            id_ciclo (int): ID del ciclo de producción
            datos_cosecha_json (str): JSON con datos de la cosecha
            id_usuario (int): ID del usuario que registra
            
        Returns:
            bool: True si fue exitoso
        """
        try:
            datos_cosecha = json.loads(datos_cosecha_json)
            
            # Usar el servicio para registrar la cosecha
            resultado = self._lote_servicio.registrar_cosecha(id_ciclo, datos_cosecha, id_usuario)
            
            if resultado.get('exito'):
                # Actualizar todas las listas relevantes
                self.cargar_lotes_cosecha()
                self.cargar_lotes_disponibles_venta()
                self.cargar_ciclos_produccion()
                self.cargar_estadisticas()
                
                # Emitir señal con información del resultado
                self.cosechaRegistradaSignal.emit(resultado)
                
                print(f"Cosecha registrada exitosamente: {resultado.get('mensaje', 'Éxito')}")
                return True
            else:
                print(f"Error al registrar cosecha: {resultado.get('mensaje', 'Error desconocido')}")
                return False
                
        except Exception as e:
            print(f"Error al finalizar ciclo con cosecha: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def registrar_cosecha_directa(self, datos_cosecha_json):
        """
        Registra una cosecha directamente (sin finalizar ciclo automáticamente).
        
        Args:
            datos_cosecha_json (str): JSON con datos completos de la cosecha
            
        Returns:
            bool: True si fue exitoso
        """
        try:
            datos_cosecha = json.loads(datos_cosecha_json)
            
            # Validar que incluya id_ciclo e id_usuario
            if not datos_cosecha.get('id_ciclo') or not datos_cosecha.get('registrado_por'):
                print("Error: Faltan campos obligatorios (id_ciclo, registrado_por)")
                return False
            
            id_ciclo = datos_cosecha.pop('id_ciclo')
            id_usuario = datos_cosecha.pop('registrado_por')
            
            # Registrar cosecha
            resultado = self._lote_servicio.registrar_cosecha(id_ciclo, datos_cosecha, id_usuario)
            
            if resultado.get('exito'):
                self.cargar_lotes_cosecha()
                self.cargar_lotes_disponibles_venta()
                self.cargar_estadisticas()
                
                self.cosechaRegistradaSignal.emit(resultado)
                return True
            else:
                print(f"Error: {resultado.get('mensaje')}")
                return False
                
        except Exception as e:
            print(f"Error al registrar cosecha directa: {str(e)}")
            return False
    
    # ==================== MÉTODOS DE CONSULTA DE LOTES ====================
    
    @Slot(int, result=list)
    def obtener_lotes_por_ciclo(self, id_ciclo):
        """
        Obtiene todos los lotes de cosecha de un ciclo específico.
        
        Args:
            id_ciclo (int): ID del ciclo de producción
            
        Returns:
            list: Lista de lotes del ciclo
        """
        try:
            # Filtrar lotes del ciclo específico
            lotes_ciclo = [lote for lote in self._lotes_cosecha if lote['id_ciclo'] == id_ciclo]
            print(f"Lotes encontrados para ciclo {id_ciclo}: {len(lotes_ciclo)}")
            return lotes_ciclo
        except Exception as e:
            print(f"Error al obtener lotes por ciclo: {str(e)}")
            return []
    
    @Slot(result=list)
    def obtener_lotes_disponibles_venta_lista(self):
        """
        Obtiene lotes disponibles para venta en formato lista.
        
        Returns:
            list: Lista de lotes disponibles para venta
        """
        try:
            self.cargar_lotes_disponibles_venta()
            return self._lotes_disponibles
        except Exception as e:
            print(f"Error al obtener lotes disponibles: {str(e)}")
            return []
    
    @Slot(int, int, result=dict)
    def obtener_lotes_cosecha_paginado(self, pagina, por_pagina):
        """
        Obtiene lotes de cosecha con paginación.
        
        Args:
            pagina (int): Número de página
            por_pagina (int): Registros por página
            
        Returns:
            dict: Resultado paginado con lotes y metadatos
        """
        try:
            resultado = self._lote_servicio.obtener_lotes_paginado(pagina, por_pagina)
            print(f"Página {pagina} cargada: {len(resultado.get('lotes', []))} lotes")
            return resultado
        except Exception as e:
            print(f"Error en paginación de lotes: {str(e)}")
            return {
                'lotes': [],
                'total_registros': 0,
                'total_paginas': 0,
                'pagina_actual': 1
            }
    
    @Slot(str, result=dict)
    def obtener_lotes_con_filtros(self, filtros_json):
        """
        Obtiene lotes aplicando filtros específicos.
        
        Args:
            filtros_json (str): JSON con filtros a aplicar
            
        Returns:
            dict: Resultado con lotes filtrados
        """
        try:
            filtros = json.loads(filtros_json) if filtros_json else {}
            resultado = self._lote_servicio.obtener_lotes_paginado(1, 100, filtros)
            return resultado
        except Exception as e:
            print(f"Error al obtener lotes con filtros: {str(e)}")
            return {'lotes': [], 'total_registros': 0}
    
    # ==================== MÉTODOS DE ANÁLISIS Y ESTADÍSTICAS ====================
    
    @Slot(result=dict)
    def obtener_estadisticas_lotes_cosecha(self):
        """
        Obtiene estadísticas completas de lotes de cosecha.
        
        Returns:
            dict: Estadísticas detalladas
        """
        try:
            estadisticas = self._lote_servicio.obtener_estadisticas_lotes()
            return estadisticas
        except Exception as e:
            print(f"Error al obtener estadísticas de lotes: {str(e)}")
            return {}
    
    @Slot(str, str, result=list)
    def obtener_lotes_por_fechas(self, fecha_desde, fecha_hasta):
        """
        Obtiene lotes en un rango de fechas específico.
        
        Args:
            fecha_desde (str): Fecha inicial (YYYY-MM-DD)
            fecha_hasta (str): Fecha final (YYYY-MM-DD)
            
        Returns:
            list: Lista de lotes en el rango
        """
        try:
            filtros = {
                'fecha_desde': fecha_desde,
                'fecha_hasta': fecha_hasta
            }
            resultado = self._lote_servicio.obtener_lotes_paginado(1, 1000, filtros)
            return resultado.get('lotes', [])
        except Exception as e:
            print(f"Error al obtener lotes por fechas: {str(e)}")
            return []
    
    # ==================== MÉTODOS DE ACTUALIZACIÓN ====================
    
    @Slot(int, str, result=bool)
    def actualizar_lote_cosecha(self, id_lote, datos_actualizacion_json):
        """
        Actualiza un lote de cosecha existente.
        
        Args:
            id_lote (int): ID del lote
            datos_actualizacion_json (str): JSON con datos a actualizar
            
        Returns:
            bool: True si fue exitoso
        """
        try:
            datos_actualizacion = json.loads(datos_actualizacion_json)
            resultado = self._lote_servicio.actualizar_lote(id_lote, datos_actualizacion)
            
            if resultado.get('exito'):
                self.cargar_lotes_cosecha()
                self.cargar_lotes_disponibles_venta()
                print(f"Lote {id_lote} actualizado exitosamente")
                return True
            else:
                print(f"Error al actualizar lote: {resultado.get('mensaje')}")
                return False
                
        except Exception as e:
            print(f"Error al actualizar lote de cosecha: {str(e)}")
            return False
    
    # ==================== MÉTODOS DE UTILIDAD PARA QML ====================
    
    @Slot(result=list)
    def obtener_categorias_calidad_lista(self):
        """
        Obtiene categorías de calidad en formato para ComboBox.
        
        Returns:
            list: Lista con value/text para ComboBox
        """
        categorias_lista = []
        for categoria in self._categorias_calidad:
            categorias_lista.append({
                'value': categoria['id_categoria'],
                'text': categoria['nombre'],
                'descripcion': categoria.get('descripcion', '')
            })
        return categorias_lista
    
    @Slot(int, result=dict)
    def obtener_info_ciclo_para_cosecha(self, id_ciclo):
        """
        Obtiene información del ciclo necesaria para el formulario de cosecha.
        
        Args:
            id_ciclo (int): ID del ciclo
            
        Returns:
            dict: Información del ciclo
        """
        try:
            # Buscar el ciclo en la lista actual
            ciclo_info = next((c for c in self._ciclos_produccion if c['id_ciclo'] == id_ciclo), None)
            
            if ciclo_info:
                return {
                    'id_ciclo': ciclo_info['id_ciclo'],
                    'cultivo_completo': ciclo_info.get('cultivo_completo', ''),
                    'area_sembrada': ciclo_info.get('area_sembrada', 0),
                    'estado': ciclo_info.get('estado', ''),
                    'fecha_siembra': ciclo_info.get('fecha_siembra', ''),
                    'fecha_cosecha_estimada': ciclo_info.get('fecha_cosecha_estimada', ''),
                    'puede_cosechar': ciclo_info.get('estado') in ['En Cosecha', 'En Desarrollo']
                }
            else:
                return {'error': 'Ciclo no encontrado'}
                
        except Exception as e:
            print(f"Error al obtener info del ciclo: {str(e)}")
            return {'error': str(e)}
    
    @Slot(result=list)
    def obtener_unidades_medida_lista(self):
        """
        Obtiene lista de unidades de medida disponibles.
        
        Returns:
            list: Lista de unidades de medida
        """
        return [
            {'value': 'kg', 'text': 'Kilogramos (kg)'},
            {'value': 't', 'text': 'Toneladas (t)'},
            {'value': 'qq', 'text': 'Quintales (qq)'},
            {'value': 'lb', 'text': 'Libras (lb)'},
            {'value': '@', 'text': 'Arrobas (@)'}
        ]
    
    @Slot(int, result=bool)
    def puede_registrar_cosecha(self, id_ciclo):
        """
        Verifica si un ciclo puede registrar cosecha.
        
        Args:
            id_ciclo (int): ID del ciclo
            
        Returns:
            bool: True si puede registrar cosecha
        """
        try:
            info_ciclo = self.obtener_info_ciclo_para_cosecha(id_ciclo)
            return info_ciclo.get('puede_cosechar', False)
        except Exception as e:
            print(f"Error al verificar si puede cosechar: {str(e)}")
            return False
    
    # ==================== MÉTODO ACTUALIZADO PARA REFRESCAR TODO ====================
    
    @Slot()
    def actualizar_todos_los_datos(self):
        """Actualiza todos los datos del modelo, incluyendo cosechas."""
        try:
            # Datos básicos existentes
            self.cargar_tipos_cultivo()
            self.cargar_variedades()
            self.cargar_ciclos_produccion()
            self.cargar_estadisticas()
            
            # Datos de cosechas (NUEVOS)
            self.cargar_lotes_cosecha()
            self.cargar_lotes_disponibles_venta()
            self.cargar_categorias_calidad()
            
            # Datos avanzados existentes
            self.cargar_dashboard_ejecutivo()
            self.cargar_estadisticas_avanzadas()
            self.cargar_alertas_sistema()
            
            print("Todos los datos actualizados exitosamente (incluyendo cosechas)")
            
        except Exception as e:
            print(f"Error actualizando datos: {str(e)}")
    
    # ==================== MÉTODOS DE RENTABILIDAD Y ANÁLISIS AVANZADO ====================

    @Slot(int, str, result=dict)
    def finalizar_ciclo_con_cosecha(self, id_ciclo, datos_cosecha_json):
        """
        Finaliza ciclo registrando cosecha - MÉTODO PRINCIPAL del flujo.
        
        Args:
            id_ciclo (int): ID del ciclo de producción
            datos_cosecha_json (str): JSON con datos de cosecha
            
        Returns:
            dict: Resultado completo de la operación
        """
        try:
            import json
            datos_cosecha = json.loads(datos_cosecha_json)
            
            # Usar el nuevo método principal del servicio de ciclos
            resultado = self.ciclo_servicio.finalizar_ciclo_con_cosecha(id_ciclo, datos_cosecha)
            
            if resultado.get('exito'):
                # Emitir señales de actualización
                self.ciclosChanged.emit()
                self.estadisticasChanged.emit()
                
                # Señal específica para lotes si existe
                if hasattr(self, 'lotesChanged'):
                    self.lotesChanged.emit()
            
            return resultado
            
        except json.JSONDecodeError:
            return {'exito': False, 'mensaje': 'Error en formato JSON de datos de cosecha'}
        except Exception as e:
            return {'exito': False, 'mensaje': f'Error interno: {str(e)}'}

    @Slot(int, result=dict)
    def obtener_rentabilidad_ciclo(self, id_ciclo):
        """
        Obtiene análisis completo de rentabilidad de un ciclo.
        
        Args:
            id_ciclo (int): ID del ciclo
            
        Returns:
            dict: Análisis detallado de rentabilidad
        """
        try:
            # Usar el método de rentabilidad del servicio de ciclos
            return self.ciclo_servicio.obtener_rentabilidad_ciclo(id_ciclo)
            
        except Exception as e:
            return {'error': f'Error obteniendo rentabilidad: {str(e)}'}

    @Slot(result=list)
    def obtener_ranking_rentabilidad(self):
        """
        Obtiene ranking completo de rentabilidad por combinaciones variedad-parcela.
        
        Returns:
            list: Ranking ordenado por ROI
        """
        try:
            analisis_servicio = AnalisisRentabilidadServicio()
            
            return analisis_servicio.obtener_ranking_completo()
            
        except Exception as e:
            logger.error(f"Error obteniendo ranking de rentabilidad: {str(e)}")
            return []

    @Slot(result=dict)
    def obtener_dashboard_rentabilidad(self):
        """
        Dashboard ejecutivo de rentabilidad del sistema.
        
        Returns:
            dict: Dashboard completo con KPIs, análisis y recomendaciones
        """
        try:
            # Usar el dashboard del servicio de gestión
            return self.gestion_servicio.obtener_dashboard_rentabilidad()
            
        except Exception as e:
            logger.error(f"Error obteniendo dashboard de rentabilidad: {str(e)}")
            return {'error': str(e)}

    @Slot(int, int, result=dict)
    def analizar_rentabilidad_variedad_parcela(self, id_variedad, id_parcela):
        """
        Analiza rentabilidad específica de una combinación variedad-parcela.
        
        Args:
            id_variedad (int): ID de la variedad
            id_parcela (int): ID de la parcela
            
        Returns:
            dict: Análisis detallado de la combinación
        """
        try:
            return self.gestion_servicio.analizar_rentabilidad_variedad_parcela(id_variedad, id_parcela)
            
        except Exception as e:
            return {'error': f'Error en análisis: {str(e)}'}

    @Slot(str, result=dict)
    def generar_reporte_rentabilidad(self, filtros_json="{}"):
        """
        Genera reporte ejecutivo de rentabilidad.
        
        Args:
            filtros_json (str): JSON con filtros opcionales
            
        Returns:
            dict: Reporte completo de rentabilidad
        """
        try:
            import json
            filtros = json.loads(filtros_json) if filtros_json != "{}" else None
            
            return self.gestion_servicio.generar_reporte_rentabilidad_detallado(filtros)
            
        except Exception as e:
            return {'error': f'Error generando reporte: {str(e)}'}

    @Slot(int, result=list)
    def obtener_ciclos_similares(self, id_ciclo):
        """
        Obtiene ciclos similares para comparación de rentabilidad.
        
        Args:
            id_ciclo (int): ID del ciclo de referencia
            
        Returns:
            list: Lista de ciclos similares con análisis comparativo
        """
        try:
            resultado = self.ciclo_servicio.comparar_ciclos_similares(id_ciclo)
            
            # Convertir a lista para QML
            if 'error' not in resultado:
                return [
                    *resultado.get('ciclos_exactos', []),
                    *resultado.get('misma_variedad', []),
                    *resultado.get('misma_parcela', [])
                ]
            else:
                return []
                
        except Exception as e:
            logger.error(f"Error obteniendo ciclos similares: {str(e)}")
            return []

    @Slot(result=dict)
    def obtener_metricas_rentabilidad_sistema(self):
        """
        Obtiene métricas generales de rentabilidad del sistema.
        
        Returns:
            dict: KPIs principales de rentabilidad
        """
        try:
            dashboard = self.obtener_dashboard_rentabilidad()
            
            return dashboard.get('kpis_principales', {}) if 'error' not in dashboard else {}
            
        except Exception as e:
            return {'error': str(e)}