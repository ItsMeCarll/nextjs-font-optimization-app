# Video Downloader Pro

Una aplicación moderna y potente para descargar videos de múltiples plataformas como YouTube, Facebook, Instagram, Twitter, y más.

## Características

- 📥 **Descarga de videos**
  - Soporte para múltiples plataformas
  - Selección de calidad (hasta 4K)
  - Extracción de audio (MP3)
  - Descarga rápida con conexiones paralelas

- 🎵 **Características de Audio**
  - Conversión a MP3
  - Reconocimiento de música (estilo Shazam)
  - Extracción de subtítulos y transcripción

- 🔒 **Privacidad y Seguridad**
  - Modo VPN integrado
  - Carpeta privada con protección biométrica
  - Historial de descargas protegido

- 🎮 **Interfaz Avanzada**
  - Diseño Material 3
  - Modo oscuro/claro
  - Ventana flotante para reproducción
  - Interfaz intuitiva y moderna

- 🔍 **Búsqueda y Organización**
  - Motor de búsqueda integrado
  - Organización automática de archivos
  - Gestión de listas de reproducción
  - Detección automática de enlaces

- 🎯 **Características Especiales**
  - Comandos de voz para descargas
  - Detección de música en segundo plano
  - Soporte para múltiples formatos
  - Notificaciones personalizables

## Tecnologías Utilizadas

### Frontend (Flutter)
- Material 3 Design
- Provider para gestión de estado
- WebView para navegación integrada
- Reproductor de video/audio personalizado
- Biometría y almacenamiento seguro

### Backend (FastAPI)
- API RESTful
- Procesamiento asíncrono
- Integración con yt-dlp
- Transcripción con Whisper
- Gestión de descargas en segundo plano

### Almacenamiento
- Firebase Auth
- Cloud Firestore
- Cloudinary para medios
- Almacenamiento local seguro

## Instalación

### Requisitos Previos
- Flutter SDK
- Python 3.8+
- FFmpeg
- Git

### Frontend (Flutter)
```bash
# Clonar el repositorio
git clone https://github.com/tuusuario/video-downloader-pro.git

# Navegar al directorio del frontend
cd video-downloader-pro/frontend-flutter

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

### Backend (FastAPI)
```bash
# Navegar al directorio del backend
cd video-downloader-pro/backend-fastapi

# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar el servidor
uvicorn main:app --reload
```

## Uso

1. **Descargar Videos**
   - Pega la URL del video
   - Selecciona la calidad deseada
   - Elige el formato (video o audio)
   - Inicia la descarga

2. **Búsqueda de Videos**
   - Usa el buscador integrado
   - Filtra por plataforma y categoría
   - Previsualiza antes de descargar

3. **Gestión de Descargas**
   - Monitorea el progreso
   - Pausa/reanuda descargas
   - Organiza por carpetas

4. **Características Avanzadas**
   - Activa el modo VPN si es necesario
   - Usa comandos de voz
   - Configura la carpeta privada
   - Crea listas de reproducción

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu función (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Distribuido bajo la Licencia MIT. Ver `LICENSE` para más información.

## Contacto

Tu Nombre - [@tutwitter](https://twitter.com/tutwitter)

Link del Proyecto: [https://github.com/tuusuario/video-downloader-pro](https://github.com/tuusuario/video-downloader-pro)
