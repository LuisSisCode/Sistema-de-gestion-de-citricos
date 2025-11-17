import QtQuick 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: productoresRoot
    anchors.fill: parent
    color: "#F8F9FA"
    
    property int tabActiva: 0
    property var tabsInfo: [
        {"text": "Agricultores", "icon": "recursos/image/icons/agricultores.png", "color": "#2E7D32"},
        {"text": "Parcelas", "icon": "recursos/image/icons/parcela.png", "color": "#F57C00"},
        {"text": "Mapa", "icon": "recursos/image/icons/mapa.png", "color": "#0288D1"}
    ]
    
    // Propiedades para datos dinámicos
    property var agricultoresData: [
        {
            "id": 1, "nombre": "Juan", "apellido": "Pérez", "identificacion": "12345678",
            "telefono": "+591-123456", "correo": "juan@email.com", "estado": "Activo"
        },
        {
            "id": 2, "nombre": "María", "apellido": "García", "identificacion": "87654321",
            "telefono": "+591-234567", "correo": "maria@email.com", "estado": "Activo"
        }
    ]
    
    property var parcelasData: [
        {
            "id": 1, "nombre": "Parcela A", "propietario": "Juan Pérez", "ubicacion": "Santa Cruz",
            "area": "5.5", "porcentajeUso": 75, "estado": "Activo"
        },
        {
            "id": 2, "nombre": "Parcela B", "propietario": "María García", "ubicacion": "La Paz",
            "area": "3.2", "porcentajeUso": 90, "estado": "Activo"
        }
    ]
    
    // Propiedades para filtros
    property var estadosAgricultores: ["Todos", "Activo", "Inactivo"]
    property var estadosParcelas: ["Todos", "Activo", "Inactivo"]
    
    // Propiedades para paginación
    property int paginaAgricultores: 1
    property int totalPaginasAgricultores: 3
    property int paginaParcelas: 1
    property int totalPaginasParcelas: 2

    // Título
    Rectangle {
        id: titleBar
        width: parent.width
        height: 80
        color: "transparent"

        Text {
            text: "GESTIÓN DE PROPIETARIOS Y TERRENO"
            font.pixelSize: 28
            font.bold: true
            color: "#2E7D32"
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Barra de pestañas - TabBarComponent
    Item {
        id: modernTabBar
        width: parent.width - 40
        height: 90
        anchors.top: titleBar.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        
        TabBarComponent {
            id: tabBar
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            tabsData: productoresRoot.tabsInfo
            tabActiva: productoresRoot.tabActiva
            
            onTabChanged: function(index) {
                productoresRoot.tabActiva = index
                paginaAgricultores = 1
                paginaParcelas = 1
            }
        }
    }

    // Área de contenido principal
    Item {
        id: contentArea
        width: parent.width - 40
        height: parent.height - modernTabBar.y - modernTabBar.height - 20
        anchors.top: modernTabBar.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        
        // ==================== TAB 1: AGRICULTORES ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 0
            opacity: tabActiva === 0 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                
                // Barra de herramientas con FilterHeaderComponent
                FilterHeaderComponent {
                    id: filterHeaderAgricultores
                    Layout.fillWidth: true
                    height: 60
                    buttonText: "Nuevo Agricultor"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#2E7D32"
                    searchPlaceholder: "Buscar agricultor..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: estadosAgricultores
                    filterPlaceholder: "Estado..."
                    filterWidth: 150
                    showFilter: true
                    
                    onButtonClicked: {
                        console.log("Nuevo agricultor")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar agricultor:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por estado:", estadosAgricultores[index])
                    }
                }
                
                // Tabla de Agricultores
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: agricultoresData
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.14; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.14; height: parent.height; text: "Apellido"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.14; height: parent.height; text: "Identificación"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Teléfono"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.18; height: parent.height; text: "Correo"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.16; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#F0F4FF"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                Text { width: parent.width * 0.14; height: parent.height; text: modelData.nombre; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.14; height: parent.height; text: modelData.apellido; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.14; height: parent.height; text: modelData.identificacion; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.12; height: parent.height; text: modelData.telefono; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.18; height: parent.height; text: modelData.correo; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 70
                                        height: 24
                                        radius: 12
                                        anchors.centerIn: parent
                                        color: modelData.estado === "Activo" ? "#E8F5E8" : "#FFF3CD"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.estado
                                            font.pixelSize: 11
                                            color: modelData.estado === "Activo" ? "#2E7D32" : "#B8860B"
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.16
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: console.log("Editar", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: console.log("Eliminar", modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador Agricultores - CENTRADO
                Item {
                    Layout.fillWidth: true
                    height: 50
                    
                    Paginator {
                        id: paginadorAgricultores
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaAgricultores
                        totalPages: totalPaginasAgricultores
                        
                        onPageChanged: {
                            paginaAgricultores = newPage
                        }
                    }
                }
            }
        }
        
        // ==================== TAB 2: PARCELAS ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 1
            opacity: tabActiva === 1 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 15
                
                // Barra de herramientas con FilterHeaderComponent
                FilterHeaderComponent {
                    id: filterHeaderParcelas
                    Layout.fillWidth: true
                    height: 60
                    buttonText: "Nueva Parcela"
                    buttonIcon: "recursos/image/icons/agregar.svg"
                    buttonColor: "#F57C00"
                    searchPlaceholder: "Buscar parcela..."
                    searchIcon: "recursos/image/icons/lupa.png"
                    filterOptions: estadosParcelas
                    filterPlaceholder: "Estado..."
                    filterWidth: 150
                    showFilter: true
                    
                    onButtonClicked: {
                        console.log("Nueva parcela")
                    }
                    
                    onSearchTextChanged: function(text) {
                        console.log("Buscar parcela:", text)
                    }
                    
                    onFilterChanged: function(index) {
                        console.log("Filtrar por estado:", estadosParcelas[index])
                    }
                }
                
                // Tabla de Parcelas
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#E0E0E0"
                    border.width: 1
                    
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        model: parcelasData
                        headerPositioning: ListView.OverlayHeader
                        
                        header: Rectangle {
                            width: parent.width
                            height: 45
                            color: "#F8F9FA"
                            radius: 8
                            z: 2
                            
                            Row {
                                anchors.fill: parent
                                Text { width: parent.width * 0.13; height: parent.height; text: "Nombre"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.16; height: parent.height; text: "Propietario"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.14; height: parent.height; text: "Ubicación"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.11; height: parent.height; text: "Área (ha)"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.1; height: parent.height; text: "% Uso"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.12; height: parent.height; text: "Estado"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; leftPadding: 10; color: "#424242" }
                                Text { width: parent.width * 0.24; height: parent.height; text: "Acciones"; font.bold: true; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter; color: "#424242" }
                            }
                        }
                        
                        delegate: Rectangle {
                            width: parent.width
                            height: 50
                            color: index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#FFF3E0"
                                onExited: parent.color = index % 2 === 0 ? "#FFFFFF" : "#FAFAFA"
                            }
                            
                            Row {
                                anchors.fill: parent
                                spacing: 0
                                
                                Text { width: parent.width * 0.13; height: parent.height; text: modelData.nombre; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.16; height: parent.height; text: modelData.propietario; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.14; height: parent.height; text: modelData.ubicacion; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.11; height: parent.height; text: modelData.area; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                Text { width: parent.width * 0.1; height: parent.height; text: modelData.porcentajeUso + "%"; verticalAlignment: Text.AlignVCenter; leftPadding: 10; elide: Text.ElideRight; font.pixelSize: 12 }
                                
                                Rectangle {
                                    width: parent.width * 0.12
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Rectangle {
                                        width: 70
                                        height: 24
                                        radius: 12
                                        anchors.centerIn: parent
                                        color: modelData.estado === "Activo" ? "#E8F5E8" : "#FFF3CD"
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.estado
                                            font.pixelSize: 11
                                            color: modelData.estado === "Activo" ? "#2E7D32" : "#B8860B"
                                        }
                                    }
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.24
                                    height: parent.height
                                    color: "transparent"
                                    
                                    Row {
                                        spacing: 5
                                        anchors.centerIn: parent
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#E3F2FD" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/editar.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Editar"
                                            onClicked: console.log("Editar", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#FFEBEE" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/basura.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Eliminar"
                                            onClicked: console.log("Eliminar", modelData.id)
                                        }
                                        
                                        Button {
                                            width: 32; height: 32
                                            background: Rectangle {
                                                color: parent.hovered ? "#F3E5F5" : "transparent"
                                                radius: 4
                                            }
                                            contentItem: Image {
                                                source: "recursos/image/icons/ojo.svg"
                                                width: 16
                                                height: 16
                                                anchors.centerIn: parent
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ToolTip.visible: hovered
                                            ToolTip.text: "Ver detalles"
                                            onClicked: console.log("Ver detalles", modelData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Paginador Parcelas - CENTRADO
                Item {
                    Layout.fillWidth: true
                    height: 50
                    
                    Paginator {
                        id: paginadorParcelas
                        width: Math.min(parent.width * 0.6, 400)
                        height: 40
                        anchors.centerIn: parent
                        currentPage: paginaParcelas
                        totalPages: totalPaginasParcelas
                        
                        onPageChanged: {
                            paginaParcelas = newPage
                        }
                    }
                }
            }
        }
        
        // ==================== TAB 3: MAPA ====================
        Item {
            anchors.fill: parent
            visible: tabActiva === 2
            opacity: tabActiva === 2 ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
            
            Rectangle {
                anchors.fill: parent
                color: "white"
                radius: 10
                border.color: "#E0E0E0"
                border.width: 1
                
                Text {
                    anchors.centerIn: parent
                    text: "Mapa - En desarrollo"
                    color: "#999999"
                    font.pixelSize: 18
                }
            }
        }
    }
}
