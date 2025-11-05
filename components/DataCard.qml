// DataCard.qml - Tarjeta de datos para dashboard
// Sprint 1.4 - Sistema de componentes base
// ⚠️ NOTA: Sin DropShadow - compatible con Qt 6 / PySide6

import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../styles" as Styles

Rectangle {
    id: root
    
    // ============================================
    // PROPIEDADES PÚBLICAS
    // ============================================
    property string title: "Título"
    property string value: "0"
    property string subtitle: ""
    property string iconText: "📊"
    property string trend: ""           // "up", "down", "neutral", ""
    property string trendValue: ""      // "+12%", "-5%", etc.
    property color iconColor: Styles.AppTheme.colors.primary
    property color cardColor: Styles.AppTheme.colors.cardBg
    property bool isClickable: false
    property bool isLoading: false
    
    // ============================================
    // SEÑALES
    // ============================================
    signal clicked()
    
    // ============================================
    // DIMENSIONES Y ESTILO
    // ============================================
    width: 280
    height: 140
    radius: Styles.AppTheme.cardRadius
    color: cardColor
    
    border.width: Styles.AppTheme.borderThin
    border.color: Styles.AppTheme.colors.cardBorder
    
    // Efecto hover si es clickeable
    scale: isClickable && mouseArea.containsMouse ? 1.02 : 1.0
    Behavior on scale {
        NumberAnimation { 
            duration: Styles.AppTheme.transitionNormal 
            easing.type: Easing.OutCubic
        }
    }
    
    // ============================================
    // CONTENIDO DE LA TARJETA
    // ============================================
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.AppTheme.cardPadding
        spacing: Styles.AppTheme.spaceMd
        visible: !isLoading
        
        // ============================================
        // HEADER - Icono y título
        // ============================================
        RowLayout {
            Layout.fillWidth: true
            spacing: Styles.AppTheme.spaceSm
            
            // Icono
            Rectangle {
                width: 48
                height: 48
                radius: Styles.AppTheme.radiusMd
                color: Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.1)
                
                Text {
                    anchors.centerIn: parent
                    text: iconText
                    font.pixelSize: Styles.AppTheme.fontSizeXl
                }
            }
            
            // Título y tendencia
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                
                Text {
                    Layout.fillWidth: true
                    text: title
                    font.pixelSize: Styles.AppTheme.fontSizeSm
                    font.weight: Styles.AppTheme.fontWeightMedium
                    font.family: Styles.AppTheme.fontFamily
                    color: Styles.AppTheme.colors.textSecondary
                    elide: Text.ElideRight
                }
                
                // Indicador de tendencia
                RowLayout {
                    visible: trend !== "" && trendValue !== ""
                    spacing: Styles.AppTheme.spaceXxs
                    
                    Text {
                        text: {
                            if (trend === "up") return "↑"
                            if (trend === "down") return "↓"
                            return "→"
                        }
                        font.pixelSize: Styles.AppTheme.fontSizeSm
                        color: {
                            if (trend === "up") return Styles.AppTheme.colors.success
                            if (trend === "down") return Styles.AppTheme.colors.error
                            return Styles.AppTheme.colors.textHint
                        }
                    }
                    
                    Text {
                        text: trendValue
                        font.pixelSize: Styles.AppTheme.fontSizeXs
                        font.weight: Styles.AppTheme.fontWeightMedium
                        color: {
                            if (trend === "up") return Styles.AppTheme.colors.success
                            if (trend === "down") return Styles.AppTheme.colors.error
                            return Styles.AppTheme.colors.textHint
                        }
                    }
                }
            }
        }
        
        // ============================================
        // VALOR PRINCIPAL
        // ============================================
        Text {
            Layout.fillWidth: true
            text: value
            font.pixelSize: Styles.AppTheme.fontSize3xl
            font.weight: Styles.AppTheme.fontWeightBold
            font.family: Styles.AppTheme.fontFamilyHeading
            color: Styles.AppTheme.colors.textPrimary
            elide: Text.ElideRight
            
            // Animación del valor (opcional)
            Behavior on text {
                SequentialAnimation {
                    NumberAnimation {
                        target: root
                        property: "scale"
                        to: 1.05
                        duration: Styles.AppTheme.transitionFast
                    }
                    NumberAnimation {
                        target: root
                        property: "scale"
                        to: 1.0
                        duration: Styles.AppTheme.transitionFast
                    }
                }
            }
        }
        
        // ============================================
        // SUBTÍTULO (opcional)
        // ============================================
        Text {
            visible: subtitle !== ""
            Layout.fillWidth: true
            text: subtitle
            font.pixelSize: Styles.AppTheme.fontSizeXs
            font.family: Styles.AppTheme.fontFamily
            color: Styles.AppTheme.colors.textHint
            elide: Text.ElideRight
        }
        
        // Espaciador
        Item { Layout.fillHeight: true }
    }
    
    // ============================================
    // INDICADOR DE CARGA
    // ============================================
    Rectangle {
        anchors.centerIn: parent
        width: 60
        height: 60
        radius: 30
        color: "transparent"
        visible: isLoading
        
        // Spinner simple
        Rectangle {
            id: spinner
            width: 40
            height: 40
            radius: 20
            anchors.centerIn: parent
            color: "transparent"
            border.width: 3
            border.color: Styles.AppTheme.colors.primary
            
            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: Styles.AppTheme.colors.primary
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
            }
            
            RotationAnimation {
                target: spinner
                from: 0
                to: 360
                duration: 1000
                loops: Animation.Infinite
                running: isLoading
            }
        }
    }
    
    // ============================================
    // ÁREA INTERACTIVA (si es clickeable)
    // ============================================
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: isClickable
        cursorShape: isClickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: isClickable && !isLoading
        
        onClicked: {
            if (isClickable && !isLoading) {
                root.clicked()
            }
        }
    }
    
    // ============================================
    // INDICADOR VISUAL DE CLICKEABLE
    // ============================================
    Rectangle {
        visible: isClickable
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Styles.AppTheme.spaceSm
        width: 24
        height: 24
        radius: 12
        color: Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.1)
        
        Text {
            anchors.centerIn: parent
            text: "→"
            font.pixelSize: Styles.AppTheme.fontSizeSm
            color: iconColor
        }
        
        // Animación de pulso
        SequentialAnimation on scale {
            running: isClickable && mouseArea.containsMouse
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 1.2; duration: 500 }
            NumberAnimation { from: 1.2; to: 1.0; duration: 500 }
        }
    }
}
