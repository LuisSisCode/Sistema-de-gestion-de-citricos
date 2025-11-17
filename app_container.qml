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
    
    // En app_container.qml
    // app_container.qml - VERIFICAR que tenga esto
    Loader {
        id: viewLoader
        objectName: "viewLoader"  // ✅ CRÍTICO: debe tener este objectName
        anchors.fill: parent
        source: currentView === "login" ? "login.qml" : "main.qml"
        asynchronous: false  // ✅ Importante para timing
        
        onStatusChanged: {
            if (status === Loader.Ready) {
                console.log("✅ Vista completamente cargada:", source)
            } else if (status === Loader.Loading) {
                console.log("⏳ Cargando vista:", source)
            } else if (status === Loader.Error) {
                console.error("❌ Error cargando vista:", source)
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
