# backend/models/auto_model.py
"""
Generador automático de modelos Qt desde repositorios
Permite crear modelos QML sin código repetitivo
"""

from PySide6.QtCore import QObject, Slot, Signal, Property
from typing import Any, List, Dict
import json


class AutoModel(QObject):
    """
    Modelo Qt base automático que se conecta con un repositorio
    y expone métodos para QML
    """
    
    # Señal genérica para cambios en los datos
    datosChanged = Signal()
    errorOcurrido = Signal(str)  # Emite mensajes de error
    
    def __init__(self, repositorio, parent=None):
        """
        Inicializa un modelo automático
        
        Args:
            repositorio: Instancia de AutoRepositorio o cualquier repositorio
            parent: Parent Qt opcional
        """
        super().__init__(parent)
        self._repositorio = repositorio
        self._datos = []
        self._cargando = False
        
        # Cargar datos iniciales
        self.cargar_datos()
        
        print(f"✅ AutoModel creado para: {repositorio.nombre_tabla}")
    
    # ============================================
    # PROPERTIES PARA QML
    # ============================================
    
    @Property(list, notify=datosChanged)
    def datos(self):
        """Property que expone los datos a QML"""
        return self._datos
    
    cargandoChanged = Signal()
    
    @Property(bool, notify=cargandoChanged)
    def cargando(self):
        """Indica si se están cargando datos"""
        return self._cargando
    
    @cargando.setter
    def cargando(self, value):
        if self._cargando != value:
            self._cargando = value
            self.cargandoChanged.emit()
    
    # ============================================
    # MÉTODOS CRUD PARA QML
    # ============================================
    
    @Slot()
    def cargar_datos(self):
        """Carga todos los datos desde el repositorio"""
        try:
            self.cargando = True
            self._datos = self._repositorio.obtener_todos()
            self.datosChanged.emit()
            print(f"✅ Datos cargados: {len(self._datos)} registros")
        except Exception as e:
            error_msg = f"Error al cargar datos: {str(e)}"
            print(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
        finally:
            self.cargando = False
    
    @Slot(int, result=str)
    def obtener_por_id(self, id_registro: int) -> str:
        """
        Obtiene un registro por su ID
        
        Args:
            id_registro: ID del registro
            
        Returns:
            str: JSON con los datos del registro
        """
        try:
            registro = self._repositorio.obtener_por_id(id_registro)
            return json.dumps(registro)
        except Exception as e:
            error_msg = f"Error al obtener registro: {str(e)}"
            print(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return json.dumps({})
    
    @Slot(str, result=bool)
    def crear(self, datos_json: str) -> bool:
        """
        Crea un nuevo registro
        
        Args:
            datos_json: JSON string con los datos
            
        Returns:
            bool: True si se creó exitosamente
        """
        try:
            self.cargando = True
            datos = json.loads(datos_json)
            exito, id_creado = self._repositorio.crear(datos)
            
            if exito:
                self.cargar_datos()  # Recargar datos
                print(f"✅ Registro creado con ID: {id_creado}")
                return True
            else:
                self.errorOcurrido.emit("No se pudo crear el registro")
                return False
                
        except Exception as e:
            error_msg = f"Error al crear: {str(e)}"
            print(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
        finally:
            self.cargando = False
    
    @Slot(int, str, result=bool)
    def actualizar(self, id_registro: int, datos_json: str) -> bool:
        """
        Actualiza un registro existente
        
        Args:
            id_registro: ID del registro
            datos_json: JSON string con los datos a actualizar
            
        Returns:
            bool: True si se actualizó exitosamente
        """
        try:
            self.cargando = True
            datos = json.loads(datos_json)
            exito = self._repositorio.actualizar(id_registro, datos)
            
            if exito:
                self.cargar_datos()  # Recargar datos
                print(f"✅ Registro {id_registro} actualizado")
                return True
            else:
                self.errorOcurrido.emit("No se pudo actualizar el registro")
                return False
                
        except Exception as e:
            error_msg = f"Error al actualizar: {str(e)}"
            print(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
        finally:
            self.cargando = False
    
    @Slot(int, result=bool)
    def eliminar(self, id_registro: int) -> bool:
        """
        Elimina un registro
        
        Args:
            id_registro: ID del registro
            
        Returns:
            bool: True si se eliminó exitosamente
        """
        try:
            self.cargando = True
            exito = self._repositorio.eliminar(id_registro)
            
            if exito:
                self.cargar_datos()  # Recargar datos
                print(f"✅ Registro {id_registro} eliminado")
                return True
            else:
                self.errorOcurrido.emit("No se pudo eliminar el registro")
                return False
                
        except Exception as e:
            error_msg = f"Error al eliminar: {str(e)}"
            print(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
        finally:
            self.cargando = False
    
    @Slot(int, result=bool)
    def desactivar(self, id_registro: int) -> bool:
        """
        Desactiva un registro (soft delete)
        
        Args:
            id_registro: ID del registro
            
        Returns:
            bool: True si se desactivó exitosamente
        """
        try:
            self.cargando = True
            exito = self._repositorio.desactivar(id_registro)
            
            if exito:
                self.cargar_datos()  # Recargar datos
                print(f"✅ Registro {id_registro} desactivado")
                return True
            else:
                self.errorOcurrido.emit("No se pudo desactivar el registro")
                return False
                
        except Exception as e:
            error_msg = f"Error al desactivar: {str(e)}"
            print(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return False
        finally:
            self.cargando = False
    
    @Slot(str, str, result=str)
    def buscar(self, campo: str, valor: str) -> str:
        """
        Busca registros por un campo específico
        
        Args:
            campo: Nombre del campo
            valor: Valor a buscar
            
        Returns:
            str: JSON con los registros encontrados
        """
        try:
            resultados = self._repositorio.buscar(campo, valor)
            return json.dumps(resultados)
        except Exception as e:
            error_msg = f"Error en búsqueda: {str(e)}"
            print(f"❌ {error_msg}")
            self.errorOcurrido.emit(error_msg)
            return json.dumps([])
    
    @Slot(result=int)
    def contar(self) -> int:
        """
        Cuenta el total de registros
        
        Returns:
            int: Total de registros
        """
        return len(self._datos)
    
    @Slot()
    def refrescar(self):
        """Alias para cargar_datos()"""
        self.cargar_datos()
