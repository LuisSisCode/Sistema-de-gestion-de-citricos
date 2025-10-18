#!/usr/bin/env python3
"""
TEST NIVEL 3: WebEngine con TU servicio específico
Objetivo: Verificar si WebEngine puede cargar tu aplicación Flask
Requisito: Tu aplicación debe estar ejecutándose
"""

import sys
import os
import urllib.request
import urllib.error
from PySide6.QtCore import QUrl, QTimer
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWebEngineQuick import QtWebEngineQuick

def verificar_tu_servicio():
    """Verifica si tu servicio Flask está ejecutándose"""
    try:
        print("🔍 Verificando tu servicio en http://localhost:5001...")
        
        # Probar endpoint de salud
        with urllib.request.urlopen("http://localhost:5001/api/health", timeout=5) as response:
            if response.status == 200:
                print("✅ API health check: OK")
                return True
            else:
                print(f"⚠️ API health check: HTTP {response.status}")
                return False
                
    except urllib.error.URLError as e:
        print(f"❌ No se puede conectar a tu servicio: {e}")
        print("💡 Asegúrate de que tu aplicación principal esté ejecutándose")
        return False
    except Exception as e:
        print(f"❌ Error verificando servicio: {e}")
        return False

def verificar_endpoint_mapa():
    """Verifica si el endpoint del mapa responde"""
    try:
        print("🗺️ Verificando endpoint del mapa...")
        
        with urllib.request.urlopen("http://localhost:5001/mapa", timeout=5) as response:
            if response.status == 200:
                content = response.read().decode('utf-8')
                if 'Mapa' in content or 'leaflet' in content.lower():
                    print("✅ Endpoint del mapa: OK")
                    return True
                else:
                    print("⚠️ Endpoint responde pero contenido sospechoso")
                    return False
            else:
                print(f"⚠️ Endpoint del mapa: HTTP {response.status}")
                return False
                
    except Exception as e:
        print(f"❌ Error verificando endpoint del mapa: {e}")
        return False

