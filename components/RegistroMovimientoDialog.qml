// C:/AgroIchilo/components/RegistroMovimientoDialog.qml (CÓDIGO CORREGIDO)

import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15

// Usa el componente base CustomDialog.
CustomDialog { 
    id: registroMovimientoDialog
    title: "Registrar Movimiento (Capital / Gasto General)"
    
    // Asigna el tamaño al dialogRoot interno
    dialogWidth: 500 
    
    // ----------------------------------------------------
    // 1. CONTENIDO DEL FORMULARIO (Se convierte en el contentItem del Dialog)
    // ----------------------------------------------------
    ColumnLayout {
        id: formLayout // Nuevo ID para referenciar variables
        spacing: 15
        width: parent.width
        
        // Variables temporales para el formulario
        property int selectedCategoriaId: -1
        property bool isGasto: true 
        
        // Selector de Tipo de Movimiento
        RowLayout {
            Text { text: "Tipo de Movimiento:"; font.bold: true; Layout.preferredWidth: 150 }
            Universal.CheckBox {
                text: "Ingreso (Capital)"
                checked: !formLayout.isGasto
                onCheckedChanged: formLayout.isGasto = !checked
            }
            Universal.CheckBox {
                text: "Egreso (Gasto General)"
                checked: formLayout.isGasto
                onCheckedChanged: formLayout.isGasto = checked
            }
        }
        
        // Selector de Categoría
        RowLayout {
            Text { text: "Categoría:"; font.bold: true; Layout.preferredWidth: 150 }
            CustomComboBox { 
                id: categoryCombo
                Layout.fillWidth: true
                model: finanzasModel.categorias 
                displayProperty: "nombre"
                filterFunction: function(item) {
                    return item.tipo === (formLayout.isGasto ? "EGRESO" : "INGRESO")
                }
                onModelIndexChanged: {
                    formLayout.selectedCategoriaId = categoryCombo.currentModelData ? categoryCombo.currentModelData.id_categoria : -1
                }
            }
        }

        // Campos de entrada
        RowLayout {
            Text { text: "Fecha:"; font.bold: true; Layout.preferredWidth: 150 }
            Universal.TextField {
                id: fechaInput
                text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                Layout.fillWidth: true
            }
        }
        
        RowLayout {
            Text { text: "Monto (" + finanzasRoot.monedaSeleccionada + "):"; font.bold: true; Layout.preferredWidth: 150 } 
            Universal.TextField {
                id: montoInput
                placeholderText: "0.00"
                validator: DoubleValidator { bottom: 0.01; decimals: 2 } 
                Layout.fillWidth: true
            }
        }
        
        RowLayout {
            Text { text: "Descripción:"; font.bold: true; Layout.preferredWidth: 150 }
            Universal.TextField {
                id: descripcionInput
                placeholderText: "Ej. Aporte inicial / Pago servicio de internet"
                Layout.fillWidth: true
            }
        }
    }
    
    // ----------------------------------------------------
    // 2. BOTÓN DE GUARDAR (Se convierte en el footer del Dialog)
    // ----------------------------------------------------
    footer: Universal.Button {
        text: "Guardar Movimiento"
        Universal.Theme.buttonColor: "#009688"
        Universal.Theme.buttonTextColor: "white"
        enabled: montoInput.text.length > 0 && formLayout.selectedCategoriaId !== -1
        onClicked: {
            if (finanzasModel.registrarMovimientoManual(
                fechaInput.text,
                parseFloat(montoInput.text),
                formLayout.isGasto,
                formLayout.selectedCategoriaId,
                descripcionInput.text
            )) {
                registroMovimientoDialog.close()
                montoInput.text = ""
                descripcionInput.text = ""
            }
        }
    }
}