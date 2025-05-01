import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: root
    width: 300
    height: 380
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    property date selectedDate: new Date()
    signal dateSelected(date date)
    
    background: Rectangle {
        color: "white"
        radius: 8
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5
        
        // Header con navegación
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "#4CAF50"
            radius: 4
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                
                Button {
                    text: "<<"
                    onClicked: {
                        currentYear--;
                        updateCalendar();
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                    }
                }
                
                Button {
                    text: "<"
                    onClicked: {
                        currentMonth--;
                        if (currentMonth < 0) {
                            currentMonth = 11;
                            currentYear--;
                        }
                        updateCalendar();
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                    }
                }
                
                Text {
                    id: monthYearText
                    Layout.fillWidth: true
                    text: monthNames[currentMonth] + " " + currentYear
                    color: "white"
                    font.bold: true
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Button {
                    text: ">"
                    onClicked: {
                        currentMonth++;
                        if (currentMonth > 11) {
                            currentMonth = 0;
                            currentYear++;
                        }
                        updateCalendar();
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                    }
                }
                
                Button {
                    text: ">>"
                    onClicked: {
                        currentYear++;
                        updateCalendar();
                    }
                    background: Rectangle {
                        color: "transparent"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                    }
                }
            }
        }
        
        // Días de la semana
        Grid {
            Layout.fillWidth: true
            columns: 7
            spacing: 2
            
            Repeater {
                model: ["L", "M", "X", "J", "V", "S", "D"]
                delegate: Rectangle {
                    width: (root.width - 20) / 7
                    height: 25
                    color: "#E8F5E9"
                    
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.bold: true
                        font.pixelSize: 11
                    }
                }
            }
        }
        
        // Días del mes
        Grid {
            id: daysGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            spacing: 2
            
            Repeater {
                id: daysRepeater
                model: 42
                
                delegate: Rectangle {
                    width: (root.width - 20) / 7
                    height: 36
                    color: {
                        if (dayNumber <= 0) 
                            return "#F5F5F5";
                        if (dayNumber === selectedDate.getDate() && 
                            currentMonth === selectedDate.getMonth() && 
                            currentYear === selectedDate.getFullYear())
                            return "#4CAF50";
                        return "white";
                    }
                    border.color: "#E0E0E0"
                    
                    property int dayNumber: 0
                    
                    Text {
                        anchors.centerIn: parent
                        text: parent.dayNumber > 0 ? parent.dayNumber : ""
                        font.pixelSize: 12
                        color: {
                            if (parent.dayNumber <= 0) 
                                return "#BDBDBD";
                            if (parent.dayNumber === selectedDate.getDate() && 
                                currentMonth === selectedDate.getMonth() && 
                                currentYear === selectedDate.getFullYear())
                                return "white";
                            return "black";
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (dayNumber > 0) {
                                selectedDate = new Date(currentYear, currentMonth, dayNumber);
                                updateCalendar();
                            }
                        }
                    }
                }
            }
        }
        
        // Botones de acción
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Button {
                text: "Cancelar"
                Layout.fillWidth: true
                onClicked: root.close()
            }
            
            Button {
                text: "Seleccionar"
                Layout.fillWidth: true
                highlighted: true
                background: Rectangle {
                    color: "#4CAF50"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    dateSelected(selectedDate);
                    root.close();
                }
            }
        }
    }
    
    // Variables para el calendario
    property int currentMonth: selectedDate.getMonth()
    property int currentYear: selectedDate.getFullYear()
    property var monthNames: ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                            "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    // Inicializar calendario cuando se abre
    Component.onCompleted: {
        updateCalendar()
    }
    
    onVisibleChanged: {
        if (visible) {
            updateCalendar()
        }
    }
    
    // Actualizar la visualización del calendario
    function updateCalendar() {
        var firstDay = new Date(currentYear, currentMonth, 1).getDay();
        if (firstDay === 0) firstDay = 7; // Ajustar domingo como último día
        firstDay--; // Ajustar para que lunes sea 0
        
        var daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
        
        // Actualizar texto del mes y año
        monthYearText.text = monthNames[currentMonth] + " " + currentYear;
        
        // Actualizar días en el grid
        for (var i = 0; i < 42; i++) {
            var dayItem = daysRepeater.itemAt(i);
            if (i < firstDay || i >= firstDay + daysInMonth) {
                dayItem.dayNumber = 0;
            } else {
                dayItem.dayNumber = i - firstDay + 1;
            }
        }
    }
}