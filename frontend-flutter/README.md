# Video Downloader Pro

Una aplicación moderna para descargar videos con múltiples características.

## Requisitos de Instalación

1. Instalar Flutter:
   - Windows: https://docs.flutter.dev/get-started/install/windows
   - macOS: https://docs.flutter.dev/get-started/install/macos
   - Linux: https://docs.flutter.dev/get-started/install/linux

2. Instalar Android Studio:
   - Descargar de: https://developer.android.com/studio
   - Instalar el Android SDK
   - Configurar un emulador Android

## Compilación

1. Clonar el repositorio:
```bash
git clone <url-del-repositorio>
cd frontend-flutter
```

2. Obtener dependencias:
```bash
flutter pub get
```

3. Compilar APK:
```bash
flutter build apk --release
```

El APK se generará en:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Actualización

Para actualizar la aplicación:

1. Incrementar la versión en pubspec.yaml:
```yaml
version: 1.0.1+2  # Formato: version_name+version_code
```

2. Compilar nuevo APK:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Características

- Descarga de videos de múltiples plataformas
- Interfaz moderna y fácil de usar
- Soporte para alta calidad (hasta 4K)
- Extracción de audio
- Modo oscuro
- Autenticación segura
- Gestión de descargas
- Soporte multilenguaje

## Solución de Problemas

Si encuentras el error "Flutter command not found":

1. Asegúrate de que Flutter está instalado:
```bash
echo $PATH  # Verifica que la ruta de Flutter está en el PATH
```

2. Reinicia la terminal después de instalar Flutter

3. En Windows, asegúrate de agregar Flutter al PATH del sistema:
   - Panel de Control > Sistema > Configuración avanzada del sistema
   - Variables de entorno > Path > Editar
   - Agregar la ruta a flutter\bin

## Contacto

Para soporte o reportar problemas, por favor crear un issue en el repositorio.
