// Colors.qml - Sistema de Colores de AgroIchilo
// Sprint 1.4 - Sistema de Diseño y Arquitectura Visual
// Paleta de colores profesional para sistema agrícola

pragma Singleton
import QtQuick 2.15

QtObject {
    id: colors
    
    // ============================================
    // COLORES PRIMARIOS - Verde Agrícola
    // ============================================
    readonly property color primary: "#2E7D32"           // Verde principal
    readonly property color primaryLight: "#4CAF50"      // Verde claro
    readonly property color primaryDark: "#1B5E20"       // Verde oscuro
    readonly property color primaryAccent: "#81C784"     // Verde acento
    readonly property color primaryHover: "#388E3C"      // Verde hover
    readonly property color primaryPressed: "#1B5E20"    // Verde pressed
    
    // ============================================
    // COLORES SECUNDARIOS - Verde Acento
    // ============================================
    readonly property color secondary: "#81C784"         // Verde acento
    readonly property color secondaryLight: "#A5D6A7"    // Verde acento claro
    readonly property color secondaryDark: "#66BB6A"     // Verde acento oscuro
    readonly property color secondaryHover: "#66BB6A"    // Verde acento hover
    readonly property color secondaryPressed: "#4CAF50"  // Verde acento pressed
    
    // ============================================
    // COLORES ACENTO - Azul Cielo/Agua
    // ============================================
    readonly property color accent: "#2196F3"            // Azul agua
    readonly property color accentLight: "#64B5F6"       // Azul claro
    readonly property color accentDark: "#1976D2"        // Azul oscuro
    
    // ============================================
    // COLORES DE ESTADO - Feedback Visual
    // ============================================
    readonly property color success: "#4CAF50"           // Verde éxito
    readonly property color successLight: "#81C784"      // Verde éxito claro
    readonly property color successDark: "#388E3C"       // Verde éxito oscuro
    readonly property color successBg: "#E8F5E9"         // Fondo éxito
    
    readonly property color warning: "#FFC107"           // Amarillo advertencia
    readonly property color warningLight: "#FFECB3"      // Amarillo advertencia claro
    readonly property color warningDark: "#FFA000"       // Amarillo advertencia oscuro
    readonly property color warningBg: "#FFF9C4"         // Fondo advertencia
    
    readonly property color error: "#F44336"             // Rojo error
    readonly property color errorLight: "#E57373"        // Rojo error claro
    readonly property color errorDark: "#D32F2F"         // Rojo error oscuro
    readonly property color errorBg: "#FFEBEE"           // Fondo error
    
    readonly property color info: "#2196F3"              // Azul información
    readonly property color infoLight: "#64B5F6"         // Azul información claro
    readonly property color infoDark: "#1976D2"          // Azul información oscuro
    readonly property color infoBg: "#E3F2FD"            // Fondo información
    
    // ============================================
    // COLORES NEUTRALES - Grises y Blancos
    // ============================================
    readonly property color white: "#FFFFFF"
    readonly property color black: "#000000"
    
    readonly property color gray50: "#FAFAFA"            // Gris muy claro
    readonly property color gray100: "#F5F5F5"           // Gris ultra claro
    readonly property color gray200: "#EEEEEE"           // Gris claro
    readonly property color gray300: "#E0E0E0"           // Gris medio claro
    readonly property color gray400: "#BDBDBD"           // Gris medio
    readonly property color gray500: "#9E9E9E"           // Gris
    readonly property color gray600: "#757575"           // Gris oscuro
    readonly property color gray700: "#616161"           // Gris muy oscuro
    readonly property color gray800: "#424242"           // Gris ultra oscuro
    readonly property color gray900: "#212121"           // Casi negro
    
    // ============================================
    // COLORES DE FONDO - Backgrounds
    // ============================================
    readonly property color bgApp: "#F1F8E9"             // Fondo principal app
    readonly property color bgPaper: "#FFFFFF"           // Fondo tarjetas/papel
    readonly property color bgDefault: "#F1F8E9"         // Fondo por defecto
    readonly property color bgElevated: "#FFFFFF"        // Fondo elevado
    readonly property color bgOverlay: "#000000"         // Overlay oscuro (con opacity)
    
    // ============================================
    // COLORES DE TEXTO - Typography
    // ============================================
    readonly property color textPrimary: "#2E3A32"       // Texto principal (oscuro)
    readonly property color textSecondary: "#546E7A"     // Texto secundario (medio)
    readonly property color textDisabled: "#78909C"      // Texto deshabilitado (claro)
    readonly property color textHint: "#78909C"          // Texto hint/placeholder
    readonly property color textOnPrimary: "#FFFFFF"     // Texto sobre color primario
    readonly property color textOnSecondary: "#FFFFFF"   // Texto sobre color secundario
    readonly property color textOnDark: "#FFFFFF"        // Texto sobre fondo oscuro
    readonly property color textOnLight: "#2E3A32"       // Texto sobre fondo claro
    
    // ============================================
    // COLORES DE BORDES - Borders
    // ============================================
    readonly property color border: "#E0E0E0"            // Borde por defecto
    readonly property color borderLight: "#F1F8E9"       // Borde claro (fondo claro)
    readonly property color borderDark: "#546E7A"        // Borde oscuro (texto medio)
    readonly property color borderFocus: "#2E7D32"       // Borde focus (verde principal)
    readonly property color borderError: "#F44336"       // Borde error
    readonly property color borderSuccess: "#4CAF50"     // Borde success (verde claro)
    
    // ============================================
    // COLORES DEL SIDEBAR - Menú Lateral
    // ============================================
    readonly property color sidebarBg: "#1B5E20"         // Fondo sidebar (verde oscuro)
    readonly property color sidebarHeader: "#145018"     // Header del sidebar (más oscuro)
    readonly property color sidebarItemHover: "#2E7D32"  // Hover item (verde principal)
    readonly property color sidebarItemActive: "#4CAF50" // Item activo (verde claro)
    readonly property color sidebarText: "#FFFFFF"       // Texto sidebar
    readonly property color sidebarTextMuted: "#81C784"  // Texto muted sidebar (verde acento)
    readonly property color sidebarSeparator: "#2E7D32"  // Línea separadora
    
    // ============================================
    // COLORES DEL HEADER - Barra Superior
    // ============================================
    readonly property color headerBg: "#FFFFFF"          // Fondo header
    readonly property color headerBorder: "#E0E0E0"      // Borde inferior header
    readonly property color headerText: "#2E3A32"        // Texto header (texto oscuro)
    readonly property color headerTextMuted: "#546E7A"   // Texto secundario header (texto medio)
    
    // ============================================
    // COLORES DE NAVEGACIÓN - Breadcrumbs, Tabs
    // ============================================
    readonly property color navActive: "#2E7D32"         // Navegación activa (verde principal)
    readonly property color navInactive: "#78909C"       // Navegación inactiva (texto claro)
    readonly property color navHover: "#4CAF50"          // Navegación hover (verde claro)
    
    // ============================================
    // COLORES DE COMPONENTES - Buttons, Cards, etc
    // ============================================
    readonly property color cardBg: "#FFFFFF"            // Fondo tarjetas
    readonly property color cardBorder: "#E0E0E0"        // Borde tarjetas
    readonly property color cardShadow: "#00000029"      // Sombra tarjetas (con opacity)
    
    readonly property color inputBg: "#FFFFFF"           // Fondo inputs
    readonly property color inputBorder: "#E0E0E0"       // Borde inputs
    readonly property color inputFocus: "#2E7D32"        // Borde input focus (verde principal)
    readonly property color inputDisabled: "#F1F8E9"     // Fondo input disabled
    
    readonly property color buttonPrimaryBg: "#2E7D32"   // Botón primario
    readonly property color buttonSecondaryBg: "#81C784" // Botón secundario (verde acento)
    readonly property color buttonGhostBg: "transparent" // Botón ghost
    readonly property color buttonDisabledBg: "#E0E0E0"  // Botón disabled
    
    // ============================================
    // COLORES ESPECIALES - Dashboard, Gráficos
    // ============================================
    readonly property color chartGreen: "#4CAF50"        // Gráficos - verde claro
    readonly property color chartGreenDark: "#2E7D32"    // Gráficos - verde principal
    readonly property color chartGreenLight: "#81C784"   // Gráficos - verde acento
    readonly property color chartBlue: "#2196F3"         // Gráficos - azul
    readonly property color chartRed: "#F44336"          // Gráficos - rojo
    readonly property color chartYellow: "#FFC107"       // Gráficos - amarillo
    
    // ============================================
    // FUNCIONES AUXILIARES
    // ============================================
    
    // Función para agregar opacidad a un color
    function withOpacity(color, opacity) {
        var tempColor = Qt.rgba(0, 0, 0, 0)
        tempColor = Qt.lighter(color, 1.0)
        return Qt.rgba(tempColor.r, tempColor.g, tempColor.b, opacity)
    }
    
    // Función para obtener color según estado
    function getStateColor(state) {
        switch(state) {
            case "success": return success
            case "warning": return warning
            case "error": return error
            case "info": return info
            default: return primary
        }
    }
    
    // Función para obtener color de texto según fondo
    function getTextColor(backgroundColor) {
        // Calcular luminosidad del color de fondo
        var r = backgroundColor.r
        var g = backgroundColor.g
        var b = backgroundColor.b
        var luminance = (0.299 * r + 0.587 * g + 0.114 * b)
        
        // Si el fondo es oscuro, usar texto claro y viceversa
        return luminance > 0.5 ? textPrimary : textOnDark
    }
}
