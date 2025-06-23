import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_settings.dart';

class StoragePathService {
  final AppSettings _settings;
  List<Directory>? _storageDirectories;

  StoragePathService(this._settings) {
    _initializeStoragePaths();
  }

  Future<void> _initializeStoragePaths() async {
    if (Platform.isAndroid) {
      _storageDirectories = await getExternalStorageDirectories();
    }
  }

  Future<List<StorageInfo>> getAvailableStoragePaths() async {
    List<StorageInfo> storagePaths = [];

    if (Platform.isAndroid) {
      // Verificar permisos
      final status = await Permission.storage.request();
      if (!status.isGranted) return storagePaths;

      // Obtener almacenamiento interno
      final internalDir = await getExternalStorageDirectory();
      if (internalDir != null) {
        storagePaths.add(StorageInfo(
          path: internalDir.path,
          name: 'Almacenamiento Interno',
          isSDCard: false,
          totalSpace: await _getTotalSpace(internalDir),
          freeSpace: await _getFreeSpace(internalDir),
        ));
      }

      // Obtener tarjetas SD
      if (_storageDirectories != null) {
        for (var dir in _storageDirectories!) {
          // Verificar si es una tarjeta SD (diferente al almacenamiento interno)
          if (dir.path != internalDir?.path) {
            storagePaths.add(StorageInfo(
              path: dir.path,
              name: 'Tarjeta SD',
              isSDCard: true,
              totalSpace: await _getTotalSpace(dir),
              freeSpace: await _getFreeSpace(dir),
            ));
          }
        }
      }
    } else {
      // Para iOS y otros, usar el directorio de documentos
      final dir = await getApplicationDocumentsDirectory();
      storagePaths.add(StorageInfo(
        path: dir.path,
        name: 'Documentos',
        isSDCard: false,
        totalSpace: await _getTotalSpace(dir),
        freeSpace: await _getFreeSpace(dir),
      ));
    }

    return storagePaths;
  }

  Future<String> getAppMusicPath() async {
    final basePath = _settings.downloadLocation;
    final musicPath = '$basePath/App Music';
    final directory = Directory(musicPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return musicPath;
  }

  Future<String> getAppVideoPath() async {
    final basePath = _settings.downloadLocation;
    final videoPath = '$basePath/App Video';
    final directory = Directory(videoPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return videoPath;
  }

  Future<bool> isPathWritable(String path) async {
    try {
      final testFile = File('$path/test_write');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> _getTotalSpace(Directory dir) async {
    try {
      final stat = await dir.statSync();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getFreeSpace(Directory dir) async {
    try {
      // En Android, podríamos usar platform channels para obtener el espacio real
      // Por ahora, retornamos un valor aproximado
      return 1024 * 1024 * 1024; // 1GB
    } catch (e) {
      return 0;
    }
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
}

class StorageInfo {
  final String path;
  final String name;
  final bool isSDCard;
  final int totalSpace;
  final int freeSpace;

  StorageInfo({
    required this.path,
    required this.name,
    required this.isSDCard,
    required this.totalSpace,
    required this.freeSpace,
  });
}
