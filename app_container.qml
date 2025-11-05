// app_container.qml - Contenedor que alterna entre login y main
import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: appWindow
    visible: true
    width: 1400
    height: 900
    title: "AgroIchilo - Sistema de Gestión Agrícola"
    
    // Propiedad para controlar qué vista mostrar
    property string currentView: "login"  // "login" o "main"
    
    Loader {
        id: viewLoader
        objectName: "viewLoader"  // ✅ AÑADIDO: objectName para encontrarlo desde Python
        anchors.fill: parent
        source: currentView === "login" ? "login.qml" : "main.qml"
        
        // ✅ MEJORADO: Asíncrono para mejor rendimiento
        asynchronous: false
        
        onLoaded: {
            console.log("✅ Vista cargada:", currentView)
            
            // Si es la vista de login, conectar la señal
            if (currentView === "login" && item) {
                // Conectar señal de login exitoso si existe
                if (item.loginSuccessful !== undefined) {
                    item.loginSuccessful.connect(function() {
                        console.log("🔓 Login exitoso detectado en app_container")
                        // No cambiamos aquí, dejamos que AppManager lo maneje
                    })
                }
            }
            
            // Si es la vista main, notificar que está lista
            if (currentView === "main" && item) {
                console.log("✅ Vista main cargada y lista")
            }
        }
        
        onStatusChanged: {
            if (status === Loader.Error) {
                console.error("❌ Error cargando vista:", source)
            } else if (status === Loader.Loading) {
                console.log("⏳ Cargando vista:", source)
            } else if (status === Loader.Ready) {
                console.log("✅ Vista lista:", source)
            }
        }
    }
    
    // ✅ AÑADIDO: Fondo mientras se carga
    Rectangle {
        anchors.fill: parent
        color: "#ECEFF1"
        visible: viewLoader.status === Loader.Loading
        z: -1
        
        Text {
            anchors.centerIn: parent
            text: "Cargando AgroIchilo..."
            font.pixelSize: 18
            color: "#2C3E50"
        }
    }
    
    Component.onCompleted: {
        console.log("🚀 Contenedor de aplicación iniciado")
        console.log("📱 Vista inicial:", currentView)
    }
    
    // ✅ AÑADIDO: Detectar cambios en currentView
    onCurrentViewChanged: {
        console.log("🔄 Cambio de vista:", currentView)
    }
}
