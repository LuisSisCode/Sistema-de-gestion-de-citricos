// C:\AgroIchilo\components\CustomComboBox.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal 2.15

// Componente que envuelve el ComboBox estándar
ComboBox {
    id: comboBoxRoot
    width: 200
    height: 40
    
    // Propiedades públicas para pasar datos
    property var model: []
    property string displayProperty: "" // Propiedad del modelo a mostrar (si el modelo es una lista de objetos)
    property string placeholderText: "Seleccione una opción"
    
    // Señal para notificar cambios (ya que el padre FilterHeaderComponent espera la interacción)
    signal modelIndexChanged(int index)

    // Configuración visual básica
    Universal.Theme.buttonColor: Universal.Theme.highlightColor // Color del botón
    
    // Define el modelo y el texto a mostrar
    model: comboBoxRoot.model
    textRole: comboBoxRoot.displayProperty || "modelData" // Usa la propiedad de display

    placeholderText: comboBoxRoot.placeholderText
    
    // Sobreescribe el delegado para manejar el texto o el objeto completo
    delegate: ItemDelegate {
        width: parent.width
        text: comboBoxRoot.displayProperty ? modelData[comboBoxRoot.displayProperty] : modelData
        
        onClicked: {
            // Llama a la señal del componente padre y cierra el popup
            comboBoxRoot.currentIndex = index
            comboBoxRoot.close()
        }
    }
    
    // Conecta el índice interno a la señal pública
    onCurrentIndexChanged: {
        modelIndexChanged(currentIndex)
    }
}