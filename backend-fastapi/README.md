# Video Downloader Backend

Backend en FastAPI para la aplicación Video Downloader Pro, proporcionando una API robusta para la descarga y procesamiento de videos.

## Características del Backend

### Endpoints Principales

- `GET /video_info`
  - Obtiene información detallada de videos
  - Soporta múltiples plataformas
  - Retorna formatos disponibles, subtítulos, etc.

- `POST /download`
  - Inicia descargas asíncronas
  - Soporte para diferentes calidades
  - Extracción de audio
  - Monitoreo de progreso

- `POST /search`
  - Búsqueda en múltiples plataformas
  - Filtros avanzados
  - Resultados paginados

- `POST /transcribe/{video_id}`
  - Transcripción de audio usando Whisper
  - Soporte para múltiples idiomas
  - Formato de salida personalizable

### Características Técnicas

- Procesamiento asíncrono de descargas
- Sistema de caché para optimizar requests
- Manejo de errores robusto
- Logging detallado
- Middleware de seguridad
- Soporte para CORS
- Rate limiting
- Compresión de respuestas

## Requisitos del Sistema

- Python 3.8+
- FFmpeg
- Espacio en disco para descargas temporales
- Memoria RAM recomendada: 2GB+

## Instalación Detallada

1. **Preparar el entorno**
```bash
# Crear y activar entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Instalar FFmpeg (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install ffmpeg

# Instalar FFmpeg (MacOS)
brew install ffmpeg

# Instalar FFmpeg (Windows)
# Descargar de https://ffmpeg.org/download.html y agregar al PATH
```

2. **Configuración del Entorno**

Crear archivo `.env` en la raíz del proyecto:
```env
# Configuración del servidor
PORT=8000
HOST=0.0.0.0
WORKERS=4
DEBUG=True

# Límites y timeouts
MAX_DOWNLOAD_SIZE=1073741824  # 1GB
DOWNLOAD_TIMEOUT=3600  # 1 hora
MAX_CONCURRENT_DOWNLOADS=5

# Configuración de almacenamiento
TEMP_DOWNLOAD_PATH=./downloads
CLOUDINARY_URL=your_cloudinary_url
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Firebase (opcional)
FIREBASE_CREDENTIALS=path/to/firebase-credentials.json

# Configuración de seguridad
API_KEY_HEADER=X-API-Key
API_KEY=your_secret_api_key
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8000
```

3. **Iniciar el Servidor**
```bash
# Desarrollo
uvicorn main:app --reload --port 8000

# Producción
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:8000
```

## Estructura del Proyecto
```
backend-fastapi/
├── main.py              # Punto de entrada y rutas principales
├── requirements.txt     # Dependencias
├── .env                # Configuración
├── downloads/          # Directorio temporal de descargas
├── logs/              # Logs de la aplicación
└── app/
    ├── core/          # Configuración central
    ├── api/           # Endpoints y rutas
    ├── models/        # Modelos Pydantic
    ├── services/      # Lógica de negocio
    └── utils/         # Utilidades

```

## API Reference

### GET /video_info
```json
{
  "url": "string",
  "response": {
    "id": "string",
    "title": "string",
    "description": "string",
    "thumbnail": "string",
    "duration": "integer",
    "formats": [
      {
        "format_id": "string",
        "ext": "string",
        "resolution": "string",
        "filesize": "integer",
        "url": "string"
      }
    ]
  }
}
```

### POST /download
```json
{
  "url": "string",
  "format": "string",
  "quality": "string",
  "extract_audio": "boolean",
  "response": {
    "download_id": "string",
    "status": "string"
  }
}
```

## Manejo de Errores

El backend implementa un sistema robusto de manejo de errores:

```python
{
  "error": {
    "code": "string",
    "message": "string",
    "details": "object"
  }
}
```

Códigos comunes:
- `400`: Solicitud inválida
- `404`: Recurso no encontrado
- `429`: Demasiadas solicitudes
- `500`: Error interno del servidor

## Monitoreo y Logs

El backend utiliza logging estructurado:

```python
{
  "timestamp": "string",
  "level": "string",
  "event": "string",
  "details": {
    "request_id": "string",
    "user_id": "string",
    "action": "string",
    "status": "string"
  }
}
```

## Seguridad

- Rate limiting por IP
- Validación de API keys
- Sanitización de entradas
- Protección contra ataques comunes
- Headers de seguridad

## Optimización

- Caché de respuestas frecuentes
- Compresión gzip
- Conexiones persistentes
- Procesamiento en segundo plano
- Limpieza automática de archivos temporales

## Contribuir

1. Fork el repositorio
2. Crear rama de feature (`git checkout -b feature/nombre`)
3. Commit cambios (`git commit -am 'Agregar característica'`)
4. Push a la rama (`git push origin feature/nombre`)
5. Crear Pull Request

## Licencia

MIT License - ver archivo LICENSE para detalles
