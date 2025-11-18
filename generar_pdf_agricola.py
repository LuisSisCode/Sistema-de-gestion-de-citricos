# -*- coding: utf-8 -*-
import os
from pathlib import Path
import sys
import json
from datetime import datetime
from PySide6.QtCore import QObject, Slot
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch, mm
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
from reportlab.pdfgen import canvas

COLOR_VERDE_PRINCIPAL = colors.Color(0.30, 0.58, 0.23)
COLOR_GRIS_CLARO = colors.Color(0.95, 0.95, 0.95)
COLOR_GRIS_OSCURO = colors.Color(0.2, 0.2, 0.2)

class GeneradorReportesAgriculaPDF(QObject):
    """Generador de reportes PDF para AgroIchilo - Compatible con Qt"""
    
    def __init__(self):
        super().__init__()
        
        if getattr(sys, 'frozen', False):
            base_dir = Path(os.environ.get('APPDATA', Path.home())) / 'AgroIchilo'
        else:
            base_dir = Path(__file__).parent.parent.parent

        self.pdf_dir = base_dir / 'reportes'
        try:
            self.pdf_dir.mkdir(parents=True, exist_ok=True)
        except Exception as e:
            self.pdf_dir = Path.home() / 'AgroIchilo' / 'reportes'
            self.pdf_dir.mkdir(parents=True, exist_ok=True)

        self.page_width, self.page_height = A4
        self.margin = 50
        self.styles = getSampleStyleSheet()
        self.usuario_responsable = ""
        self.datos_reporte = []
        self.tipo_reporte = 0
        self.fecha_desde = ""
        self.fecha_hasta = ""
        self._crear_estilos_personalizados()
    
    def _crear_estilos_personalizados(self):
        """Crea estilos de párrafo personalizados"""
        titulo_style = ParagraphStyle(
            'TituloReporte',
            parent=self.styles['Heading1'],
            fontSize=24,
            textColor=COLOR_VERDE_PRINCIPAL,
            spaceAfter=6,
            alignment=TA_CENTER,
            fontName='Helvetica-Bold'
        )
        self.styles.add(titulo_style)

    @Slot(str, int, str, str, result=str)
    def generar_reporte_pdf(self, datos_json, tipo_reporte, fecha_desde, fecha_hasta):
        """Genera un reporte PDF y retorna la ruta del archivo"""
        try:
            self.tipo_reporte = tipo_reporte
            self.fecha_desde = fecha_desde
            self.fecha_hasta = fecha_hasta
            
            if isinstance(datos_json, str):
                try:
                    self.datos_reporte = json.loads(datos_json)
                except:
                    self.datos_reporte = []
            else:
                self.datos_reporte = datos_json
            
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            tipos_map = {
                1: "Produccion_Cultivos",
                2: "Inventario_Agroquimicos",
                3: "Ventas_Clientes",
                4: "Gestion_Parcelas",
                5: "Maquinaria_Equipos",
                6: "Consumo_Combustible",
                7: "Mantenimiento_Equipos",
                8: "Tratamientos_Fitosanitarios",
                9: "Reporte_Financiero"
            }
            
            tipo_nombre = tipos_map.get(tipo_reporte, "Reporte_General")
            nombre_archivo = f"{tipo_nombre}_{timestamp}.pdf"
            ruta_archivo = self.pdf_dir / nombre_archivo
            
            doc = SimpleDocTemplate(
                str(ruta_archivo),
                pagesize=A4,
                rightMargin=self.margin,
                leftMargin=self.margin,
                topMargin=80,
                bottomMargin=60,
                title=f"Reporte AgroIchilo - {tipo_nombre}"
            )
            
            story = []
            story.append(Spacer(1, 10*mm))
            
            titulo = self._obtener_titulo_reporte(tipo_reporte)
            titulo_para = Paragraph(titulo, self.styles['TituloReporte'])
            story.append(titulo_para)
            story.append(Spacer(1, 5*mm))
            
            periodo_text = f"<b>Período:</b> {fecha_desde} al {fecha_hasta}"
            periodo_para = Paragraph(periodo_text, self.styles['Normal'])
            story.append(periodo_para)
            story.append(Spacer(1, 15*mm))
            
            if self.datos_reporte and len(self.datos_reporte) > 0:
                table = self._crear_tabla_datos()
                story.append(table)
            else:
                sin_datos = Paragraph("<b>No hay datos disponibles para este período</b>", self.styles['Normal'])
                story.append(sin_datos)
            
            story.append(Spacer(1, 15*mm))
            
            doc.build(story)
            
            print(f"✅ PDF generado: {ruta_archivo}")
            return str(ruta_archivo)
                
        except Exception as e:
            print(f"❌ Error generando reporte PDF: {e}")
            import traceback
            traceback.print_exc()
            return ""

    def _crear_tabla_datos(self):
        """Crea la tabla de datos según el tipo de reporte"""
        columnas = self._obtener_columnas()
        table_data = [columnas]
        
        total_valor = 0
        for registro in self.datos_reporte:
            fila = []
            for col in columnas:
                valor = registro.get(col, 'N/A')
                
                if isinstance(valor, (int, float)):
                    if col in ['valor', 'precio_unitario', 'valor_total', 'costo_total', 'costo', 'total', 'ingresos', 'egresos']:
                        fila.append(f"Bs {float(valor):,.2f}")
                        if col == 'valor' or col == 'valor_total' or col == 'costo_total' or col == 'costo' or col == 'total':
                            total_valor += float(valor)
                    else:
                        fila.append(f"{valor:.2f}")
                else:
                    fila.append(str(valor)[:40])
            
            table_data.append(fila)
        
        fila_total = ['TOTAL']
        for i, col in enumerate(columnas[1:], 1):
            if i == len(columnas) - 1:
                fila_total.append(f"Bs {total_valor:,.2f}")
            else:
                fila_total.append("")
        
        table_data.append(fila_total)
        
        ancho_col = (self.page_width - 2*self.margin) / len(columnas)
        table = Table(table_data, colWidths=[ancho_col] * len(columnas))
        
        table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), COLOR_VERDE_PRINCIPAL),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 9),
            ('TOPPADDING', (0, 0), (-1, 0), 8),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 8),
            
            ('FONTNAME', (0, 1), (-1, -2), 'Helvetica'),
            ('FONTSIZE', (0, 1), (-1, -2), 8),
            ('TOPPADDING', (0, 1), (-1, -2), 6),
            ('BOTTOMPADDING', (0, 1), (-1, -2), 6),
            ('ROWHEIGHT', (0, 1), (-1, -2), 20),
            
            ('BACKGROUND', (0, -1), (-1, -1), COLOR_VERDE_PRINCIPAL),
            ('TEXTCOLOR', (0, -1), (-1, -1), colors.white),
            ('FONTNAME', (0, -1), (-1, -1), 'Helvetica-Bold'),
            ('FONTSIZE', (0, -1), (-1, -1), 10),
            
            ('GRID', (0, 0), (-1, -1), 0.5, colors.black),
            ('ROWBACKGROUNDS', (0, 1), (-1, -2), [colors.white, COLOR_GRIS_CLARO]),
        ]))
        
        return table

    def _obtener_columnas(self):
        """Obtiene las columnas según el tipo de reporte"""
        if not self.datos_reporte or len(self.datos_reporte) == 0:
            return ['fecha', 'descripcion', 'valor']
        
        primer_registro = self.datos_reporte[0]
        columnas_posibles = list(primer_registro.keys())
        
        columnas_ordenadas = [
            'fecha', 'cultivo', 'producto', 'cliente', 'productor', 'equipo',
            'variedad', 'marca', 'parcela', 'tipo', 'descripcion',
            'cantidad', 'stock', 'litros', 'hectareas', 'año',
            'precio_unitario', 'valor', 'valor_total', 'costo_total', 'costo',
            'total', 'estado', 'ingresos', 'egresos'
        ]
        
        columnas_finales = [col for col in columnas_ordenadas if col in columnas_posibles]
        
        if not columnas_finales:
            columnas_finales = columnas_posibles[:6]
        
        return columnas_finales[:6]

    def _obtener_titulo_reporte(self, tipo):
        """Obtiene el título según el tipo de reporte"""
        titulos = {
            1: "REPORTE DE PRODUCCIÓN POR CULTIVOS",
            2: "REPORTE DE INVENTARIO DE AGROQUÍMICOS",
            3: "REPORTE DE VENTAS Y CLIENTES",
            4: "REPORTE DE GESTIÓN DE PARCELAS",
            5: "REPORTE DE MAQUINARIA Y EQUIPOS",
            6: "REPORTE DE CONSUMO DE COMBUSTIBLE",
            7: "REPORTE DE MANTENIMIENTO DE EQUIPOS",
            8: "REPORTE DE TRATAMIENTOS FITOSANITARIOS",
            9: "REPORTE FINANCIERO CONSOLIDADO"
        }
        return titulos.get(tipo, "REPORTE GENERAL")

    @Slot(result=str)
    def exportarPDF(self):
        """Método que QML llama para exportar PDF con datos actuales"""
        try:
            datos_json = json.dumps(self.datos_reporte)
            return self.generar_reporte_pdf(datos_json, self.tipo_reporte, self.fecha_desde, self.fecha_hasta)
        except Exception as e:
            print(f"❌ Error en exportarPDF: {e}")
            return ""
