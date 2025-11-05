// login.qml - Versión corregida
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1

Rectangle {
    id: loginRoot
    anchors.fill: parent
    color: "#f5f5f5"
    
    // Settings para guardar credenciales
    Settings {
        id: appSettings
        property string savedUsername: ""
        property string savedPassword: ""
        property bool rememberCredentials: false
        property bool showPassword: false
    }
    
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
            text: "AgroIchilo"
            font.pixelSize: 28
            font.bold: true
            color: "#2C3E50"
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Sistema de Gestión Agrícola"
            font.pixelSize: 14
            color: "#7F8C8D"
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Versión 1.0"
            font.pixelSize: 12
            color: "#95A5A6"
        }
        
        // Espacio
        Item { Layout.preferredHeight: 20 }
        
        // Card de login
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 350
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
                        text: appSettings.savedUsername
                        
                        background: Rectangle {
                            color: txtUsuario.activeFocus ? "#F0F8FF" : "#F9F9F9"
                            border.color: txtUsuario.activeFocus ? "#4CAF50" : "#D0D0D0"
                            border.width: 1
                            radius: 4
                        }
                        
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
                        echoMode: appSettings.showPassword ? TextInput.Normal : TextInput.Password
                        font.pixelSize: 14
                        text: appSettings.rememberCredentials ? appSettings.savedPassword : ""
                        
                        background: Rectangle {
                            color: txtPassword.activeFocus ? "#F0F8FF" : "#F9F9F9"
                            border.color: txtPassword.activeFocus ? "#4CAF50" : "#D0D0D0"
                            border.width: 1
                            radius: 4
                        }
                        
                        // Icono para mostrar/ocultar contraseña
                        Rectangle {
                            anchors {
                                right: parent.right
                                rightMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            width: 30
                            height: 30
                            color: "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: appSettings.showPassword ? "👁️" : "👁️‍🗨️"
                                font.pixelSize: 16
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: appSettings.showPassword = !appSettings.showPassword
                            }
                        }
                        
                        Keys.onReturnPressed: btnLogin.clicked()
                    }
                }
                
                // Opciones adicionales
                RowLayout {
                    Layout.fillWidth: true
                    
                    CheckBox {
                        id: chkRemember
                        text: "Recordar credenciales"
                        checked: appSettings.rememberCredentials
                        onCheckedChanged: appSettings.rememberCredentials = checked
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    CheckBox {
                        id: chkShowPassword
                        text: "Mostrar contraseña"
                        checked: appSettings.showPassword
                        onCheckedChanged: appSettings.showPassword = checked
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
                    enabled: !loginController.cargando && txtUsuario.text.length > 0 && txtPassword.text.length > 0
                    
                    background: Rectangle {
                        color: btnLogin.enabled ? 
                               (btnLogin.down ? "#45A049" : "#4CAF50") : 
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
                        
                        if (appSettings.rememberCredentials) {
                            appSettings.savedUsername = usuario
                            appSettings.savedPassword = password
                        }
                        
                        loginController.intentarLogin(usuario, password)
                    }
                }
            }
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
    
    // Conexiones
    Connections {
        target: loginController
        
        function onLoginExitoso(datosUsuario) {
            console.log("✅ Login exitoso desde login.qml")
            loginRoot.loginSuccessful()
        }
    }
    
    // Focus inicial
    Component.onCompleted: {
        console.log("✅ Login.qml cargado")
        if (appSettings.savedUsername !== "") {
            txtPassword.forceActiveFocus()
        } else {
            txtUsuario.forceActiveFocus()
        }
    }
}
