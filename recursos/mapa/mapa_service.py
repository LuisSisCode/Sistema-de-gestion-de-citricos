# Será responsable de servir datos GeoJSON y la interfaz web del mapa
from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import json
import logging
import os
from datetime import datetime
import random

# Importar servicios existentes de tu arquitectura
from backend.services.AgricultorParcelaServ.gestion_servicio import GestionServicio
from backend.services.AgricultorParcelaServ.parcela_servicio import ParcelaServicio
from backend.services.AgricultorParcelaServ.agricultor_servicio import AgricultorServicio

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Crear aplicación Flask
app = Flask(__name__)
CORS(app)  # Permitir CORS para todas las rutas

# Inicializar servicios
gestion_servicio = GestionServicio()
parcela_servicio = ParcelaServicio()
agricultor_servicio = AgricultorServicio()

class MapaGeoJSONConverter:
    """Clase para convertir datos de parcelas a formato GeoJSON"""
    
    @staticmethod
    def parcela_to_geojson_feature(parcela):
        """
        Convierte una parcela individual a una Feature GeoJSON
        
        Args:
            parcela (dict): Datos de la parcela
            
        Returns:
            dict: Feature GeoJSON
        """
        try:
            # Obtener coordenadas - MÉTODO CORREGIDO
            coords = None
            
            # Intentar desde coordenadas_gps (formato string)
            if parcela.get('coordenadas_gps'):
                try:
                    # Formato: "-17.3465, -63.8096"
                    lat_str, lng_str = parcela['coordenadas_gps'].split(',')
                    lat = float(lat_str.strip())
                    lng = float(lng_str.strip())
                    coords = [lng, lat]  # GeoJSON: [longitud, latitud]
                    logger.info(f"Coordenadas parseadas correctamente: {coords} para parcela {parcela.get('nombre')}")
                except Exception as e:
                    logger.error(f"Error parseando coordenadas: {parcela['coordenadas_gps']} - {str(e)}")
            
            # Intentar desde latitud/longitud separadas
            if not coords and parcela.get('latitud') and parcela.get('longitud'):
                try:
                    lat = float(parcela['latitud'])
                    lng = float(parcela['longitud'])
                    coords = [lng, lat]
                    logger.info(f"Coordenadas desde lat/lng: {coords} para parcela {parcela.get('nombre')}")
                except Exception as e:
                    logger.error(f"Error con lat/lng: {str(e)}")
            
            if not coords:
                logger.warning(f"Usando ubicación por defecto para parcela {parcela.get('nombre')} (ID: {parcela.get('id_parcela')})")
                coords = [-63.90644780051694, -17.345377525340123]  # Santa Cruz
            
            geometry = {"type": "Point", "coordinates": coords}

            # CORRECCIÓN: Construir nombre del propietario correctamente
            nombre_propietario = ""
            
            # Intentar varias formas de obtener el nombre del propietario
            if parcela.get('propietario') and parcela.get('propietario') != 'Propietario desconocido':
                nombre_propietario = parcela.get('propietario')
            elif parcela.get('nombre_agricultor') and parcela.get('apellido_agricultor'):
                nombre_propietario = f"{parcela.get('nombre_agricultor', '')} {parcela.get('apellido_agricultor', '')}".strip()
            elif parcela.get('nombre_propietario'):
                nombre_propietario = parcela.get('nombre_propietario')
            else:
                nombre_propietario = "Propietario desconocido"

            # CORRECCIÓN: Obtener área correctamente
            area_total = 0.0
            if parcela.get('area_total'):
                try:
                    area_total = float(parcela.get('area_total'))
                except:
                    area_total = 0.0
            elif parcela.get('area'):
                try:
                    area_total = float(parcela.get('area'))
                except:
                    area_total = 0.0
            
            # Generar porcentaje de uso aleatorio (50-100%)
            import random
            porcentaje_uso = random.randint(50, 100)
            
            # CORRECCIÓN: Crear propiedades con datos reales
            properties = {
                "id": parcela.get('id_parcela') or parcela.get('id'),
                "nombre": parcela.get('nombre', 'Sin nombre'),
                
                # Propietario con datos reales
                "propietario": nombre_propietario,
                "propietarioId": parcela.get('id_agricultor') or parcela.get('propietarioId'),
                
                "ubicacion": parcela.get('ubicacion', ''),
                "area": area_total,
                "area_texto": f"{area_total:,.2f} ha",
                "porcentajeUso": porcentaje_uso,
                
                "tipoSuelo": parcela.get('tipo_suelo') or parcela.get('tipoSuelo', 'No especificado'),
                "fuenteAgua": parcela.get('fuente_agua') or parcela.get('fuenteAgua', 'No especificada'),
                "fechaAdquisicion": parcela.get('fecha_adquisicion') or parcela.get('fechaAdquisicion', ''),
                
                "tiene_coordenadas": bool(parcela.get('coordenadas_gps')),
                "activo": parcela.get('activo', True)
            }
            
            # Log para debugging
            logger.info(f"Parcela procesada: {properties['nombre']}, Propietario: {properties['propietario']}, Área: {properties['area']} ha")
            
            # Crear feature GeoJSON
            feature = {
                "type": "Feature",
                "geometry": geometry,
                "properties": properties
            }
            
            return feature
            
        except Exception as e:
            logger.error(f"Error convirtiendo parcela a GeoJSON: {str(e)}")
            logger.error(f"Datos de parcela: {parcela}")
            return None
    
    @staticmethod
    def parcelas_to_geojson(parcelas):
        """
        Convierte una lista de parcelas a FeatureCollection GeoJSON
        
        Args:
            parcelas (list): Lista de parcelas
            
        Returns:
            dict: FeatureCollection GeoJSON
        """
        features = []
        
        for parcela in parcelas:
            feature = MapaGeoJSONConverter.parcela_to_geojson_feature(parcela)
            if feature:
                features.append(feature)
        
        geojson = {
            "type": "FeatureCollection",
            "features": features,
            "metadata": {
                "total_parcelas": len(parcelas),
                "parcelas_con_coordenadas": len(features),
                "generado": datetime.now().isoformat()
            }
        }
        
        return geojson

