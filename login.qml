import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 800
    height: 500
    title: "Sistema de Acceso"
    flags: Qt.FramelessWindowHint
    color: "transparent"

    // Propiedades de diseño
    property color colorFondo: "#f8f9fa"
    property color colorTitulo: "#203436"
    property color colorTexto: "#636e72"
    property color colorBordes: "#dfe6e9"
    property color colorBoton: "#e30909"
    property color colorHover: "#74b9ff"
    property color colorSombra: "#80000000"
    property color colorHeaderBar: "#203436"
    
    // Propiedad para controlar animación de salida
    property bool isClosing: false

    // Permite mover la ventana sin borde
    MouseArea {
        id: dragArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        property point clickPos: "0,0"
        
        onPressed: {
            clickPos = Qt.point(mouse.x, mouse.y)
        }
        
        onPositionChanged: {
            if (pressed) {
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                mainWindow.x += delta.x
                mainWindow.y += delta.y
            }
        }
    }

    Rectangle {
        id: mainRect
        anchors.fill: parent
        radius: 15
        color: colorFondo
        border.color: "#ffffff"
        border.width: 1
        clip: true
        

        // Barra superior con botones de control
        Rectangle {
            id: headerBar
            width: parent.width
            height: 40
            color: colorHeaderBar
            radius: 15
            
            // Solo redondear las esquinas superiores
            Rectangle {
                width: parent.width
                height: parent.height / 2
                color: colorHeaderBar
                anchors.bottom: parent.bottom
            }
            
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 10
                spacing: 10
                
                // Botón minimizar
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: "#FFBD44"
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.opacity = 0.8
                        onExited: parent.opacity = 1
                        onClicked: mainWindow.showMinimized()
                    }
                    
                    Text {
                        visible: false
                        anchors.centerIn: parent
                        text: "_"
                        color: "#000"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
                
                // Botón cerrar
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: "#FF605C"
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.opacity = 0.8
                        onExited: parent.opacity = 1
                        onClicked: Qt.quit()
                    }
                    
                    Text {
                        visible: false
                        anchors.centerIn: parent
                        text: "×"
                        color: "#000"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }
            }
            
            // Título de la aplicación en la barra superior
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                text: "SISTEMA DE ACCESO"
                font.pixelSize: 12
                font.bold: true
                color: "white"
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            anchors.topMargin: 50
            spacing: 20

            // Contenedor Personalizado con Diseño en Dos Columnas
            Rectangle {
                id: contenedor
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 15
                border.color: colorBordes
                border.width: 1
                
                // Efecto de sombra
                Rectangle {
                    z: -1
                    anchors.fill: parent
                    anchors.margins: -3
                    radius: 18
                    color: colorSombra
                    opacity: 0.2
                }

                // Dividimos en dos columnas
                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    // Columna izquierda (imagen decorativa)
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.45
                        color: "#203436"
                        radius: 15
                        
                        // Solo redondear esquinas izquierdas
                        Rectangle {
                            width: parent.width / 2
                            height: parent.height
                            anchors.right: parent.right
                            color: "#203436"
                        }
                        
                        // Imagen de fondo
                        Image {
                            id: loginImage
                            anchors.centerIn: parent
                            width: parent.width * 0.8
                            height: width
                            source: "Image/Image_login/logologinn.png"  // Asegúrate de incluir esta imagen en tu proyecto
                            fillMode: Image.PreserveAspectFit
                            opacity: 0.8
                            
                            // Animación flotante
                            NumberAnimation on y {
                                from: -5
                                to: 5
                                duration: 3000
                                loops: Animation.Infinite
                                easing.type: Easing.InOutQuad
                                running: true
                            }
                            
                            // Animación de entrada
                            NumberAnimation on opacity {
                                from: 0
                                to: 0.8
                                duration: 1000
                                running: true
                            }
                        }
                        
                        // Texto de bienvenida
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 40
                            text: "BIENVENIDO"
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                        }
                        
                        // Texto decorativo
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 20
                            text: "Sistema de gestión segura"
                            font.pixelSize: 14
                            color: "white"
                            opacity: 0.8
                        }
                    }
                    
                    // Columna derecha (formulario)
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            width: parent.width * 0.8
                            spacing: 8
                            
                          
                            // Título de Inicio de Sesión
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Iniciar Sesión"
                                font.pixelSize: 30
                                font.bold: true
                                color: colorTitulo
                            }
                            
                            // Subtítulo
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Introduzca sus credenciales"
                                font.pixelSize: 14
                                color: colorTexto
                                opacity: 0.7
                            }
                            
                            // Espaciador
                            Item { Layout.preferredHeight: 20 }

                            // Campo de Usuario con icono
                            Rectangle {
                                Layout.fillWidth: true
                                height: 50
                                radius: 5
                                border.color: usernameField.activeFocus ? colorBoton : colorBordes
                                border.width: 1
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10
                                    
                                    // Icono de usuario
                                    Image {
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        source: "Image/Image_UI_interfaz/Inconos/circulo-de-usuario.svg"  // Añade este icono
                                        fillMode: Image.PreserveAspectFit
                                        opacity: 0.6
                                    }
                                    
                                    // Campo de texto
                                    TextField {
                                        id: usernameField
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        placeholderText: "Nombre de usuario"
                                        font.pixelSize: 14
                                        selectByMouse: true
                                        background: null  // Eliminamos el fondo predeterminado
                                        
                                        // Animación al enfocar
                                        scale: 1
                                        Behavior on scale { NumberAnimation { duration: 200 } }
                                        onFocusChanged: if (activeFocus) scale = 1.02; else scale = 1
                                    }
                                }
                            }

                            // Campo de Contraseña con icono
                            Rectangle {
                                Layout.fillWidth: true
                                height: 50
                                radius: 5
                                border.color: passwordField.activeFocus ? colorBoton : colorBordes
                                border.width: 1
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10
                                    
                                    // Icono de candado
                                    Image {
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        source: "Image/Image_UI_interfaz/Inconos/cerrar.svg"  // Añade este icono
                                        fillMode: Image.PreserveAspectFit
                                        opacity: 0.6
                                    }
                                    
                                    // Campo de texto
                                    TextField {
                                        id: passwordField
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        placeholderText: "Contraseña"
                                        font.pixelSize: 14
                                        echoMode: TextField.Password
                                        selectByMouse: true
                                        background: null  // Eliminamos el fondo predeterminado
                                        
                                        // Animación al enfocar
                                        scale: 1
                                        Behavior on scale { NumberAnimation { duration: 200 } }
                                        onFocusChanged: if (activeFocus) scale = 1.02; else scale = 1
                                        
                                        // Permitir login con Enter
                                        Keys.onReturnPressed: {
                                            loginButton.clicked()
                                        }
                                    }
                                    
                                    // Botón para mostrar/ocultar contraseña
                                    Image {
                                        id: passwordVisibilityToggle
                                        Layout.preferredWidth: 22
                                        Layout.preferredHeight: 22
                                        source: passwordField.echoMode === TextField.Password 
                                               ? "Image/Image_UI_interfaz/Inconos/ojos-cruzados.svg" 
                                               : "Image/Image_UI_interfaz/Inconos/ojo.svg"  // Añade estos iconos
                                        fillMode: Image.PreserveAspectFit
                                        opacity: 0.6
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                if (passwordField.echoMode === TextField.Password) {
                                                    passwordField.echoMode = TextField.Normal
                                                } else {
                                                    passwordField.echoMode = TextField.Password
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Opción recordar contraseña
                            RowLayout {
                                Layout.fillWidth: true
                                
                                CheckBox {
                                    id: rememberPassword
                                    text: "Recordar credenciales"
                                    font.pixelSize: 12
                                    checked: false
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                // Link para recuperar contraseña
                                Text {
                                    text: "¿Olvidó su contraseña?"
                                    font.pixelSize: 12
                                    color: colorBoton
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            // Aquí colocas la lógica para recuperar contraseña
                                        }
                                    }
                                }
                            }

                            // Botón de Ingreso mejorado
                            Button {
                                id: loginButton
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                text: "INGRESAR"
                                font.pixelSize: 16
                                font.bold: true

                                contentItem: Text {
                                    text: parent.text
                                    font: parent.font
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    radius: 5
                                    color: loginButton.down ? Qt.darker(colorBoton, 1.2) : 
                                          loginButton.hovered ? colorHover : colorBoton
                                    
                                    // Gradiente para dar profundidad
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: loginButton.down ? Qt.darker(colorBoton, 1.3) : Qt.lighter(loginButton.hovered ? colorHover : colorBoton, 1.1) }
                                        GradientStop { position: 1.0; color: loginButton.down ? Qt.darker(colorBoton, 1.5) : loginButton.hovered ? colorHover : colorBoton }
                                    }
                                    
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                }

                                // Animación al hacer clic
                                scale: loginButton.down ? 0.98 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100 } }
                                
                                onClicked: {
                                    loginButton.opacity = 0.7
                                    loginButton.enabled = false
                                    // Llamamos al backend para autenticar
                                    backend.login(usernameField.text, passwordField.text)
                                    // La transición ahora la maneja el backend
                                }
                            }
                            
                            // Indicador de carga
                            BusyIndicator {
                                id: loadingIndicator
                                Layout.alignment: Qt.AlignHCenter
                                running: !loginButton.enabled
                                visible: running
                                Layout.preferredHeight: 32
                                Layout.preferredWidth: 32
                            }
                            
                            // Estado del Sistema
                            Text {
                                id: statusText
                                Layout.fillWidth: true
                                text: backend.status || "El sistema está listo para autenticar"
                                horizontalAlignment: Text.AlignHCenter
                                color: colorTexto
                                font.pixelSize: 12

                                // Animación de entrada del estado
                                opacity: 0
                                Behavior on opacity { NumberAnimation { duration: 300 } }
                                
                                Component.onCompleted: {
                                    opacity = 0.8
                                }
                            }
                            
                            Connections {
                                target: backend
                                
                                function onStatusChanged(newStatus) {
                                    statusText.opacity = 0
                                    statusText.text = newStatus
                                    statusText.opacity = 0.8
                                }
                                
                                function onLoginSuccess(success) {
                                    if (success) {
                                        // Iniciar la animación de cierre
                                        console.log("Login exitoso - preparando transición")
                                        closeAnimation.start()
                                    } else {
                                        // Habilitar el botón nuevamente
                                        loginButton.opacity = 1.0
                                        loginButton.enabled = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Animación para cerrar la ventana con estilo
    PropertyAnimation {
        id: closeAnimation
        target: mainWindow
        property: "opacity"
        from: 1
        to: 0
        duration: 500
        easing.type: Easing.InQuad
        
        onFinished: {
            // La aplicación se cerrará desde el backend
        }
    }
    
    // Animación de entrada al iniciar la aplicación
    Component.onCompleted: {
        mainWindow.opacity = 0
        startupAnimation.start()
    }
    
    PropertyAnimation {
        id: startupAnimation
        target: mainWindow
        property: "opacity"
        from: 0
        to: 1
        duration: 800
        easing.type: Easing.OutQuad
    }
}
