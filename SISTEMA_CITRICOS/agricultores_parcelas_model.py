from PySide6.QtCore import QObject, Slot, Signal, Property
from bd_agricultores_parcelas import GestorAgricultoresParcelas
import json

class AgricultoresParcelas(QObject):
    agricultoresChanged = Signal()
    parcelasChanged = Signal()
    propietariosChanged = Signal()
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._gestor = GestorAgricultoresParcelas()
        self._agricultores = []
        self._parcelas = []
        self._propietarios = []
        
        # Cargar datos iniciales
        self.cargar_agricultores()
        self.cargar_parcelas()
        self.cargar_propietarios()
    
    @Property(list, notify=agricultoresChanged)
    def agricultores(self):
        return self._agricultores
    
    @Property(list, notify=parcelasChanged)
    def parcelas(self):
        return self._parcelas
    
    @Property(list, notify=propietariosChanged)
    def propietarios(self):
        return self._propietarios
    
    @Slot()
    def cargar_agricultores(self):
        """Carga la lista de agricultores desde la base de datos"""
        try:
            self._agricultores = self._gestor.obtener_agricultores()
            print("Emitiendo señal agricultoresChanged")
            self.agricultoresChanged.emit()
            print("Señal emitida")
        except Exception as e:
            print(f"Error al cargar agricultores: {str(e)}")
    
    @Slot()
    def cargar_parcelas(self):
        """Carga la lista de parcelas desde la base de datos"""
        try:
            self._parcelas = self._gestor.obtener_parcelas()
            self.parcelasChanged.emit()
        except Exception as e:
            print(f"Error al cargar parcelas: {str(e)}")
    
    @Slot()
    def cargar_propietarios(self):
        """Carga la lista de propietarios desde la base de datos"""
        try:
            self._propietarios = self._gestor.obtener_propietarios()
            self.propietariosChanged.emit()
        except Exception as e:
            print(f"Error al cargar propietarios: {str(e)}")
    
    @Slot(str, result=bool)
    def agregar_agricultor(self, agricultor_data_json):
        """Agrega un nuevo agricultor a la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            agricultor_data = json.loads(agricultor_data_json)
            success, _ = self._gestor.agregar_agricultor(agricultor_data)
            if success:
                self.cargar_agricultores()
                # Si es propietario, también actualizamos la lista de propietarios
                if agricultor_data.get('esPropietario', False):
                    self.cargar_propietarios()
            return success
        except Exception as e:
            print(f"Error al agregar agricultor: {str(e)}")
            return False
    
    @Slot(int, str, result=bool)
    def actualizar_agricultor(self, id_agricultor, agricultor_data_json):
        """Actualiza un agricultor existente"""
        try:
            # Convertir el string JSON a diccionario
            agricultor_data = json.loads(agricultor_data_json)
            success = self._gestor.actualizar_agricultor(id_agricultor, agricultor_data)
            if success:
                self.cargar_agricultores()
                # Si se actualizó el estado de propietario, actualizamos la lista de propietarios
                if 'esPropietario' in agricultor_data:
                    self.cargar_propietarios()
            return success
        except Exception as e:
            print(f"Error al actualizar agricultor: {str(e)}")
            return False
    
    @Slot(int, result=bool)
    def eliminar_agricultor(self, id_agricultor):
        """Elimina un agricultor existente"""
        try:
            success = self._gestor.eliminar_agricultor(id_agricultor)
            if success:
                self.cargar_agricultores()
                self.cargar_propietarios()  # Actualizar la lista de propietarios
            return success
        except Exception as e:
            print(f"Error al eliminar agricultor: {str(e)}")
            return False
    
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
    def agregar_parcela(self, parcela_data_json):
        """Agrega una nueva parcela a la base de datos"""
        try:
            # Convertir el string JSON a diccionario
            parcela_data = json.loads(parcela_data_json)
            success, _ = self._gestor.agregar_parcela(parcela_data)
            if success:
                self.cargar_parcelas()
            return success
        except Exception as e:
            print(f"Error al agregar parcela: {str(e)}")
            return False
    
    # Métodos adicionales para filtrado que pueden ser útiles desde QML
    
    @Slot(str, result=list)
    def filtrar_agricultores_por_nombre(self, filtro):
        """Filtra agricultores por nombre o apellido"""
        filtro = filtro.lower()
        return [a for a in self._agricultores if 
                filtro in a['nombre'].lower() or 
                filtro in a['apellido'].lower()]
    
    @Slot(str, result=list)
    def filtrar_parcelas_por_nombre(self, filtro):
        """Filtra parcelas por nombre"""
        filtro = filtro.lower()
        return [p for p in self._parcelas if filtro in p['nombre'].lower()]
    
    @Slot(int, result=list)
    def obtener_parcelas_por_propietario(self, id_propietario):
        """Obtiene las parcelas de un propietario específico"""
        return [p for p in self._parcelas if p['propietarioId'] == id_propietario]
    
    @Slot(int, str, result=bool)
    def actualizar_parcela(self, parcela_id, parcela_data_json):
        """Actualiza una parcela existente"""
        try:
            # Convertir el string JSON a diccionario
            parcela_data = json.loads(parcela_data_json)
            success = self._gestor.actualizar_parcela(parcela_id, parcela_data)
            if success:
                self.cargar_parcelas()
            return success
        except Exception as e:
            print(f"Error al actualizar parcela: {str(e)}")
            return False