// C:/AgroIchilo/components/CustomDialog.qml

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal 2.15

// Componente base que encapsula el Dialog de Qt
Dialog {
    id: dialogRoot

    // Propiedad pública para definir el ancho del diálogo desde el componente que lo usa
    property int dialogWidth: 400 
    
    // Configuración estándar
    width: dialogRoot.dialogWidth
    height: implicitHeight // La altura se ajusta al contenido automáticamente
    modal: true
    focus: true
    
    // Estilo del fondo del diálogo
    background: Rectangle {
        color: "#FFFFFF" // Fondo blanco
        radius: 8
        border.color: Universal.Theme.dividerColor
        border.width: 1
        
        // Sombra suave (Opcional)
        // elevation: 2 // Si usas Material Design o un módulo de efectos.
    }
    
    // ----------------------------------------------------
    // CABECERA (Header)
    // ----------------------------------------------------
    header: Rectangle {
        width: parent.width
        height: 50
        // Usa el color principal del tema para la barra de título
        color: Universal.Theme.highlightColor 
        
        RowLayout {
            anchors.fill: parent
            spacing: 10
            
            Text {
                text: dialogRoot.title // Usa la propiedad 'title' del Dialog
                font.pixelSize: 18
                font.bold: true
                color: "white"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                leftPadding: 15
            }

            // Botón de Cerrar (X)
            Universal.Button {
                text: "X"
                Universal.Theme.buttonColor: "transparent"
                Universal.Theme.buttonTextColor: "white"
                onClicked: dialogRoot.close() // Cierra el diálogo
                Layout.rightMargin: 10
            }
        }
    }
    
    // ----------------------------------------------------
    // CONTENIDO Y PIE DE PÁGINA
    // ----------------------------------------------------
    
    // Importante: Al usar el 'Dialog' de QtQuick Controls, el componente que lo
    // instancia (RegistroMovimientoDialog.qml) debe proporcionar su
    // contenido (contentItem) y pie de página (footer) como propiedades
    // o como hijos directos del Dialog.
    
    // Ajustar el padding entre el header/footer y el contenido
    padding: 0
    contentItem: Item { width: parent.width; height: implicitHeight; padding: 15 } // Espacio para el contenido
    
    // El 'footer' se deja como propiedad para ser definido por el componente hijo
}