// login.qml - Versión mejorada con autocompletado automático
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
        property bool autoLogin: false
    }
    
    // Señal para notificar login exitoso
    signal loginSuccessful()
    
    // Propiedad para manejar autocompletado automático
    property bool autoLoginAttempted: false
    
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
            Layout.preferredHeight: 380
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
                        
                        // Auto-seleccionar texto al enfocar
                        onActiveFocusChanged: {
                            if (activeFocus && text.length > 0) {
                                selectAll()
                            }
                        }
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
                        
                        Keys.onReturnPressed: {
                            if (!loginController.cargando) {
                                btnLogin.clicked()
                            }
                        }
                        
                        // Auto-seleccionar texto al enfocar
                        onActiveFocusChanged: {
                            if (activeFocus && text.length > 0) {
                                selectAll()
                            }
                        }
                    }
                }
                
                // Opciones adicionales
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CheckBox {
                            id: chkRemember
                            text: "Recordar credenciales"
                            checked: appSettings.rememberCredentials
                            onCheckedChanged: {
                                appSettings.rememberCredentials = checked
                                // Si se desactiva recordar, también desactivar auto-login
                                if (!checked) {
                                    chkAutoLogin.checked = false
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        CheckBox {
                            id: chkShowPassword
                            text: "Mostrar contraseña"
                            checked: appSettings.showPassword
                            onCheckedChanged: appSettings.showPassword = checked
                        }
                    }
                    
                    CheckBox {
                        id: chkAutoLogin
                        text: "Iniciar sesión automáticamente"
                        checked: appSettings.autoLogin
                        enabled: chkRemember.checked
                        onCheckedChanged: {
                            if (chkRemember.checked) {
                                appSettings.autoLogin = checked
                            } else {
                                checked = false
                                appSettings.autoLogin = false
                            }
                        }
                    }
                }
                
                // Mensaje de estado (información sobre credenciales guardadas)
                Text {
                    id: txtStatus
                    Layout.fillWidth: true
                    text: {
                        if (appSettings.autoLogin && !autoLoginAttempted) {
                            return "Iniciando sesión automáticamente..."
                        } else if (appSettings.rememberCredentials && appSettings.savedUsername !== "") {
                            return "✓ Credenciales guardadas para: " + appSettings.savedUsername
                        }
                        return ""
                    }
                    color: appSettings.autoLogin ? "#4CAF50" : "#7F8C8D"
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    visible: text !== ""
                    horizontalAlignment: Text.AlignHCenter
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
                    text: {
                        if (loginController.cargando) {
                            return "Iniciando sesión..."
                        } else if (appSettings.autoLogin && !autoLoginAttempted) {
                            return "Inicio automático..."
                        } else {
                            return "Iniciar Sesión"
                        }
                    }
                    enabled: !loginController.cargando && 
                             !(appSettings.autoLogin && !autoLoginAttempted) &&
                             txtUsuario.text.length > 0 && 
                             txtPassword.text.length > 0
                    
                    background: Rectangle {
                        color: {
                            if (!btnLogin.enabled) {
                                return "#A0A0A0"
                            } else if (appSettings.autoLogin && !autoLoginAttempted) {
                                return "#FF9800"
                            } else {
                                return btnLogin.down ? "#45A049" : "#4CAF50"
                            }
                        }
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
                        realizarLogin()
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
        visible: loginController.cargando || (appSettings.autoLogin && !autoLoginAttempted)
        
        BusyIndicator {
            anchors.centerIn: parent
            running: parent.visible
        }
        
        Text {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.verticalCenter
                topMargin: 60
            }
            text: appSettings.autoLogin ? "Iniciando sesión automáticamente..." : "Iniciando sesión..."
            color: "white"
            font.pixelSize: 14
        }
    }
    
    // Función para realizar login
    function realizarLogin() {
        var usuario = txtUsuario.text.trim()
        var password = txtPassword.text.trim()
        
        // Guardar credenciales según las opciones seleccionadas
        if (chkRemember.checked) {
            appSettings.savedUsername = usuario
            appSettings.savedPassword = password
        } else {
            // Si no se marca recordar, limpiar solo la contraseña
            appSettings.savedUsername = usuario
            appSettings.savedPassword = ""
            appSettings.autoLogin = false
        }
        
        loginController.intentarLogin(usuario, password)
        autoLoginAttempted = true
    }
    
    // Función para limpiar credenciales guardadas
    function limpiarCredenciales() {
        appSettings.savedUsername = ""
        appSettings.savedPassword = ""
        appSettings.rememberCredentials = false
        appSettings.autoLogin = false
        
        txtUsuario.text = ""
        txtPassword.text = ""
        chkRemember.checked = false
        chkAutoLogin.checked = false
        
        txtUsuario.forceActiveFocus()
    }
    
    // Función para intentar login automático
    function intentarAutoLogin() {
        if (appSettings.autoLogin && 
            appSettings.savedUsername !== "" && 
            appSettings.savedPassword !== "" &&
            !autoLoginAttempted) {
            
            console.log("🔐 Intentando inicio de sesión automático...")
            txtUsuario.text = appSettings.savedUsername
            txtPassword.text = appSettings.savedPassword
            
            // Pequeño delay para mostrar la interfaz antes del auto-login
            autoLoginTimer.start()
        }
    }
    
    // Timer para auto-login (da tiempo a que la UI se muestre)
    Timer {
        id: autoLoginTimer
        interval: 500
        onTriggered: {
            if (appSettings.autoLogin && !autoLoginAttempted) {
                realizarLogin()
            }
        }
    }
    
    // Conexiones
    Connections {
        target: loginController
        
        function onLoginExitoso(datosUsuario) {
            console.log("✅ Login exitoso desde login.qml")
            autoLoginAttempted = false // Reset para próxima vez
            loginRoot.loginSuccessful()
        }
        
        function onLoginFallido(mensaje) {
            autoLoginAttempted = false // Permitir reintento
        }
    }
    
    // Focus inicial y auto-login
    Component.onCompleted: {
        console.log("✅ Login.qml cargado")
        console.log("📝 Credenciales guardadas:", {
            usuario: appSettings.savedUsername,
            recordar: appSettings.rememberCredentials,
            autoLogin: appSettings.autoLogin
        })
        
        // Configurar campos con credenciales guardadas
        if (appSettings.savedUsername !== "") {
            txtUsuario.text = appSettings.savedUsername
            if (appSettings.rememberCredentials && appSettings.savedPassword !== "") {
                txtPassword.text = appSettings.savedPassword
            }
        }
        
        // Establecer focus
        if (appSettings.savedUsername === "") {
            txtUsuario.forceActiveFocus()
        } else if (appSettings.savedPassword === "" || !appSettings.rememberCredentials) {
            txtPassword.forceActiveFocus()
        }
        
        // Intentar auto-login después de un breve delay
        if (appSettings.autoLogin && 
            appSettings.savedUsername !== "" && 
            appSettings.savedPassword !== "") {
            intentarAutoLogin()
        }
    }
}