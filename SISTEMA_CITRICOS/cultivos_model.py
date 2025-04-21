from PySide6.QtCore import QObject, Slot, Signal, Property
from bd_cultivos import GestorCultivos
import json

class CultivosModel(QObject):
    tiposCultivoChanged = Signal()
    variedadesChanged = Signal()
    ciclosProduccionChanged = Signal()
    estadisticasChanged = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._gestor = GestorCultivos()
        self._tipos_cultivo = []
        self._variedades = []
        self._ciclos_produccion = []
        self._estadisticas = {}
        
        # Cargar datos iniciales
        self.cargar_tipos_cultivo()
        self.cargar_variedades()
        self.cargar_ciclos_produccion()
        self.cargar_estadisticas()
    
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
    
    @Slot()
    def cargar_tipos_cultivo(self):
        """Carga la lista de tipos de cultivo desde la base de datos"""
        try:
            self._tipos_cultivo = self._gestor.obtener_tipos_cultivo()
            self.tiposCultivoChanged.emit()
        except Exception as e:
            print(f"Error al cargar tipos de cultivo: {str(e)}")
    
    @Slot()
    def cargar_variedades(self):
        """Carga la lista de variedades desde la base de datos"""
        try:
            self._variedades = self._gestor.obtener_variedades_cultivo()
            self.variedadesChanged.emit()
        except Exception as e:
            print(f"Error al cargar variedades: {str(e)}")
    
    @Slot(int)
    def cargar_variedades_por_tipo(self, id_tipo_cultivo):
        """Carga las variedades para un tipo de cultivo específico"""
        try:
            self._variedades = self._gestor.obtener_variedades_cultivo(id_tipo_cultivo)
            self.variedadesChanged.emit()
        except Exception as e:
            print(f"Error al cargar variedades por tipo: {str(e)}")
    
    @Slot()
    def cargar_ciclos_produccion(self):
        """Carga la lista de ciclos de producción desde la base de datos"""
        try:
            self._ciclos_produccion = self._gestor.obtener_ciclos_produccion()
            self.ciclosProduccionChanged.emit()
        except Exception as e:
            print(f"Error al cargar ciclos de producción: {str(e)}")
    
    @Slot(int)
    def cargar_ciclos_por_parcela(self, id_parcela):
        """Carga los ciclos de producción para una parcela específica"""
        try:
            self._ciclos_produccion = self._gestor.obtener_ciclos_produccion(id_parcela=id_parcela)
            self.ciclosProduccionChanged.emit()
        except Exception as e:
            print(f"Error al cargar ciclos por parcela: {str(e)}")
    
    @Slot(str)
    def cargar_ciclos_por_estado(self, estado):
        """Carga los ciclos de producción filtrados por estado"""
        try:
            self._ciclos_produccion = self._gestor.obtener_ciclos_produccion(filtro_estado=estado)
            self.ciclosProduccionChanged.emit()
        except Exception as e:
            print(f"Error al cargar ciclos por estado: {str(e)}")
    
    @Slot()
    def cargar_estadisticas(self):
        """Carga las estadísticas de cultivos desde la base de datos"""
        try:
            self._estadisticas = self._gestor.obtener_estadisticas_cultivos()
            self.estadisticasChanged.emit()
        except Exception as e:
            print(f"Error al cargar estadísticas: {str(e)}")
    
    @Slot(str, result=bool)
    def agregar_tipo_cultivo(self, tipo_data_json):
        """Agrega un nuevo tipo de cultivo a la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            tipo_data = json.loads(tipo_data_json)
            success, _ = self._gestor.agregar_tipo_cultivo(tipo_data)
            if success:
                self.cargar_tipos_cultivo()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al agregar tipo de cultivo: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_tipo_cultivo(self, id_tipo_cultivo, tipo_data_json):
        """Actualiza un tipo de cultivo existente"""
        try:
            # Convertir el string JSON a diccionario
            tipo_data = json.loads(tipo_data_json)
            success = self._gestor.actualizar_tipo_cultivo(id_tipo_cultivo, tipo_data)
            if success:
                self.cargar_tipos_cultivo()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al actualizar tipo de cultivo: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_tipo_cultivo(self, id_tipo_cultivo):
        """Elimina un tipo de cultivo existente"""
        try:
            success = self._gestor.eliminar_tipo_cultivo(id_tipo_cultivo)
            if success:
                self.cargar_tipos_cultivo()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al eliminar tipo de cultivo: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def desactivar_tipo_cultivo(self, id_tipo_cultivo):
        """Desactiva un tipo de cultivo en lugar de eliminarlo físicamente"""
        try:
            success = self._gestor.desactivar_tipo_cultivo(id_tipo_cultivo)
            if success:
                self.cargar_tipos_cultivo()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al desactivar tipo de cultivo: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def agregar_variedad_cultivo(self, variedad_data_json):
        """Agrega una nueva variedad de cultivo a la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            variedad_data = json.loads(variedad_data_json)
            success, _ = self._gestor.agregar_variedad_cultivo(variedad_data)
            if success:
                self.cargar_variedades()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al agregar variedad de cultivo: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_variedad_cultivo(self, id_variedad, variedad_data_json):
        """Actualiza una variedad de cultivo existente"""
        try:
            # Convertir el string JSON a diccionario
            variedad_data = json.loads(variedad_data_json)
            success = self._gestor.actualizar_variedad_cultivo(id_variedad, variedad_data)
            if success:
                self.cargar_variedades()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al actualizar variedad de cultivo: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_variedad_cultivo(self, id_variedad):
        """Elimina una variedad de cultivo existente"""
        try:
            success = self._gestor.eliminar_variedad_cultivo(id_variedad)
            if success:
                self.cargar_variedades()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al eliminar variedad de cultivo: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def desactivar_variedad_cultivo(self, id_variedad):
        """Desactiva una variedad de cultivo en lugar de eliminarla físicamente"""
        try:
            success = self._gestor.desactivar_variedad_cultivo(id_variedad)
            if success:
                self.cargar_variedades()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al desactivar variedad de cultivo: {str(e)}")
            return False
    
    @Slot(str, result=bool)
    def agregar_ciclo_produccion(self, ciclo_data_json):
        """Agrega un nuevo ciclo de producción a la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            ciclo_data = json.loads(ciclo_data_json)
            success, _ = self._gestor.agregar_ciclo_produccion(ciclo_data)
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
            success = self._gestor.actualizar_ciclo_produccion(id_ciclo, ciclo_data)
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
            success = self._gestor.eliminar_ciclo_produccion(id_ciclo)
            if success:
                self.cargar_ciclos_produccion()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al eliminar ciclo de producción: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def desactivar_ciclo_produccion(self, id_ciclo):
        """Desactiva un ciclo de producción en lugar de eliminarlo físicamente"""
        try:
            success = self._gestor.desactivar_ciclo_produccion(id_ciclo)
            if success:
                self.cargar_ciclos_produccion()
                self.cargar_estadisticas()
            return success
        except Exception as e:
            print(f"Error al desactivar ciclo de producción: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def cambiar_estado_ciclo(self, id_ciclo, nuevo_estado):
        """Cambia el estado de un ciclo de producción"""
        try:
            success = self._gestor.cambiar_estado_ciclo(id_ciclo, nuevo_estado)
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