# === ENDPOINTS DE LA API ===

@app.route('/')
def index():
    """Endpoint raíz con información de la API"""
    return jsonify({
        "mensaje": "Servicio de Mapas - Sistema Cítricos",
        "version": "1.0.0",
        "endpoints": {
            "parcelas_geojson": "/api/parcelas/geojson",
            "parcela_geojson": "/api/parcelas/<id>/geojson",
            "propietario_parcelas": "/api/propietarios/<id>/parcelas/geojson",
            "estadisticas": "/api/estadisticas",
            "salud": "/api/health"
        }
    })

@app.route('/mapa')
def mapa_web():
    """Sirve la interfaz web del mapa"""
    try:
        # CORREGIDO: Buscar el archivo HTML en la misma carpeta que este script
        html_path = os.path.join(os.path.dirname(__file__), 'index.html')
        
        # Si no existe en la misma carpeta, intentar en el directorio de trabajo actual
        if not os.path.exists(html_path):
            html_path = os.path.join(os.getcwd(), 'index.html')
            logger.info(f"Archivo no encontrado en carpeta script, intentando: {html_path}")
        
        # Headers de seguridad
        headers = {
            'Content-Type': 'text/html; charset=utf-8',
            'Content-Security-Policy': "default-src * 'unsafe-inline' 'unsafe-eval' data: blob:; img-src * data: blob:;"
        }
        
        if os.path.exists(html_path):
            logger.info(f"Sirviendo mapa desde: {html_path}")
            with open(html_path, 'r', encoding='utf-8') as file:
                content = file.read()
            return content, 200, headers
        else:
            logger.error(f"Archivo HTML no encontrado en ninguna ubicación")
            
            # FALLBACK: Crear HTML básico si no se encuentra el archivo
            fallback_html = """
            <!DOCTYPE html>
            <html lang="es">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Mapa de Parcelas - Fallback</title>
                <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
                <style>
                    body { margin: 0; font-family: Arial, sans-serif; }
                    #map { height: 100vh; width: 100%; }
                    .header { 
                        background: #2E7D32; 
                        color: white; 
                        padding: 10px; 
                        text-align: center; 
                        position: absolute; 
                        top: 0; 
                        left: 0; 
                        right: 0; 
                        z-index: 1000; 
                    }
                    #map { margin-top: 60px; height: calc(100vh - 60px); }
                </style>
            </head>
            <body>
                <div class="header">
                    <h3>🗺️ Mapa de Parcelas - Sistema Cítricos (Modo Básico)</h3>
                </div>
                <div id="map"></div>
                
                <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
                <script>
                    console.log('Iniciando mapa básico...');
                    
                    // Inicializar mapa
                    const map = L.map('map').setView([-17.4001, -63.9260], 12);
                    
                    // Agregar capa base
                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        attribution: '© OpenStreetMap contributors'
                    }).addTo(map);
                    
                    // Cargar parcelas
                    fetch('/api/parcelas/geojson')
                        .then(response => response.json())
                        .then(data => {
                            console.log('Parcelas cargadas:', data.features.length);
                            
                            data.features.forEach(feature => {
                                const coords = feature.geometry.coordinates;
                                const marker = L.marker([coords[1], coords[0]]).addTo(map);
                                
                                marker.bindPopup(`
                                    <b>${feature.properties.nombre}</b><br>
                                    Propietario: ${feature.properties.propietario}<br>
                                    Área: ${feature.properties.area_texto}
                                `);
                            });
                            
                            // Ajustar vista
                            if (data.features.length > 0) {
                                const group = new L.featureGroup();
                                data.features.forEach(feature => {
                                    const coords = feature.geometry.coordinates;
                                    L.marker([coords[1], coords[0]]).addTo(group);
                                });
                                map.fitBounds(group.getBounds().pad(0.1));
                            }
                        })
                        .catch(error => {
                            console.error('Error cargando parcelas:', error);
                            alert('Error cargando datos del mapa. Verifique la conexión.');
                        });
                </script>
            </body>
            </html>
            """
            
            logger.info("Sirviendo HTML de fallback")
            return fallback_html, 200, headers
            
    except Exception as e:
        logger.error(f"Error sirviendo mapa web: {str(e)}")
        return f"<html><body><h1>Error interno: {str(e)}</h1></body></html>", 500

