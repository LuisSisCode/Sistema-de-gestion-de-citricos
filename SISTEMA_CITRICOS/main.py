import sys
import os
from PySide6.QtCore import QObject, Slot, QUrl, Property, Signal
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from usuario_roles_model import UsuariosRolesModel
os.environ["QT_LOGGING_RULES"] = "*.debug=false"

class ModuleManager(QObject):
    """Clase para manejar la navegación entre módulos de la aplicación"""
    
    # Señal para notificar cambios en el módulo activo
    moduleChanged = Signal(int)
    
    def __init__(self, engine):
        super().__init__()
        self.engine = engine
        self.root = None
        self._current_module = 0  # Inicialmente en el módulo "Inicio"
        
        # Mapeo de índices de módulos a archivos QML
        self.module_files = {
            0: "inicio.qml",
            1: "usuario_roles.qml", # Esto no va a tener un empleado
            2: "agricultores_parcela.qml",
            3: "cultivos.qml",
            4: "agroquimico.qml",
            5: "ventas_cliente.qml",
            6: "maquinaria.qml",
            7: "reportes.qml",
            8: "configuracion.qml" # Incluyendo esto
        }
    
    def set_root_object(self, root):
        """Establece el objeto raíz de QML y conecta los botones"""
        self.root = root
        self.connect_buttons()
    
    def connect_buttons(self):
        """Conecta los botones del menú con las funciones para cambiar módulos"""
        if not self.root:
            print("Error: No se pudo acceder al objeto raíz QML")
            return
        
        # Verificar si existe el contentContainer (Loader)
        self.content_container = self.root.findChild(QObject, "contentContainer")
        if not self.content_container:
            print("Error: No se pudo encontrar el contentContainer en el QML")
            return
        
        print("Contenedor de contenido encontrado correctamente")
        
        # Conectar los botones
        self.connect_button("btnInicio", 0)
        self.connect_button("btnUsuarios", 1)
        self.connect_button("btnAgricultores", 2)
        self.connect_button("btnCultivos", 3)
        self.connect_button("btnAgroquimicos", 4)
        self.connect_button("btnVentas", 5)
        self.connect_button("btnMaquinaria", 6)
        self.connect_button("btnReportes", 7)
        self.connect_button("btnConfiguracion", 8)
        
        # Cargar el módulo inicial (inicio_content.qml)
        self.change_module(0)
    
    def connect_button(self, button_id, module_index):
        """Conecta un botón específico para cambiar al módulo correspondiente"""
        button = self.root.findChild(QObject, button_id)
        if button:
            #print(f"Botón {button_id} encontrado, conectando para cargar el módulo {module_index}")
            # Conectar la señal clicked del botón a nuestra función para cambiar el módulo
            button.clicked.connect(lambda: self.change_module(module_index))
        else:
            print(f"Error: No se pudo encontrar el botón {button_id}")
    
    @Slot(int)
    def change_module(self, module_index):
        """Cambia al módulo especificado cargando el archivo QML correspondiente"""
        print(f"Cambiando al módulo: {module_index}")
        
        # Actualizar la propiedad activeModule del QML para cambiar el estilo del botón
        self.root.setProperty("activeModule", module_index)
        
        # Obtener el archivo QML correspondiente al módulo
        qml_file = self.module_files.get(module_index)
        if not qml_file:
            print(f"Error: No se encontró un archivo QML para el módulo {module_index}")
            return
        
        # Verificar que el archivo existe
        if not os.path.exists(qml_file):
            print(f"Error: No se encontró el archivo {qml_file}")
            return
        
        # Cargar el archivo QML en el Loader
        if self.content_container:
            self.content_container.setProperty("source", qml_file)
            #print(f"Módulo {qml_file} cargado correctamente")
        else:
            print("Error: No se pudo acceder al contenedor de contenido")
        
        # Actualizar nuestro propio estado
        self._current_module = module_index
        self.moduleChanged.emit(module_index)

def main():
    # Usar variables de entorno para depuración
    os.environ["QT_DEBUG_PLUGINS"] = "1"
    
    # Crear la aplicación
    app = QGuiApplication(sys.argv)
    
    # Crear el motor QML
    engine = QQmlApplicationEngine()
    
    # Crear el gestor de módulos
    module_manager = ModuleManager(engine)

    # Crear y registrar el modelo de usuarios y roles
    usuario_roles_model = UsuariosRolesModel()
    engine.rootContext().setContextProperty("usuariosRolesModel", usuario_roles_model)
    
    
    # Imprimir el directorio de trabajo actual (útil para depuración)
    print(f"Directorio de trabajo actual: {os.getcwd()}")
    
    # Verificar que existe el archivo QML principal
    qml_file_path = "main.qml"
    if not os.path.exists(qml_file_path):
        print(f"Error: No se encontró el archivo QML principal {qml_file_path}")
        sys.exit(-1)
    
    # Cargar el archivo QML principal
    qml_file = QUrl.fromLocalFile(qml_file_path)
    engine.load(qml_file)
    
    # Verificar si la carga fue exitosa
    if not engine.rootObjects():
        print("Error: No se pudo cargar el archivo QML principal.")
        sys.exit(-1)
    
    # Obtener el objeto raíz para poder acceder a los elementos QML
    root_object = engine.rootObjects()[0]
    module_manager.set_root_object(root_object)
    print("Aplicación iniciada correctamente")
    
    # Ejecutar la aplicación
    sys.exit(app.exec())

if __name__ == "__main__":
    main()