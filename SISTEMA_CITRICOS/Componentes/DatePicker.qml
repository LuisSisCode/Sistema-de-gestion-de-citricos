import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: root
    width: 320
    height: 400
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    property date selectedDate: new Date()
    property date minDate: new Date(2000, 0, 1)
    property date maxDate: new Date(2100, 11, 31)
    signal dateSelected(date selectedDate)
    
    background: Rectangle {
        color: "#FFFFFF"
        radius: 8
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "#4CAF50"
            
            RowLayout {
                anchors.fill: parent
                spacing: 10
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                
                Label {
                    text: calendar.visibleMonth === calendar.month && calendar.visibleYear === calendar.year 
                          ? Qt.formatDate(calendar.selectedDate, "MMMM yyyy")
                          : Qt.formatDate(new Date(calendar.visibleYear, calendar.visibleMonth, 1), "MMMM yyyy")
                    color: "white"
                    font.bold: true
                    font.pixelSize: 16
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "<"
                    onClicked: {
                        var newDate = new Date(calendar.visibleYear, calendar.visibleMonth - 1, 1);
                        calendar.year = newDate.getFullYear();
                        calendar.month = newDate.getMonth();
                    }
                    flat: true
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                    }
                }
                
                Button {
                    text: ">"
                    onClicked: {
                        var newDate = new Date(calendar.visibleYear, calendar.visibleMonth + 1, 1);
                        calendar.year = newDate.getFullYear();
                        calendar.month = newDate.getMonth();
                    }
                    flat: true
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                    }
                }
            }
        }
        
        // Calendario
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 1
            
            DayOfWeekRow {
                locale: calendar.locale
                Layout.fillWidth: true
                delegate: Label {
                    text: model.shortName
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    font.pixelSize: 10
                }
            }
            
            MonthGrid {
                id: calendar
                Layout.fillWidth: true
                Layout.fillHeight: true
                month: selectedDate.getMonth()
                year: selectedDate.getFullYear()
                locale: Qt.locale()
                
                property date selectedDate: root.selectedDate
                property int visibleMonth: month
                property int visibleYear: year
                
                delegate: Rectangle {
                    width: calendar.cellWidth
                    height: calendar.cellHeight
                    color: model.day === calendar.selectedDate.getDate() && 
                           model.month === calendar.selectedDate.getMonth() && 
                           model.year === calendar.selectedDate.getFullYear() ? "#4CAF50" : 
                           model.month === calendar.month ? "#FAFAFA" : "#EEEEEE"
                    
                    Label {
                        text: model.day
                        anchors.centerIn: parent
                        color: model.day === calendar.selectedDate.getDate() && 
                               model.month === calendar.selectedDate.getMonth() && 
                               model.year === calendar.selectedDate.getFullYear() ? "white" : 
                               model.month !== calendar.month ? "#BDBDBD" : 
                               model.weekNumber % 7 === 0 ? "#E53935" : "#212121"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (model.month === calendar.month) {
                                calendar.selectedDate = new Date(model.year, model.month, model.day);
                                root.selectedDate = calendar.selectedDate;
                            } else {
                                calendar.month = model.month;
                                calendar.year = model.year;
                                calendar.selectedDate = new Date(model.year, model.month, model.day);
                                root.selectedDate = calendar.selectedDate;
                            }
                        }
                    }
                }
            }
        }
        
        // Botones de acción
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 10
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
                onClicked: {
                    root.selectedDate = calendar.selectedDate;
                    root.dateSelected(calendar.selectedDate);
                    root.close();
                }
            }
        }
    }
}