import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtWebEngine 1.15

Rectangle {
    id: mapaRoot
    anchors.fill: parent
    color: "red"  // Color llamativo para verificar visibilidad
    
    
    // WebEngineView simplificado
    WebEngineView {
        id: webView
        anchors.fill: parent
        url: "http://localhost:5001/mapa"
        
        onLoadingChanged: function(loadRequest) {
            console.log("🔄 Estado de carga:", loadRequest.status)
            if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                console.log("✅ Mapa cargado correctamente")
            } else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                console.log("❌ Error al cargar mapa:", loadRequest.errorString)
            }
        }
        
        onJavaScriptConsoleMessage: function(level, message, line, sourceId) {
            console.log("[JS] " + message)
        }
    }
    
    Text {
        anchors.centerIn: parent
        text: "Cargando mapa..."
        font.pixelSize: 24
        color: "white"
        visible: webView.loading
    }
    
    Button {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        text: "Debug"
        onClicked: {
            console.log("🛠️ Estado del WebEngineView:")
            console.log("- URL actual:", webView.url)
            console.log("- Cargando:", webView.loading)
            console.log("- Tamaño:", width, "x", height)
        }
    }
    
    Component.onCompleted: {
        console.log("✅ Componente QML cargado correctamente")
        console.log("🗺️ Intentando cargar URL:", webView.url)
    }
}