def main():
    print("🧪 TEST NIVEL 3: WebEngine con TU servicio")
    print("=" * 50)
    
    # Verificaciones previas
    print("🔍 VERIFICACIONES PREVIAS:")
    if not verificar_tu_servicio():
        print("\n❌ PRUEBA CANCELADA")
        print("🚀 Inicia tu aplicación principal primero y luego ejecuta este test")
        return False
    
    if not verificar_endpoint_mapa():
        print("\n⚠️ Endpoint del mapa tiene problemas, pero continuamos...")
    
    try:
        print("\n1️⃣ Inicializando QtWebEngine...")
        QtWebEngineQuick.initialize()
        
        print("2️⃣ Creando aplicación...")
        app = QGuiApplication(sys.argv)
        
        print("3️⃣ Configurando WebEngine para tu servicio...")
        os.environ["QTWEBENGINE_DISABLE_SANDBOX"] = "1"
        os.environ["QTWEBENGINE_CHROMIUM_FLAGS"] = "--disable-web-security --allow-running-insecure-content"
        
        print("4️⃣ Creando motor QML...")
        engine = QQmlApplicationEngine()
        
        # QML específico para tu servicio
        qml_content = '''
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtWebEngine 1.15

ApplicationWindow {
    visible: true
    width: 1000
    height: 800
    title: "🧪 Test WebEngine - Tu Servicio Flask"
    
    property bool servicioVerificado: false
    property bool mapaVisible: false
    property string estadoActual: "Verificando..."
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        
        // Header de información
        Rectangle {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 80
            color: "#2E7D32"
            
            Row {
                anchors.centerIn: parent
                spacing: 20
                
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: servicioVerificado ? "#4CAF50" : "#F44336"
                }
                
                Text {
                    text: "🗺️ Probando TU mapa interactivo"
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18
                }
                
                Text {
                    text: estadoActual
                    color: "white"
                    font.pixelSize: 14
                }
            }
        }
        
        // Área de carga
        Rectangle {
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color: "transparent"
            
            Column {
                anchors.centerIn: parent
                spacing: 30
                visible: !mapaVisible
                
                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: true
                    implicitWidth: 100
                    implicitHeight: 100
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "🔄 Cargando tu mapa desde localhost:5001..."
                    font.pixelSize: 20
                    font.bold: true
                    color: "#333"
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Este es el test definitivo.\\nSi funciona aquí, el problema está en tu aplicación principal."
                    font.pixelSize: 14
                    color: "#666"
                    horizontalAlignment: Text.AlignHCenter
                    width: 500
                    wrapMode: Text.WordWrap
                }
                
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 400
                    height: 100
                    color: "#e3f2fd"
                    border.color: "#2196f3"
                    radius: 8
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 10
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "📋 Información del test:"
                            font.bold: true
                            color: "#1976d2"
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "URL: http://localhost:5001/mapa"
                            font.pixelSize: 12
                            color: "#666"
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Timeout: 30 segundos"
                            font.pixelSize: 12
                            color: "#666"
                        }
                    }
                }
            }
            
            // WebEngine View para tu mapa
            WebEngineView {
                id: webView
                anchors.fill: parent
                url: "http://localhost:5001/mapa"
                visible: false
                
                onLoadingChanged: {
                    console.log("📄 Cargando tu servicio - Estado:", loadRequest.status)
                    
                    if (loadRequest.status === WebEngineView.LoadStartedStatus) {
                        estadoActual = "Conectando a tu Flask..."
                        console.log("🔄 Iniciando carga de tu servicio...")
                    }
                    else if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                        mapaVisible = true
                        visible = true
                        estadoActual = "✅ ¡Tu mapa cargado!"
                        console.log("✅ ÉXITO TOTAL: Tu mapa cargado en WebEngine")
                    } 
                    else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                        estadoActual = "❌ Error de carga"
                        console.log("❌ ERROR: Falló la carga de tu servicio -", loadRequest.errorString)
                        errorMessage.visible = true
                    }
                }
                
                onJavaScriptConsoleMessage: {
                    console.log("🌐 JS desde tu mapa:", message)
                }
            }
            
            // Mensaje de error
            Rectangle {
                id: errorMessage
                anchors.centerIn: parent
                width: 600
                height: 300
                color: "#ffebee"
                border.color: "#f44336"
                border.width: 2
                radius: 12
                visible: false
                
                Column {
                    anchors.centerIn: parent
                    spacing: 20
                    width: parent.width - 40
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "❌ No se pudo cargar TU mapa"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#d32f2f"
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "WebEngine no puede cargar tu servicio Flask"
                        font.pixelSize: 16
                        color: "#666"
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 40
                        height: 120
                        color: "#fff3e0"
                        border.color: "#ff9800"
                        radius: 8
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "🔍 Posibles causas:"
                                font.bold: true
                                color: "#e65100"
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "• Tu index.html tiene errores\\n• Problema con las rutas Flask\\n• JavaScript incompatible con WebEngine\\n• Política de seguridad muy restrictiva"
                                font.pixelSize: 12
                                color: "#bf360c"
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width - 20
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                    
                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "🌐 Abrir en navegador normal"
                        onClicked: Qt.openUrlExternally("http://localhost:5001/mapa")
                        
                        background: Rectangle {
                            color: parent.hovered ? "#1976d2" : "#2196f3"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }
    
    // Timer de timeout
    Timer {
        interval: 30000  // 30 segundos
        running: true
        repeat: false
        onTriggered: {
            if (!mapaVisible) {
                console.log("⏰ TIMEOUT: Tu servicio tardó más de 30 segundos")
                estadoActual = "⏰ Timeout"
                errorMessage.visible = true
            }
        }
    }
}
        '''
        
        print("5️⃣ Cargando QML de prueba...")
        engine.loadData(qml_content.encode('utf-8'))
        
        if not engine.rootObjects():
            print("❌ ERROR: No se pudo cargar el QML")
            return False
            
        print("✅ QML cargado correctamente")
        print("\n🎯 RESULTADO ESPERADO:")
        print("- Si ves TU MAPA = WebEngine funciona perfectamente")
        print("- Si ves error = El problema está en tu HTML/JavaScript")
        print("- Si ves timeout = Tu servicio es muy lento para WebEngine")
        print("\nPresiona Ctrl+C para terminar el test")
        
        result = app.exec()
        return result == 0
        
    except Exception as e:
        print(f"❌ ERROR INESPERADO: {e}")
        return False

if __name__ == "__main__":
    success = main()
    print("\n" + "=" * 50)
    if success:
        print("🎉 TEST NIVEL 3: ÉXITO - Tu servicio funciona en WebEngine")
        print("🔍 CONCLUSIÓN: El problema está en tu aplicación principal")
        print("💡 Revisa la configuración específica de tu app")
    else:
        print("💥 TEST NIVEL 3: FALLO - Tu servicio no funciona en WebEngine")
        print("🔧 CONCLUSIÓN: Problema específico con tu HTML/JavaScript")
        print("💡 Posibles soluciones:")
        print("   - Usar MapaSimple.qml (navegador externo)")
        print("   - Simplificar tu index.html")
        print("   - Verificar errores JavaScript")