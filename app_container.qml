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
        anchors.fill: parent
        source: currentView === "login" ? "login.qml" : "main.qml"
        
        onLoaded: {
            console.log("✅ Vista cargada:", currentView)
            
            // Si es la vista de login, conectar la señal
            if (currentView === "login" && item) {
                item.loginSuccessful.connect(function() {
                    console.log("🔓 Login exitoso, cambiando a vista principal")
                    appWindow.currentView = "main"
                })
            }
        }
    }
    
    Component.onCompleted: {
        console.log("🚀 Contenedor de aplicación iniciado")
        console.log("📱 Vista inicial:", currentView)
    }
}