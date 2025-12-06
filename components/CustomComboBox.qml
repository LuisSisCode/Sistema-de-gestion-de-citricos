// C:\AgroIchilo\components\CustomComboBox.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Componente que envuelve el ComboBox estándar
ComboBox {
    id: comboBoxRoot
    width: 200
    height: 40
    
    // Propiedades públicas para pasar datos
    property var comboModel: []  // CAMBIADO: Nombre diferente para evitar conflicto
    property string displayProperty: "" // Propiedad del modelo a mostrar
    property string placeholderText: "Seleccione una opción"
    property var filterFunction: null  // Función de filtro opcional
    
    // Señal para notificar cambios
    signal modelIndexChanged(int index)
    signal modelDataChanged(var modelData)  // Nueva señal para pasar datos completos
    
    // Modelo interno que puede ser filtrado
    property var internalModel: {
        if (!filterFunction || !comboModel) return comboModel
        var filtered = []
        for (var i = 0; i < comboModel.length; i++) {
            var item = comboModel[i]
            if (filterFunction(item)) {
                filtered.push(item)
            }
        }
        return filtered
    }
    
    // Configuración visual básica
    background: Rectangle {
        color: "#FAFAFA"
        radius: 6
        border.color: "#CCCCCC"
        border.width: 1
    }
    
    contentItem: Text {
        text: comboBoxRoot.currentText
        color: "#333333"
        font.pixelSize: 12
        verticalAlignment: Text.AlignVCenter
        leftPadding: 12
        
        Text {
            text: comboBoxRoot.placeholderText
            color: "#999999"
            font: parent.font
            visible: !parent.text && !comboBoxRoot.popup.visible
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
        }
    }
    
    // Define el modelo
    model: internalModel
    textRole: displayProperty || "modelData"
    
    // Delegado personalizado
    delegate: ItemDelegate {
        width: comboBoxRoot.width
        height: 38
        
        contentItem: Text {
            text: comboBoxRoot.displayProperty && typeof(modelData) === 'object' ? 
                  modelData[comboBoxRoot.displayProperty] : modelData
            color: "#333333"
            font.pixelSize: 12
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
            elide: Text.ElideRight
        }
        
        background: Rectangle {
            color: highlighted ? "#5C6BC0" : "white"
        }
        
        onClicked: {
            comboBoxRoot.currentIndex = index
            comboBoxRoot.modelIndexChanged(index)
            if (typeof(modelData) === 'object') {
                comboBoxRoot.modelDataChanged(modelData)
            }
            comboBoxRoot.popup.close()
        }
    }
    
    // Conecta el índice interno a la señal pública
    onCurrentIndexChanged: {
        modelIndexChanged(currentIndex)
        if (currentIndex >= 0 && currentIndex < internalModel.length) {
            var data = internalModel[currentIndex]
            if (typeof(data) === 'object') {
                modelDataChanged(data)
            }
        }
    }
    
    // Popup personalizado
    popup: Popup {
        y: comboBoxRoot.height
        width: comboBoxRoot.width
        height: Math.min(400, contentItem.implicitHeight)
        padding: 0
        
        background: Rectangle {
            color: "white"
            radius: 6
            border.color: "#E0E0E0"
            border.width: 1
        }
        
        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: comboBoxRoot.popup.visible ? comboBoxRoot.delegateModel : null
            currentIndex: comboBoxRoot.highlightedIndex
            
            ScrollBar.vertical: ScrollBar {
                width: 6
                policy: ScrollBar.AsNeeded
            }
        }
    }
}