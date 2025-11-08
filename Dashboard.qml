// dashboard.qml - Dashboard principal de AgroIchilo
// Compatible con Qt 6 / PySide6 - Sin DropShadow
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components"
import "styles" as Styles

Rectangle {
    id: dashboardRoot
    anchors.fill: parent
    color: "transparent"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth
        
        ColumnLayout {
            width: parent.width
            spacing: Styles.AppTheme.spaceLg
            
            // ============================================
            // TARJETAS DE RESUMEN (KPIs)
            // ============================================
            GridLayout {
                Layout.fillWidth: true
                columns: 4
                rowSpacing: Styles.AppTheme.spaceLg
                columnSpacing: Styles.AppTheme.spaceLg
                
                // Tarjeta: Total Productores
                DataCard {
                    Layout.fillWidth: true
                    title: "Total Productores"
                    value: dashboardModel ? dashboardModel.totalProductores : "0"
                    iconText: "👨‍🌾"
                    iconColor: Styles.AppTheme.colors.primary
                    trend: "up"
                    trendValue: "+5"
                }
                
                // Tarjeta: Total Parcelas
                DataCard {
                    Layout.fillWidth: true
                    title: "Total Parcelas"
                    value: dashboardModel ? dashboardModel.totalParcelas : "0"
                    iconText: "🌳"
                    iconColor: Styles.AppTheme.colors.chartGreen
                    trend: "neutral"
                }
                
                // Tarjeta: Producción Total
                DataCard {
                    Layout.fillWidth: true
                    title: "Producción (kg)"
                    value: dashboardModel ? dashboardModel.produccionTotal : "0"
                    iconText: "📦"
                    iconColor: Styles.AppTheme.colors.chartGreenLight
                    trend: "up"
                    trendValue: "+12%"
                }
                
                // Tarjeta: Ventas Totales
                DataCard {
                    Layout.fillWidth: true
                    title: "Ventas Totales"
                    value: dashboardModel ? ("Bs " + dashboardModel.ventasTotales.toFixed(2)) : "Bs 0.00"
                    iconText: "💰"
                    iconColor: Styles.AppTheme.colors.success
                    trend: "up"
                    trendValue: "+8%"
                }
            }
            
            // ============================================
            // FILA 2: Más métricas
            // ============================================
            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: Styles.AppTheme.spaceLg
                columnSpacing: Styles.AppTheme.spaceLg
                
                DataCard {
                    Layout.fillWidth: true
                    title: "Hectáreas Cultivadas"
                    value: "320"
                    subtitle: "Ha totales"
                    iconText: "🌾"
                    iconColor: Styles.AppTheme.colors.primaryAccent
                }
                
                DataCard {
                    Layout.fillWidth: true
                    title: "Maquinaria Activa"
                    value: "12"
                    subtitle: "Equipos operativos"
                    iconText: "🚜"
                    iconColor: Styles.AppTheme.colors.secondary
                }
                
                DataCard {
                    Layout.fillWidth: true
                    title: "Agroquímicos"
                    value: "24"
                    subtitle: "Productos en stock"
                    iconText: "🧪"
                    iconColor: Styles.AppTheme.colors.chartBlue
                }
            }
            
            // ============================================
            // MENSAJE DE BIENVENIDA
            // ============================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: Styles.AppTheme.colors.bgPaper
                radius: Styles.AppTheme.cardRadius
                border.width: Styles.AppTheme.borderThin
                border.color: Styles.AppTheme.colors.border
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Styles.AppTheme.spaceLg
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "🎉"
                        font.pixelSize: Styles.AppTheme.fontSize4xl
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "¡Bienvenido a AgroIchilo!"
                        font.pixelSize: Styles.AppTheme.fontSize3xl
                        font.weight: Styles.AppTheme.fontWeightBold
                        font.family: Styles.AppTheme.fontFamilyHeading
                        color: Styles.AppTheme.colors.textPrimary
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Sistema de Gestión Agrícola - Cítricos"
                        font.pixelSize: Styles.AppTheme.fontSizeLg
                        color: Styles.AppTheme.colors.textSecondary
                    }
                    
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 400
                        Layout.preferredHeight: 2
                        radius: 1
                        color: Styles.AppTheme.colors.border
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 500
                        text: "Utiliza el menú lateral para navegar entre los diferentes módulos del sistema"
                        font.pixelSize: Styles.AppTheme.fontSizeMd
                        color: Styles.AppTheme.colors.textHint
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
            
            // Espaciado final
            Item { Layout.preferredHeight: Styles.AppTheme.spaceLg }
        }
    }
    
    Component.onCompleted: {
        console.log("✅ Dashboard cargado correctamente")
    }
}
