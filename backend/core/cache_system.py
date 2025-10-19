# bd_capa/nucleo/cache_system.py

import threading
import time
import logging
from typing import Dict, Any, Optional, Set, Callable
from datetime import datetime, timedelta
from functools import wraps
import hashlib
import json

class CacheManager:
    """Gestor de caché centralizado con soporte para TTL e invalidación"""
    
    def __init__(self, default_ttl: int = 1800):  # 30 minutos por defecto
        self._cache: Dict[str, Dict[str, Any]] = {}
        self._metadata: Dict[str, Dict[str, Dict]] = {}
        self._lock = threading.RLock()
        self.default_ttl = default_ttl
        self.logger = logging.getLogger('CacheManager')
        self._stats = {'hits': 0, 'misses': 0, 'invalidations': 0}
        
    def get(self, namespace: str, key: str = None) -> Optional[Any]:
        """Obtiene datos del caché"""
        with self._lock:
            if namespace not in self._cache:
                self._stats['misses'] += 1
                return None
            
            cache_key = key or 'default'
            
            if cache_key not in self._cache[namespace]:
                self._stats['misses'] += 1
                return None
            
            # Verificar TTL
            if self._is_expired(namespace, cache_key):
                self._remove_key(namespace, cache_key)
                self._stats['misses'] += 1
                return None
            
            self._stats['hits'] += 1
            return self._cache[namespace][cache_key]
    
    def set(self, namespace: str, data: Any, key: str = None, ttl: int = None):
        """Guarda datos en caché"""
        with self._lock:
            if namespace not in self._cache:
                self._cache[namespace] = {}
                self._metadata[namespace] = {}
            
            cache_key = key or 'default'
            ttl = ttl or self.default_ttl
            
            self._cache[namespace][cache_key] = data
            self._metadata[namespace][cache_key] = {
                'timestamp': datetime.now(),
                'ttl': ttl
            }
    
    def invalidate(self, namespace: str, key: str = None):
        """Invalida caché específico"""
        with self._lock:
            if namespace not in self._cache:
                return
            
            if key:
                self._remove_key(namespace, key)
            else:
                self._cache.pop(namespace, None)
                self._metadata.pop(namespace, None)
            
            self._stats['invalidations'] += 1
    
    def invalidate_pattern(self, pattern: str):
        """Invalida claves que contengan el patrón"""
        with self._lock:
            keys_to_remove = []
            for namespace in self._cache:
                for key in self._cache[namespace]:
                    if pattern in f"{namespace}.{key}":
                        keys_to_remove.append((namespace, key))
            
            for namespace, key in keys_to_remove:
                self._remove_key(namespace, key)
    
    def clear_all(self):
        """Limpia todo el caché"""
        with self._lock:
            self._cache.clear()
            self._metadata.clear()
    
    def get_stats(self):
        """Obtiene estadísticas del caché"""
        total = self._stats['hits'] + self._stats['misses']
        hit_rate = (self._stats['hits'] / total * 100) if total > 0 else 0
        return {**self._stats, 'hit_rate': round(hit_rate, 2)}
    
    def _is_expired(self, namespace: str, key: str) -> bool:
        """Verifica si una clave ha expirado"""
        if namespace not in self._metadata or key not in self._metadata[namespace]:
            return True
        
        metadata = self._metadata[namespace][key]
        expiry_time = metadata['timestamp'] + timedelta(seconds=metadata['ttl'])
        return datetime.now() > expiry_time
    
    def _remove_key(self, namespace: str, key: str):
        """Remueve una clave específica"""
        self._cache[namespace].pop(key, None)
        self._metadata[namespace].pop(key, None)
        
        if not self._cache[namespace]:
            self._cache.pop(namespace, None)
            self._metadata.pop(namespace, None)

# Instancia global del cache manager
cache_manager = CacheManager()

def generate_cache_key(*args, **kwargs) -> str:
    """Genera una clave única basada en argumentos"""
    key_data = {
        'args': [str(arg) for arg in args if arg is not None],
        'kwargs': {k: str(v) for k, v in kwargs.items() if v is not None}
    }
    key_string = json.dumps(key_data, sort_keys=True)
    return hashlib.md5(key_string.encode()).hexdigest()[:12]

def cacheable(namespace: str, ttl: int = 1800, key_func: Callable = None):
    """Decorador para cachear métodos"""
    def decorator(func):
        @wraps(func)
        def wrapper(self, *args, **kwargs):
            # Generar clave
            if key_func:
                cache_key = key_func(*args, **kwargs)
            else:
                cache_key = f"{func.__name__}_{generate_cache_key(*args, **kwargs)}"
            
            # Intentar obtener del caché
            cached_data = cache_manager.get(namespace, cache_key)
            if cached_data is not None:
                if hasattr(self, 'logger'):
                    self.logger.info(f"Cache HIT: {namespace}.{cache_key}")
                return cached_data
            
            # Ejecutar función original
            if hasattr(self, 'logger'):
                self.logger.info(f"Cache MISS: {namespace}.{cache_key}")
            
            result = func(self, *args, **kwargs)
            
            # Guardar en caché si el resultado es válido
            if result is not None and result != []:
                cache_manager.set(namespace, result, cache_key, ttl)
            
            return result
        return wrapper
    return decorator

def cache_invalidator(namespace: str, key: str = None, pattern: str = None):
    """Decorador para invalidar caché"""
    def decorator(func):
        @wraps(func)
        def wrapper(self, *args, **kwargs):
            result = func(self, *args, **kwargs)
            
            # Solo invalidar si la operación fue exitosa
            if result and (isinstance(result, bool) or (isinstance(result, tuple) and result[0])):
                if pattern:
                    cache_manager.invalidate_pattern(pattern)
                else:
                    cache_manager.invalidate(namespace, key)
                
                if hasattr(self, 'logger'):
                    self.logger.info(f"Cache invalidado tras: {func.__name__}")
            
            return result
        return wrapper
    return decorator

# Configuración de TTL por módulo
TTL_CONFIG = {
    'agricultores': 1800,      # 30 minutos
    'parcelas': 1800,          # 30 minutos  
    'clientes': 900,           # 15 minutos
    'ventas': 300,             # 5 minutos
    'cultivos': 3600,          # 1 hora
    'variedades': 3600,        # 1 hora
    'agroquimicos': 1800,      # 30 minutos
    'maquinaria': 1800,        # 30 minutos
    'usuarios': 3600,          # 1 hora
    'roles': 7200,             # 2 horas
    'estadisticas': 600,       # 10 minutos
    'reportes': 300,           # 5 minutos
}

def get_ttl(namespace: str) -> int:
    """Obtiene el TTL configurado para un namespace"""
    return TTL_CONFIG.get(namespace, 1800)

def print_cache_stats():
    """Imprime estadísticas del caché"""
    stats = cache_manager.get_stats()
    print(f"\n📊 CACHE STATS: Hits: {stats['hits']} | Misses: {stats['misses']} | Hit Rate: {stats['hit_rate']}%")

def clear_cache():
    """Limpia todo el caché"""
    cache_manager.clear_all()
    print("✅ Caché limpiado")
