// C:/AgroIchilo/components/RegistroMovimientoDialog.qml (CÓDIGO CORREGIDO)

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal 2.15

// Usa el componente base CustomDialog.
CustomDialog { 
    id: registroMovimientoDialog
    title: "Registrar Movimiento (Capital / Gasto General)"
    
    // Asigna el tamaño al dialogRoot interno
    dialogWidth: 500 
    
    // ----------------------------------------------------
    // CONTENIDO DEL FORMULARIO
    // ----------------------------------------------------
    ColumnLayout {
        id: formLayout
        spacing: 15
        width: parent.width - 30
        anchors.centerIn: parent
        
        // Variables temporales para el formulario
        property int selectedCategoriaId: -1
        property bool isGasto: true 
        property var currentModelData: null
        
        // Selector de Tipo de Movimiento
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            
            Text { 
                text: "Tipo de Movimiento:"; 
                font.bold: true; 
                Layout.preferredWidth: 150 
            }
            
            RowLayout {
                spacing: 15
                
                Universal.CheckBox {
                    id: ingresoCheck
                    text: "Ingreso (Capital)"
                    checked: !formLayout.isGasto
                    onCheckedChanged: {
                        if (checked) {
                            formLayout.isGasto = false
                            gastoCheck.checked = false
                        }
                    }
                }
                
                Universal.CheckBox {
                    id: gastoCheck
                    text: "Egreso (Gasto General)"
                    checked: formLayout.isGasto
                    onCheckedChanged: {
                        if (checked) {
                            formLayout.isGasto = true
                            ingresoCheck.checked = false
                            // Actualizar categorías cuando cambie el tipo
                            categoryCombo.currentIndex = -1
                            formLayout.selectedCategoriaId = -1
                        }
                    }
                }
            }
        }
        
        // Selector de Categoría
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            
            Text { 
                text: "Categoría:"; 
                font.bold: true; 
                Layout.preferredWidth: 150 
            }
            
            CustomComboBox { 
                id: categoryCombo
                Layout.fillWidth: true
                comboModel: typeof(finanzasModel) !== 'undefined' && finanzasModel.categorias ? 
                           finanzasModel.categorias : []
                displayProperty: "nombre"
                placeholderText: "Seleccione categoría"
                
                filterFunction: function(item) {
                    return item.tipo === (formLayout.isGasto ? "EGRESO" : "INGRESO")
                }
                
                onModelDataChanged: function(modelData) {
                    formLayout.currentModelData = modelData
                    formLayout.selectedCategoriaId = modelData ? modelData.id_categoria : -1
                }
            }
        }

        // Campos de entrada
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            
            Text { 
                text: "Fecha:"; 
                font.bold: true; 
                Layout.preferredWidth: 150 
            }
            
            Universal.TextField {
                id: fechaInput
                text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                Layout.fillWidth: true
                validator: RegularExpressionValidator {
                    regularExpression: /^\d{4}-\d{2}-\d{2}$/
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            
            Text { 
                text: "Monto:"; 
                font.bold: true; 
                Layout.preferredWidth: 150 
            }
            
            Universal.TextField {
                id: montoInput
                placeholderText: "0.00"
                Layout.fillWidth: true
                validator: DoubleValidator { 
                    bottom: 0.01; 
                    decimals: 2 
                    notation: DoubleValidator.StandardNotation
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            
            Text { 
                text: "Descripción:"; 
                font.bold: true; 
                Layout.preferredWidth: 150 
            }
            
            Universal.TextField {
                id: descripcionInput
                placeholderText: "Ej. Aporte inicial / Pago servicio de internet"
                Layout.fillWidth: true
            }
        }
    }
    
    // ----------------------------------------------------
    // BOTÓN DE GUARDAR
    // ----------------------------------------------------
    footer: RowLayout {
        width: parent.width
        spacing: 10
        padding: 15
        
        Item { Layout.fillWidth: true }
        
        Universal.Button {
            text: "Cancelar"
            Universal.Theme.buttonColor: "#757575"
            Universal.Theme.buttonTextColor: "white"
            onClicked: registroMovimientoDialog.close()
        }
        
        Universal.Button {
            text: "Guardar Movimiento"
            Universal.Theme.buttonColor: "#009688"
            Universal.Theme.buttonTextColor: "white"
            enabled: montoInput.text.length > 0 && 
                     formLayout.selectedCategoriaId !== -1 &&
                     fechaInput.acceptableInput
            onClicked: {
                if (typeof(finanzasModel) !== 'undefined' && 
                    finanzasModel.registrarMovimientoManual) {
                    
                    var success = finanzasModel.registrarMovimientoManual(
                        fechaInput.text,
                        parseFloat(montoInput.text.replace(',', '.')),
                        formLayout.isGasto,
                        formLayout.selectedCategoriaId,
                        descripcionInput.text
                    )
                    
                    if (success) {
                        registroMovimientoDialog.close()
                        montoInput.text = ""
                        descripcionInput.text = ""
                        categoryCombo.currentIndex = -1
                    }
                } else {
                    console.error("Modelo finanzasModel no está disponible")
                }
            }
        }
    }
}