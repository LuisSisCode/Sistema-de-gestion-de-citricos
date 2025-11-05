// CustomButton.qml - Botón personalizado reutilizable
// Sprint 1.4 - Sistema de componentes base

import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../styles" as Styles

Rectangle {
    id: root
    
    // ============================================
    // PROPIEDADES PÚBLICAS
    // ============================================
    property string text: "Button"
    property string iconText: ""
    property string variant: "primary"  // primary, secondary, outline, ghost, danger
    property string size: "md"          // sm, md, lg
    property bool isEnabled: true
    property bool isLoading: false
    property bool fullWidth: false
    
    // ============================================
    // SEÑALES
    // ============================================
    signal clicked()
    
    // ============================================
    // PROPIEDADES PRIVADAS
    // ============================================
    property color backgroundColor: getBackgroundColor()
    property color textColor: getTextColor()
    property color borderColor: getBorderColor()
    property int buttonHeight: getButtonHeight()
    property int horizontalPadding: getHorizontalPadding()
    
    // ============================================
    // DIMENSIONES
    // ============================================
    width: fullWidth ? parent.width : (contentRow.width + horizontalPadding * 2)
    height: buttonHeight
    radius: Styles.AppTheme.radiusMd
    
    // Color de fondo
    color: {
        if (!isEnabled) return Styles.AppTheme.colors.buttonDisabledBg
        if (mouseArea.pressed) return Qt.darker(backgroundColor, 1.1)
        if (mouseArea.containsMouse) return Qt.darker(backgroundColor, 1.05)
        return backgroundColor
    }
    
    // Borde
    border.width: (variant === "outline" || variant === "ghost") ? 
                  Styles.AppTheme.borderThin : 0
    border.color: borderColor
    
    // Opacidad cuando está deshabilitado
    opacity: isEnabled ? 1.0 : 0.5
    
    // Animaciones
    Behavior on color {
        ColorAnimation { 
            duration: Styles.AppTheme.transitionFast 
            easing.type: Styles.AppTheme.easingType
        }
    }
    
    Behavior on scale {
        NumberAnimation { 
            duration: Styles.AppTheme.transitionFast 
            easing.type: Easing.OutCubic
        }
    }
    
    // ============================================
    // CONTENIDO DEL BOTÓN
    // ============================================
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Styles.AppTheme.buttonIconSpacing
        visible: !isLoading
        
        // Icono (si existe)
        Text {
            visible: iconText !== ""
            text: iconText
            font.pixelSize: Styles.AppTheme.buttonIconSize
            color: textColor
            
            Behavior on color {
                ColorAnimation { duration: Styles.AppTheme.transitionFast }
            }
        }
        
        // Texto
        Text {
            text: root.text
            font.pixelSize: getFontSize()
            font.weight: Styles.AppTheme.fontWeightMedium
            font.family: Styles.AppTheme.fontFamily
            color: textColor
            
            Behavior on color {
                ColorAnimation { duration: Styles.AppTheme.transitionFast }
            }
        }
    }
    
    // ============================================
    // INDICADOR DE CARGA
    // ============================================
    Rectangle {
        id: loadingIndicator
        anchors.centerIn: parent
        width: 20
        height: 20
        radius: 10
        color: "transparent"
        visible: isLoading
        
        Rectangle {
            width: 4
            height: 4
            radius: 2
            color: textColor
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            
            SequentialAnimation on opacity {
                running: isLoading
                loops: Animation.Infinite
                NumberAnimation { from: 1; to: 0.3; duration: 500 }
                NumberAnimation { from: 0.3; to: 1; duration: 500 }
            }
        }
    }
    
    // ============================================
    // ÁREA INTERACTIVA
    // ============================================
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: isEnabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
        enabled: isEnabled && !isLoading
        
        onClicked: {
            if (isEnabled && !isLoading) {
                root.clicked()
            }
        }
    }
    
    // Efecto de escala al hacer click
    scale: mouseArea.pressed ? 0.97 : 1.0
    
    // ============================================
    // FUNCIONES AUXILIARES
    // ============================================
    
    function getBackgroundColor() {
        switch(variant) {
            case "primary":
                return Styles.AppTheme.colors.primary
            case "secondary":
                return Styles.AppTheme.colors.secondary
            case "danger":
                return Styles.AppTheme.colors.error
            case "outline":
            case "ghost":
                return "transparent"
            default:
                return Styles.AppTheme.colors.primary
        }
    }
    
    function getTextColor() {
        switch(variant) {
            case "primary":
            case "secondary":
            case "danger":
                return Styles.AppTheme.colors.white
            case "outline":
                return Styles.AppTheme.colors.primary
            case "ghost":
                return Styles.AppTheme.colors.textPrimary
            default:
                return Styles.AppTheme.colors.white
        }
    }
    
    function getBorderColor() {
        switch(variant) {
            case "outline":
                return Styles.AppTheme.colors.primary
            case "ghost":
                return Styles.AppTheme.colors.border
            default:
                return "transparent"
        }
    }
    
    function getButtonHeight() {
        switch(size) {
            case "sm": return Styles.AppTheme.buttonHeightSm
            case "md": return Styles.AppTheme.buttonHeightMd
            case "lg": return Styles.AppTheme.buttonHeightLg
            default: return Styles.AppTheme.buttonHeightMd
        }
    }
    
    function getHorizontalPadding() {
        switch(size) {
            case "sm": return Styles.AppTheme.buttonPaddingHorizontalSm
            case "md": return Styles.AppTheme.buttonPaddingHorizontalMd
            case "lg": return Styles.AppTheme.buttonPaddingHorizontalLg
            default: return Styles.AppTheme.buttonPaddingHorizontalMd
        }
    }
    
    function getFontSize() {
        switch(size) {
            case "sm": return Styles.AppTheme.fontSizeSm
            case "md": return Styles.AppTheme.fontSizeMd
            case "lg": return Styles.AppTheme.fontSizeLg
            default: return Styles.AppTheme.fontSizeMd
        }
    }
}
