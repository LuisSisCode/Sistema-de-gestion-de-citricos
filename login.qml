// login.qml - Vista de Login para AgroIchilo
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: loginRoot
    width: 400
    height: 550
    color: "#f5f5f5"
    
    // Señal para notificar login exitoso
    signal loginSuccessful()
    
    ColumnLayout {
        anchors.centerIn: parent
        width: 350
        spacing: 20
        
        // Logo y título
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 100
            height: 100
            radius: 50
            color: "#4CAF50"
            
            Text {
                anchors.centerIn: parent
                text: "AG"
                font.pixelSize: 40
                font.bold: true
                color: "white"
            }
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: loginController.obtenerNombreApp()
            font.pixelSize: 28
            font.bold: true
            color: "#2C3E50"
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: loginController.obtenerNombreEmpresa()
            font.pixelSize: 14
            color: "#7F8C8D"
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: loginController.obtenerVersionApp()
            font.pixelSize: 12
            color: "#95A5A6"
        }
        
        // Espacio
        Item { Layout.preferredHeight: 20 }
        
        // Card de login
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 280
            color: "white"
            radius: 8
            border.color: "#E0E0E0"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 15
                
                // Campo Usuario
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Usuario"
                        font.pixelSize: 14
                        color: "#34495E"
                    }
                    
                    TextField {
                        id: txtUsuario
                        Layout.fillWidth: true
                        placeholderText: "Ingrese su usuario"
                        font.pixelSize: 14
                        
                        background: Rectangle {
                            color: txtUsuario.focus ? "#F0F8FF" : "#F9F9F9"
                            border.color: txtUsuario.focus ? "#4CAF50" : "#D0D0D0"
                            border.width: 1
                            radius: 4
                        }
                        
                        // Enter para pasar al siguiente campo
                        Keys.onReturnPressed: txtPassword.forceActiveFocus()
                    }
                }
                
                // Campo Contraseña
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    Text {
                        text: "Contraseña"
                        font.pixelSize: 14
                        color: "#34495E"
                    }
                    
                    TextField {
                        id: txtPassword
                        Layout.fillWidth: true
                        placeholderText: "Ingrese su contraseña"
                        echoMode: TextInput.Password
                        font.pixelSize: 14
                        
                        background: Rectangle {
                            color: txtPassword.focus ? "#F0F8FF" : "#F9F9F9"
                            border.color: txtPassword.focus ? "#4CAF50" : "#D0D0D0"
                            border.width: 1
                            radius: 4
                        }
                        
                        // Enter para hacer login
                        Keys.onReturnPressed: btnLogin.clicked()
                    }
                }
                
                // Mensaje de error
                Text {
                    id: txtError
                    Layout.fillWidth: true
                    text: loginController.mensajeError
                    color: "#E74C3C"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    visible: text !== ""
                    horizontalAlignment: Text.AlignHCenter
                }
                
                // Botón Login
                Button {
                    id: btnLogin
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    text: loginController.cargando ? "Iniciando sesión..." : "Iniciar Sesión"
                    enabled: !loginController.cargando
                    
                    background: Rectangle {
                        color: btnLogin.enabled ? 
                               (btnLogin.pressed ? "#45A049" : "#4CAF50") : 
                               "#A0A0A0"
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: btnLogin.text
                        font.pixelSize: 15
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        var usuario = txtUsuario.text.trim()
                        var password = txtPassword.text.trim()
                        
                        loginController.intentarLogin(usuario, password)
                    }
                }
            }
        }
        
        // Info adicional
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Sistema de Gestión Agrícola"
            font.pixelSize: 11
            color: "#95A5A6"
        }
    }
    
    // Indicador de carga
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.3
        visible: loginController.cargando
        
        BusyIndicator {
            anchors.centerIn: parent
            running: parent.visible
        }
    }
    
    // Conexiones con el controlador
    Connections {
        target: loginController
        
        function onLoginExitoso(datosUsuario) {
            console.log("✅ Login exitoso en QML")
            loginRoot.loginSuccessful()
        }
        
        function onLoginFallido(mensaje) {
            console.log("❌ Login fallido:", mensaje)
            // El mensaje ya se muestra vía binding con mensajeError
        }
    }
    
    // Focus inicial
    Component.onCompleted: {
        txtUsuario.forceActiveFocus()
    }
}