@app.route('/api/health')
def health_check():
    """Endpoint de salud del servicio"""
    try:
        # Probar conexión a base de datos
        estadisticas = gestion_servicio.obtener_dashboard_completo()
        return jsonify({
            "status": "ok",
            "timestamp": datetime.now().isoformat(),
            "database": "connected",
            "total_parcelas": estadisticas.get('resumen', {}).get('total_parcelas', 0)
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "timestamp": datetime.now().isoformat(),
            "database": "disconnected",
            "error": str(e)
        }), 500

@app.route('/api/parcelas/geojson')
def get_parcelas_geojson():
    """
    Endpoint principal: Devuelve todas las parcelas como GeoJSON
    Parámetros opcionales:
    - propietario_id: Filtrar por propietario
    - activas_only: Solo parcelas activas (default: true)
    """
    try:
        # Obtener parámetros de consulta
        propietario_id = request.args.get('propietario_id', type=int)
        activas_only = request.args.get('activas_only', 'true').lower() == 'true'
        
        logger.info(f"Solicitando parcelas GeoJSON - Propietario: {propietario_id}, Solo activas: {activas_only}")
        
        # Obtener parcelas según filtros
        if propietario_id:
            parcelas = parcela_servicio.obtener_parcelas_por_propietario(propietario_id)
        else:
            # Obtener todas las parcelas (usar paginación grande)
            resultado = parcela_servicio.obtener_parcelas_paginado(1, 1000)
            parcelas = resultado.get('parcelas', [])
        
        # Filtrar solo activas si se solicita
        if activas_only:
            parcelas = [p for p in parcelas if p.get('activo', True)]
        
        # Convertir a GeoJSON
        geojson = MapaGeoJSONConverter.parcelas_to_geojson(parcelas)
        
        if geojson['features']:
            logger.info(f"Primera parcela GeoJSON: {json.dumps(geojson['features'][0], indent=2)}")
        
        return jsonify(geojson)
        
    except Exception as e:
        logger.error(f"Error en get_parcelas_geojson: {str(e)}")
        return jsonify({
            "error": "Error interno del servidor",
            "mensaje": str(e)
        }), 500

@app.route('/api/parcelas/<int:parcela_id>/geojson')
def get_parcela_geojson(parcela_id):
    """Devuelve una parcela específica como GeoJSON"""
    try:
        # Buscar la parcela por ID
        # Como no tienes método directo por ID, buscar en todas
        resultado = parcela_servicio.obtener_parcelas_paginado(1, 1000)
        parcelas = resultado.get('parcelas', [])
        
        parcela = None
        for p in parcelas:
            if p.get('parcelaId') == parcela_id or p.get('id') == parcela_id:
                parcela = p
                break
        
        if not parcela:
            return jsonify({
                "error": "Parcela no encontrada",
                "parcela_id": parcela_id
            }), 404
        
        # Convertir a GeoJSON
        feature = MapaGeoJSONConverter.parcela_to_geojson_feature(parcela)
        
        if not feature:
            return jsonify({
                "error": "No se pudo generar GeoJSON para esta parcela",
                "parcela_id": parcela_id
            }), 400
        
        geojson = {
            "type": "FeatureCollection",
            "features": [feature]
        }
        
        return jsonify(geojson)
        
    except Exception as e:
        logger.error(f"Error en get_parcela_geojson: {str(e)}")
        return jsonify({
            "error": "Error interno del servidor",
            "mensaje": str(e)
        }), 500

