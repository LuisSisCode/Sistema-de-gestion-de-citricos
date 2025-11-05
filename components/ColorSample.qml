// ColorSample.qml - Componente auxiliar para mostrar colores
import QtQuick 2.15
import QtQuick.Layouts 1.15
import "styles" as Styles

ColumnLayout {
    property color colorValue: "black"
    property string colorName: "Color"
    
    spacing: Styles.AppTheme.spaceXs
    
    Rectangle {
        width: 100
        height: 60
        radius: Styles.AppTheme.radiusMd
        color: colorValue
        border.width: 1
        border.color: Styles.AppTheme.colors.border
    }
    
    Text {
        text: colorName
        font.pixelSize: Styles.AppTheme.fontSizeSm
        font.weight: Styles.AppTheme.fontWeightMedium
        color: Styles.AppTheme.colors.textSecondary
    }
}
