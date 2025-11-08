// MenuButton.qml - Botón del menú lateral
// Sprint 1.4 - Actualizado con sistema de estilos

import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../styles" as Styles

Rectangle {
    id: root
    
    // Propiedades públicas
    property string buttonText: "Botón"
    property string iconText: "📄"
    property string iconSource: ""  // Nueva propiedad para imágenes
    property bool isActive: false
    
    // Señales
    signal clicked()
    
    // Dimensiones
    width: parent.width
    height: Styles.AppTheme.sidebarItemHeight
    radius: Styles.AppTheme.radiusMd
    
    // Color según estado
    color: {
        if (isActive) return Styles.AppTheme.colors.sidebarItemActive
        if (mouseArea.containsMouse) return Styles.AppTheme.colors.sidebarItemHover
        return "transparent"
    }
    
    // Animación suave del color
    Behavior on color {
        ColorAnimation { 
            duration: Styles.AppTheme.transitionFast 
            easing.type: Styles.AppTheme.easingType
        }
    }
    
    // Borde izquierdo cuando está activo
    Rectangle {
        visible: isActive
        width: 4
        height: parent.height
        radius: 2
        color: Styles.AppTheme.colors.primaryLight
        anchors.left: parent.left
        
        // Animación de entrada
        scale: isActive ? 1.0 : 0.0
        Behavior on scale {
            NumberAnimation { 
                duration: Styles.AppTheme.transitionNormal 
                easing.type: Easing.OutBack
            }
        }
    }
    
    // Contenido del botón
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Styles.AppTheme.spaceMd
        anchors.rightMargin: Styles.AppTheme.spaceMd
        spacing: Styles.AppTheme.spaceSm
        
        // Icono - Ahora soporta tanto texto como imagen
        Item {
            width: Styles.AppTheme.sidebarIconSize
            height: Styles.AppTheme.sidebarIconSize
            
            // Icono de texto (emoji)
            Text {
                id: textIcon
                anchors.centerIn: parent
                text: root.iconText
                font.pixelSize: Styles.AppTheme.sidebarIconSize
                color: root.isActive ? 
                       Styles.AppTheme.colors.white : 
                       Styles.AppTheme.colors.sidebarTextMuted
                visible: root.iconSource === ""  // Mostrar solo si no hay imagen
                
                // Animación del color
                Behavior on color {
                    ColorAnimation { duration: Styles.AppTheme.transitionFast }
                }
            }
            
            // Icono de imagen - Versión simplificada sin ColorOverlay
            Image {
                id: imageIcon
                anchors.centerIn: parent
                source: root.iconSource
                width: Styles.AppTheme.sidebarIconSize +10
                height: Styles.AppTheme.sidebarIconSize +10
                fillMode: Image.PreserveAspectFit
                visible: root.iconSource !== ""  // Mostrar solo si hay imagen
                mipmap: true  // Mejor calidad al escalar
                
                // Control de opacidad en lugar de cambio de color
                opacity: root.isActive ? 1.0 : 0.8
                
                Behavior on opacity {
                    NumberAnimation { duration: Styles.AppTheme.transitionFast }
                }
            }
        }
        
        // Texto
        Text {
            Layout.fillWidth: true
            text: root.buttonText
            font.pixelSize: Styles.AppTheme.fontSizeMd
            font.weight: root.isActive ? 
                        Styles.AppTheme.fontWeightSemiBold : 
                        Styles.AppTheme.fontWeightNormal
            font.family: Styles.AppTheme.fontFamily
            color: root.isActive ? 
                   Styles.AppTheme.colors.white : 
                   Styles.AppTheme.colors.sidebarText
            
            // Animación del color
            Behavior on color {
                ColorAnimation { duration: Styles.AppTheme.transitionFast }
            }
        }
        
        // Indicador de activo (opcional)
        Rectangle {
            visible: root.isActive
            width: 6
            height: 6
            radius: 3
            color: Styles.AppTheme.colors.primaryLight
            
            // Animación de pulso
            SequentialAnimation on opacity {
                running: root.isActive
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.3; duration: 1000 }
                NumberAnimation { from: 0.3; to: 1.0; duration: 1000 }
            }
        }
    }
    
    // Área interactiva
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            root.clicked()
        }
    }
    
    // Efecto de escala al hacer click
    scale: mouseArea.pressed ? 0.98 : 1.0
    Behavior on scale {
        NumberAnimation { 
            duration: Styles.AppTheme.transitionFast 
            easing.type: Easing.OutCubic
        }
    }
}