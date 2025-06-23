import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/download_task.dart';
import '../models/app_settings.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  final AppSettings _settings;
  
  StorageService(this._secureStorage, this._settings);

  // Directorios principales
  Future<String> get _baseDir async {
    if (Platform.isAndroid) {
      return _settings.downloadLocation;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
  }

  Future<Directory> get videosDirectory async =>
      Directory('${await _baseDir}/videos');

  Future<Directory> get audioDirectory async =>
      Directory('${await _baseDir}/audio');

  Future<Directory> get playlistsDirectory async =>
      Directory('${await _baseDir}/playlists');

  Future<Directory> get privateDirectory async =>
      Directory('${await _baseDir}/private');

  // Inicialización y permisos
  Future<void> initializeStorage() async {
    final dirs = [
      await videosDirectory,
      await audioDirectory,
      await playlistsDirectory,
      await privateDirectory,
    ];

    for (var dir in dirs) {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }

    // Crear archivo .nomedia en Android para ocultar medios
    if (Platform.isAndroid) {
      final nomediaFile = File('${await privateDirectory.path}/.nomedia');
      if (!await nomediaFile.exists()) {
        await nomediaFile.create();
      }
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  // Gestión de archivos privados
  Future<bool> moveToPrivate(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final fileName = file.path.split('/').last;
      final newPath = '${await privateDirectory.path}/$fileName';
      await file.rename(newPath);

      // Registrar en el índice de archivos privados
      await _addToPrivateIndex(fileName, newPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> moveFromPrivate(String fileName) async {
    try {
      final privatePath = '${await privateDirectory.path}/$fileName';
      final file = File(privatePath);
      if (!await file.exists()) return false;

      final isVideo = fileName.endsWith('.mp4') || fileName.endsWith('.mkv');
      final targetDir = isVideo ? await videosDirectory : await audioDirectory;
      final newPath = '${targetDir.path}/$fileName';
      
      await file.rename(newPath);
      await _removeFromPrivateIndex(fileName);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _addToPrivateIndex(String fileName, String path) async {
    final index = await _loadPrivateIndex();
    index[fileName] = path;
    await _savePrivateIndex(index);
  }

  Future<void> _removeFromPrivateIndex(String fileName) async {
    final index = await _loadPrivateIndex();
    index.remove(fileName);
    await _savePrivateIndex(index);
  }

  Future<Map<String, String>> _loadPrivateIndex() async {
    try {
      final indexJson = await _secureStorage.read(key: 'private_index');
      if (indexJson == null) return {};
      return Map<String, String>.from(json.decode(indexJson));
    } catch (e) {
      return {};
    }
  }

  Future<void> _savePrivateIndex(Map<String, String> index) async {
    await _secureStorage.write(
      key: 'private_index',
      value: json.encode(index),
    );
  }

  // Gestión de listas de reproducción
  Future<void> createPlaylist(String name, List<String> filePaths) async {
    final playlistDir = await playlistsDirectory;
    final playlistPath = '${playlistDir.path}/$name.m3u';
    final file = File(playlistPath);

    final content = StringBuffer('#EXTM3U\n');
    for (var path in filePaths) {
      content.writeln('#EXTINF:-1,${path.split('/').last}');
      content.writeln(path);
    }

    await file.writeAsString(content.toString());
  }

  Future<List<String>> getPlaylistFiles(String playlistName) async {
    final playlistDir = await playlistsDirectory;
    final playlistPath = '${playlistDir.path}/$playlistName.m3u';
    final file = File(playlistPath);

    if (!await file.exists()) return [];

    final content = await file.readAsLines();
    return content
        .where((line) => !line.startsWith('#'))
        .where((line) => line.isNotEmpty)
        .toList();
  }

  // Gestión de espacio y limpieza
  Future<Map<String, int>> getStorageStats() async {
    final stats = <String, int>{};
    
    final dirs = {
      'videos': await videosDirectory,
      'audio': await audioDirectory,
      'playlists': await playlistsDirectory,
      'private': await privateDirectory,
    };

    for (var entry in dirs.entries) {
      stats[entry.key] = await _calculateDirSize(entry.value);
    }

    return stats;
  }

  Future<int> _calculateDirSize(Directory dir) async {
    int size = 0;
    try {
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      // Ignorar errores
    }
    return size;
  }

  Future<void> clearDirectory(Directory dir) async {
    if (await dir.exists()) {
      await for (var entity in dir.list(recursive: true)) {
        await entity.delete();
      }
    }
  }

  // Búsqueda y filtrado
  Future<List<FileSystemEntity>> searchFiles(String query) async {
    final results = <FileSystemEntity>[];
    final dirs = [
      await videosDirectory,
      await audioDirectory,
      await playlistsDirectory,
    ];

    for (var dir in dirs) {
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File) {
          final fileName = entity.path.split('/').last.toLowerCase();
          if (fileName.contains(query.toLowerCase())) {
            results.add(entity);
          }
        }
      }
    }

    return results;
  }

  // Utilidades
  String getFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  String getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'mp4':
      case 'mkv':
      case 'avi':
        return 'video/$ext';
      case 'mp3':
      case 'm4a':
      case 'wav':
        return 'audio/$ext';
      default:
        return 'application/octet-stream';
    }
  }
}
