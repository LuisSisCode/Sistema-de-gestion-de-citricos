// AppTheme.qml - Sistema de Tema de AgroIchilo
// Sprint 1.4 - Sistema de Diseño y Arquitectura Visual
// Tipografías, espaciados, sombras y propiedades de componentes

pragma Singleton
import QtQuick 2.15
import "." as Styles

QtObject {
    id: theme
    
    // Referencia al sistema de colores
    readonly property var colors: Styles.Colors
    
    // ============================================
    // TIPOGRAFÍA - Font Sizes
    // ============================================
    readonly property int fontSizeXs: 10        // Extra pequeño (captions, labels)
    readonly property int fontSizeSm: 12        // Pequeño (hints, metadata)
    readonly property int fontSizeMd: 14        // Medio (body, inputs)
    readonly property int fontSizeLg: 16        // Grande (subtítulos)
    readonly property int fontSizeXl: 18        // Extra grande (títulos sección)
    readonly property int fontSize2xl: 24       // 2X grande (títulos principales)
    readonly property int fontSize3xl: 32       // 3X grande (títulos destacados)
    readonly property int fontSize4xl: 40       // 4X grande (displays)
    
    // ============================================
    // TIPOGRAFÍA - Font Weights
    // ============================================
    readonly property int fontWeightLight: Font.Light       // 300
    readonly property int fontWeightNormal: Font.Normal     // 400
    readonly property int fontWeightMedium: Font.Medium     // 500
    readonly property int fontWeightSemiBold: Font.DemiBold // 600
    readonly property int fontWeightBold: Font.Bold         // 700
    readonly property int fontWeightExtraBold: Font.ExtraBold // 800
    
    // ============================================
    // TIPOGRAFÍA - Font Families
    // ============================================
    readonly property string fontFamily: "Segoe UI"         // Fuente principal
    readonly property string fontFamilyHeading: "Segoe UI"  // Fuente títulos
    readonly property string fontFamilyMono: "Courier New"  // Fuente monoespaciada
    
    // ============================================
    // TIPOGRAFÍA - Line Heights
    // ============================================
    readonly property real lineHeightTight: 1.2    // Ajustado
    readonly property real lineHeightNormal: 1.5   // Normal
    readonly property real lineHeightRelaxed: 1.75 // Relajado
    readonly property real lineHeightLoose: 2.0    // Espacioso
    
    // ============================================
    // ESPACIADOS - Spacing (en píxeles)
    // ============================================
    readonly property int spaceXxs: 2      // Extra extra pequeño
    readonly property int spaceXs: 4       // Extra pequeño
    readonly property int spaceSm: 8       // Pequeño
    readonly property int spaceMd: 12      // Medio
    readonly property int spaceLg: 16      // Grande
    readonly property int spaceXl: 24      // Extra grande
    readonly property int space2xl: 32     // 2X grande
    readonly property int space3xl: 48     // 3X grande
    readonly property int space4xl: 64     // 4X grande
    
    // ============================================
    // RADIOS - Border Radius
    // ============================================
    readonly property int radiusNone: 0       // Sin radio
    readonly property int radiusSm: 4         // Pequeño
    readonly property int radiusMd: 6         // Medio
    readonly property int radiusLg: 8         // Grande
    readonly property int radiusXl: 12        // Extra grande
    readonly property int radius2xl: 16       // 2X grande
    readonly property int radiusFull: 9999    // Completamente redondo
    
    // ============================================
    // BORDES - Border Width
    // ============================================
    readonly property int borderNone: 0       // Sin borde
    readonly property int borderThin: 1       // Delgado
    readonly property int borderMedium: 2     // Medio
    readonly property int borderThick: 3      // Grueso
    readonly property int borderExtraThick: 4 // Extra grueso
    
    // ============================================
    // SOMBRAS - Box Shadows
    // ============================================
    // Sombra pequeña (hover, botones)
    readonly property var shadowSm: {
        "color": Qt.rgba(0, 0, 0, 0.1),
        "offsetX": 0,
        "offsetY": 1,
        "blur": 3,
        "spread": 0
    }
    
    // Sombra media (cards, modales pequeños)
    readonly property var shadowMd: {
        "color": Qt.rgba(0, 0, 0, 0.12),
        "offsetX": 0,
        "offsetY": 2,
        "blur": 8,
        "spread": 0
    }
    
    // Sombra grande (modales, dropdowns)
    readonly property var shadowLg: {
        "color": Qt.rgba(0, 0, 0, 0.15),
        "offsetX": 0,
        "offsetY": 4,
        "blur": 16,
        "spread": 0
    }
    
    // Sombra extra grande (overlays, popovers)
    readonly property var shadowXl: {
        "color": Qt.rgba(0, 0, 0, 0.2),
        "offsetX": 0,
        "offsetY": 8,
        "blur": 24,
        "spread": 0
    }
    
    // ============================================
    // PROPIEDADES DE COMPONENTES - Sidebar
    // ============================================
    readonly property int sidebarWidth: 260
    readonly property int sidebarHeaderHeight: 100
    readonly property int sidebarItemHeight: 48
    readonly property int sidebarIconSize: 20
    readonly property int sidebarLogoSize: 50
    
    // ============================================
    // PROPIEDADES DE COMPONENTES - Header
    // ============================================
    readonly property int headerHeight: 70
    readonly property int headerPadding: 20
    readonly property int headerAvatarSize: 40
    readonly property int headerNotificationSize: 40
    
    // ============================================
    // PROPIEDADES DE COMPONENTES - Buttons
    // ============================================
    readonly property int buttonHeightSm: 32      // Botón pequeño
    readonly property int buttonHeightMd: 40      // Botón medio
    readonly property int buttonHeightLg: 48      // Botón grande
    
    readonly property int buttonPaddingHorizontalSm: 12
    readonly property int buttonPaddingHorizontalMd: 16
    readonly property int buttonPaddingHorizontalLg: 24
    
    readonly property int buttonPaddingVerticalSm: 6
    readonly property int buttonPaddingVerticalMd: 10
    readonly property int buttonPaddingVerticalLg: 12
    
    readonly property int buttonIconSize: 16
    readonly property int buttonIconSpacing: 8
    
    // ============================================
    // PROPIEDADES DE COMPONENTES - Inputs
    // ============================================
    readonly property int inputHeightSm: 32       // Input pequeño
    readonly property int inputHeightMd: 40       // Input medio
    readonly property int inputHeightLg: 48       // Input grande
    
    readonly property int inputPaddingHorizontal: 12
    readonly property int inputPaddingVertical: 8
    readonly property int inputIconSize: 16
    
    // ============================================
    // PROPIEDADES DE COMPONENTES - Cards
    // ============================================
    readonly property int cardPadding: 20
    readonly property int cardPaddingSm: 12
    readonly property int cardPaddingLg: 24
    readonly property int cardRadius: radiusLg
    readonly property int cardMinHeight: 120
    
    // ============================================
    // PROPIEDADES DE COMPONENTES - Modales
    // ============================================
    readonly property int modalMaxWidth: 600
    readonly property int modalMinWidth: 400
    readonly property int modalPadding: 24
    readonly property int modalRadius: radiusXl
    readonly property real modalOverlayOpacity: 0.5
    
    // ============================================
    // PROPIEDADES DE COMPONENTES - Tablas
    // ============================================
    readonly property int tableHeaderHeight: 48
    readonly property int tableRowHeight: 56
    readonly property int tableCellPaddingHorizontal: 16
    readonly property int tableCellPaddingVertical: 12
    
    // ============================================
    // PROPIEDADES DE COMPONENTES - Tooltips
    // ============================================
    readonly property int tooltipMaxWidth: 300
    readonly property int tooltipPadding: 8
    readonly property int tooltipRadius: radiusMd
    readonly property int tooltipArrowSize: 6
    
    // ============================================
    // PROPIEDADES DE COMPONENTES - Notifications
    // ============================================
    readonly property int notificationWidth: 360
    readonly property int notificationPadding: 16
    readonly property int notificationRadius: radiusLg
    readonly property int notificationIconSize: 24
    
    // ============================================
    // PROPIEDADES DE COMPONENTES - Breadcrumbs
    // ============================================
    readonly property int breadcrumbHeight: 32
    readonly property int breadcrumbIconSize: 14
    readonly property int breadcrumbSpacing: 8
    
    // ============================================
    // PROPIEDADES DE ANIMACIÓN - Transitions
    // ============================================
    readonly property int transitionFast: 150      // Rápida
    readonly property int transitionNormal: 250    // Normal
    readonly property int transitionSlow: 400      // Lenta
    
    readonly property int easingType: Easing.OutCubic
    
    // ============================================
    // Z-INDEX - Capas de profundidad
    // ============================================
    readonly property int zIndexBase: 0           // Capa base
    readonly property int zIndexDropdown: 1000    // Dropdowns
    readonly property int zIndexSticky: 1100      // Headers fijos
    readonly property int zIndexModal: 1300       // Modales
    readonly property int zIndexPopover: 1400     // Popovers
    readonly property int zIndexTooltip: 1500     // Tooltips
    readonly property int zIndexNotification: 1600 // Notificaciones
    
    // ============================================
    // BREAKPOINTS - Responsive (para futuro)
    // ============================================
    readonly property int breakpointXs: 480       // Extra pequeño
    readonly property int breakpointSm: 768       // Pequeño
    readonly property int breakpointMd: 1024      // Medio
    readonly property int breakpointLg: 1280      // Grande
    readonly property int breakpointXl: 1536      // Extra grande
    
    // ============================================
    // FUNCIONES AUXILIARES
    // ============================================
    
    // Obtener altura de componente según tamaño
    function getComponentHeight(size) {
        switch(size) {
            case "sm": return buttonHeightSm
            case "md": return buttonHeightMd
            case "lg": return buttonHeightLg
            default: return buttonHeightMd
        }
    }
    
    // Obtener padding según tamaño
    function getPadding(size) {
        switch(size) {
            case "xs": return spaceXs
            case "sm": return spaceSm
            case "md": return spaceMd
            case "lg": return spaceLg
            case "xl": return spaceXl
            default: return spaceMd
        }
    }
    
    // Obtener font size según nivel de encabezado
    function getHeadingSize(level) {
        switch(level) {
            case 1: return fontSize3xl
            case 2: return fontSize2xl
            case 3: return fontSizeXl
            case 4: return fontSizeLg
            case 5: return fontSizeMd
            case 6: return fontSizeSm
            default: return fontSizeMd
        }
    }
    
    // Obtener espaciado responsive
    function getResponsiveSpacing(baseSize, screenWidth) {
        if (screenWidth < breakpointSm) {
            return baseSize * 0.75
        } else if (screenWidth < breakpointMd) {
            return baseSize * 0.875
        }
        return baseSize
    }
}
