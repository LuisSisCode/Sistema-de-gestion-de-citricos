
import os
import sys
import subprocess

def start_application():
    """
    Inicia la aplicación comenzando por el login.
    """
    try:
        # Obtener la ruta del directorio actual
        current_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Ruta al script de login
        login_script = os.path.join(current_dir, "login.py")
        
        if not os.path.exists(login_script):
            print(f"Error: No se encontró el archivo de login en {login_script}")
            sys.exit(1)
            
        # Ejecutar el script de login (no como subproceso, sino como proceso principal)
        print("Iniciando sistema con pantalla de login...")
        
        # Usar el mismo intérprete de Python que está ejecutando este script
        python_executable = sys.executable
        
        # Ejecutar el proceso de login y esperar a que termine
        process = subprocess.Popen([python_executable, login_script])
        process.wait()
        
        # El proceso de login se encargará de iniciar main.py si la autenticación es exitosa
        # No es necesario hacer nada más aquí
        
    except Exception as e:
        print(f"Error al iniciar la aplicación: {e}")
        sys.exit(1)

if __name__ == "__main__":
    start_application()