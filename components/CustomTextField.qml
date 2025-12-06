// CustomTextField.qml - Input de texto personalizado
// Sprint 1.4 - Sistema de componentes base

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../styles" as Styles

Rectangle {
    id: root
    
    // ============================================
    // PROPIEDADES PÚBLICAS
    // ============================================
    property string placeholderText: "Ingrese texto..."
    property string label: ""
    property string helperText: ""
    property string errorText: ""
    property string successText: ""
    property string iconText: ""
    property string size: "md"           // sm, md, lg
    property bool isPassword: false
    property bool isDisabled: false
    property bool isReadOnly: false
    property bool hasError: false
    property bool hasSuccess: false
    property bool isRequired: false
    property int maxLength: 200
    
    // Alias para acceder al texto del input
    property alias text: textInput.text
    property alias textInput: textInput
    
    // ============================================
    // SEÑALES
    // ============================================
    signal enterPressed()
    signal inputFocusChanged(bool hasFocus)  // CAMBIADO: De focusChanged a inputFocusChanged
    signal textChangedSignal(string text)    // CAMBIADO: Nombre único para evitar conflicto
    
    // ============================================
    // PROPIEDADES PRIVADAS
    // ============================================
    property color borderColor: getBorderColor()
    property int inputHeight: getInputHeight()
    
    // ============================================
    // DIMENSIONES
    // ============================================
    width: parent.width
    height: {
        var totalHeight = inputHeight
        if (label !== "") totalHeight += 25
        if (helperText !== "" || errorText !== "" || successText !== "") totalHeight += 20
        return totalHeight
    }
    color: "transparent"
    
    // ============================================
    // CONTENIDO DEL COMPONENTE
    // ============================================
    ColumnLayout {
        anchors.fill: parent
        spacing: Styles.AppTheme.spaceXs
        
        // ============================================
        // LABEL
        // ============================================
        Text {
            visible: label !== ""
            text: label + (isRequired ? " *" : "")
            font.pixelSize: Styles.AppTheme.fontSizeSm
            font.weight: Styles.AppTheme.fontWeightMedium
            font.family: Styles.AppTheme.fontFamily
            color: Styles.AppTheme.colors.textPrimary
            
            Text {
                visible: isRequired
                anchors.left: parent.right
                anchors.leftMargin: 2
                text: ""
                font.pixelSize: Styles.AppTheme.fontSizeSm
                color: Styles.AppTheme.colors.error
            }
        }
        
        // ============================================
        // INPUT CONTAINER
        // ============================================
        Rectangle {
            id: inputContainer
            Layout.fillWidth: true
            Layout.preferredHeight: inputHeight
            radius: Styles.AppTheme.radiusMd
            color: isDisabled ? 
                   Styles.AppTheme.colors.inputDisabled : 
                   Styles.AppTheme.colors.inputBg
            
            border.width: Styles.AppTheme.borderThin
            border.color: borderColor
            
            // Animación del borde
            Behavior on border.color {
                ColorAnimation { 
                    duration: Styles.AppTheme.transitionFast 
                }
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Styles.AppTheme.inputPaddingHorizontal
                anchors.rightMargin: Styles.AppTheme.inputPaddingHorizontal
                spacing: Styles.AppTheme.spaceSm
                
                // Icono izquierdo (si existe)
                Text {
                    visible: iconText !== ""
                    text: iconText
                    font.pixelSize: Styles.AppTheme.inputIconSize
                    color: textInput.activeFocus ? 
                           Styles.AppTheme.colors.primary : 
                           Styles.AppTheme.colors.textHint
                    
                    Behavior on color {
                        ColorAnimation { duration: Styles.AppTheme.transitionFast }
                    }
                }
                
                // Campo de texto
                TextInput {
                    id: textInput
                    Layout.fillWidth: true
                    
                    font.pixelSize: getFontSize()
                    font.family: Styles.AppTheme.fontFamily
                    color: Styles.AppTheme.colors.textPrimary
                    
                    enabled: !isDisabled
                    readOnly: isReadOnly
                    echoMode: isPassword ? TextInput.Password : TextInput.Normal
                    maximumLength: maxLength
                    
                    selectByMouse: true
                    selectionColor: Styles.AppTheme.colors.primary
                    selectedTextColor: Styles.AppTheme.colors.white
                    
                    verticalAlignment: TextInput.AlignVCenter
                    
                    // Placeholder
                    Text {
                        anchors.fill: parent
                        text: placeholderText
                        font: textInput.font
                        color: Styles.AppTheme.colors.textHint
                        visible: !textInput.text && !textInput.activeFocus
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onTextChanged: {
                        root.textChangedSignal(text)  // CAMBIADO: Usar señal renombrada
                    }
                    
                    onAccepted: {
                        root.enterPressed()
                    }
                    
                    onActiveFocusChanged: {
                        root.inputFocusChanged(activeFocus)  // CAMBIADO: Usar señal renombrada
                    }
                    
                    Keys.onReturnPressed: {
                        root.enterPressed()
                    }
                }
                
                // Botón mostrar/ocultar contraseña
                Rectangle {
                    visible: isPassword
                    width: 24
                    height: 24
                    radius: 12
                    color: passwordMouseArea.containsMouse ? 
                           Styles.AppTheme.colors.gray100 : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: textInput.echoMode === TextInput.Password ? "👁️" : "👁️‍🗨️"
                        font.pixelSize: Styles.AppTheme.fontSizeMd
                    }
                    
                    MouseArea {
                        id: passwordMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            if (textInput.echoMode === TextInput.Password) {
                                textInput.echoMode = TextInput.Normal
                            } else {
                                textInput.echoMode = TextInput.Password
                            }
                        }
                    }
                }
                
                // Icono de estado (error/success)
                Text {
                    visible: hasError || hasSuccess
                    text: hasError ? "❌" : "✅"
                    font.pixelSize: Styles.AppTheme.inputIconSize
                }
            }
        }
        
        // ============================================
        // HELPER TEXT / ERROR / SUCCESS
        // ============================================
        Text {
            visible: helperText !== "" || errorText !== "" || successText !== ""
            text: {
                if (hasError && errorText !== "") return errorText
                if (hasSuccess && successText !== "") return successText
                return helperText
            }
            font.pixelSize: Styles.AppTheme.fontSizeXs
            font.family: Styles.AppTheme.fontFamily
            color: {
                if (hasError) return Styles.AppTheme.colors.error
                if (hasSuccess) return Styles.AppTheme.colors.success
                return Styles.AppTheme.colors.textSecondary
            }
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            
            Behavior on color {
                ColorAnimation { duration: Styles.AppTheme.transitionFast }
            }
        }
    }
    
    // ============================================
    // FUNCIONES AUXILIARES
    // ============================================
    
    function getBorderColor() {
        if (hasError) return Styles.AppTheme.colors.borderError
        if (hasSuccess) return Styles.AppTheme.colors.borderSuccess
        if (textInput.activeFocus) return Styles.AppTheme.colors.borderFocus
        return Styles.AppTheme.colors.inputBorder
    }
    
    function getInputHeight() {
        switch(size) {
            case "sm": return Styles.AppTheme.inputHeightSm
            case "md": return Styles.AppTheme.inputHeightMd
            case "lg": return Styles.AppTheme.inputHeightLg
            default: return Styles.AppTheme.inputHeightMd
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
    
    // Funciones públicas
    function clear() {
        textInput.text = ""
    }
    
    function focusInput() {  // CAMBIADO: De focus a focusInput
        textInput.forceActiveFocus()
    }
    
    function selectAll() {
        textInput.selectAll()
    }
}