@app.route('/api/propietarios/<int:propietario_id>/parcelas/geojson')
def get_propietario_parcelas_geojson(propietario_id):
    """Devuelve las parcelas de un propietario específico como GeoJSON"""
    try:
        # Obtener parcelas del propietario
        parcelas = parcela_servicio.obtener_parcelas_por_propietario(propietario_id)
        
        if not parcelas:
            return jsonify({
                "type": "FeatureCollection",
                "features": [],
                "metadata": {
                    "total_parcelas": 0,
                    "propietario_id": propietario_id,
                    "mensaje": "No se encontraron parcelas para este propietario"
                }
            })
        
        # Convertir a GeoJSON
        geojson = MapaGeoJSONConverter.parcelas_to_geojson(parcelas)
        geojson["metadata"]["propietario_id"] = propietario_id
        
        return jsonify(geojson)
        
    except Exception as e:
        logger.error(f"Error en get_propietario_parcelas_geojson: {str(e)}")
        return jsonify({
            "error": "Error interno del servidor",
            "mensaje": str(e)
        }), 500

@app.route('/api/estadisticas')
def get_estadisticas():
    """Devuelve estadísticas generales del sistema"""
    try:
        # Obtener dashboard completo
        dashboard = gestion_servicio.obtener_dashboard_completo()
        
        # Obtener estadísticas de parcelas
        estadisticas_parcelas = parcela_servicio.obtener_estadisticas_parcelas()
        
        estadisticas = {
            "resumen": dashboard.get('resumen', {}),
            "calidad_datos": dashboard.get('calidad_datos', {}),
            "parcelas": estadisticas_parcelas,
            "timestamp": datetime.now().isoformat()
        }
        
        return jsonify(estadisticas)
        
    except Exception as e:
        logger.error(f"Error en get_estadisticas: {str(e)}")
        return jsonify({
            "error": "Error interno del servidor",
            "mensaje": str(e)
        }), 500

@app.route('/api/propietarios')
def get_propietarios():
    """Devuelve lista de propietarios para filtros"""
    try:
        propietarios = agricultor_servicio.obtener_propietarios_activos()
        
        # Formatear para el frontend
        propietarios_formateados = []
        for prop in propietarios:
            propietarios_formateados.append({
                "id": prop.get('id'),
                "nombre": prop.get('nombre', ''),
                "apellido": prop.get('apellido', ''),
                "nombre_completo": f"{prop.get('nombre', '')} {prop.get('apellido', '')}".strip()
            })
        
        return jsonify({
            "propietarios": propietarios_formateados,
            "total": len(propietarios_formateados)
        })
        
    except Exception as e:
        logger.error(f"Error en get_propietarios: {str(e)}")
        return jsonify({
            "error": "Error interno del servidor",
            "mensaje": str(e)
        }), 500

# === MANEJO DE ERRORES ===

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        "error": "Endpoint no encontrado",
        "mensaje": "La ruta solicitada no existe"
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        "error": "Error interno del servidor",
        "mensaje": "Ocurrió un error inesperado"
    }), 500

@app.after_request
def add_security_headers(resp):
    # Permitir imágenes data: y todos los orígenes
    csp = "default-src * 'unsafe-inline' 'unsafe-eval' data: blob:; img-src * data: blob:;"
    resp.headers['Content-Security-Policy'] = csp
    resp.headers['Access-Control-Allow-Origin'] = '*'
    resp.headers['Access-Control-Allow-Headers'] = '*'
    resp.headers['Access-Control-Allow-Methods'] = '*'
    return resp

# === PUNTO DE ENTRADA ===

if __name__ == '__main__':
    logger.info("Iniciando Servicio de Mapas - Sistema Cítricos")
    logger.info("Endpoints disponibles:")
    logger.info("  GET /                                    - Información de la API")
    logger.info("  GET /api/health                          - Estado del servicio")
    logger.info("  GET /api/parcelas/geojson                - Todas las parcelas")
    logger.info("  GET /api/parcelas/<id>/geojson           - Parcela específica")
    logger.info("  GET /api/propietarios/<id>/parcelas/geojson - Parcelas de propietario")
    logger.info("  GET /api/estadisticas                    - Estadísticas del sistema")
    logger.info("  GET /api/propietarios                    - Lista de propietarios")
    
    # Ejecutar en puerto 5001 para no interferir con tu aplicación principal
    app.run(host='127.0.0.1', port=5001, debug=True)