import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/download_task.dart';
import '../models/video_info.dart';
import '../models/app_settings.dart';

class DownloadService {
  final Dio _dio;
  final FlutterFFmpeg _ffmpeg;
  final AppSettings _settings;
  final Map<String, DownloadTask> _activeTasks = {};
  final StreamController<DownloadTask> _downloadController = StreamController<DownloadTask>.broadcast();

  Stream<DownloadTask> get downloadStream => _downloadController.stream;

  DownloadService(this._dio, this._ffmpeg, this._settings);

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<String> getDownloadPath() async {
    if (Platform.isAndroid) {
      return _settings.downloadLocation;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<DownloadTask> startDownload({
    required VideoInfo videoInfo,
    required DownloadType type,
    required String quality,
    required String format,
  }) async {
    // Verificar permisos
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('No se tienen permisos de almacenamiento');
    }

    // Crear tarea de descarga
    final task = DownloadTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoInfo: videoInfo,
      type: type,
      outputPath: await _getOutputPath(videoInfo, type, format),
      selectedQuality: quality,
      selectedFormat: format,
      totalBytes: _calculateTotalBytes(videoInfo, quality, type),
    );

    // Agregar a tareas activas
    _activeTasks[task.id] = task;
    _downloadController.add(task);

    // Iniciar descarga
    try {
      if (type == DownloadType.video) {
        await _downloadVideo(task);
      } else if (type == DownloadType.audio) {
        await _downloadAudio(task);
      } else {
        await _downloadSubtitles(task);
      }
    } catch (e) {
      task.setError(e.toString());
      _downloadController.add(task);
    }

    return task;
  }

  Future<void> _downloadVideo(DownloadTask task) async {
    final url = _getDownloadUrl(task);
    final tempPath = await _getTempPath(task);
    
    try {
      await _dio.download(
        url,
        tempPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            task.updateProgress(progress, received);
            _downloadController.add(task);
          }
        },
      );

      // Convertir formato si es necesario
      if (task.selectedFormat != 'mp4') {
        await _convertFormat(tempPath, task.outputPath, task.selectedFormat);
        await File(tempPath).delete();
      } else {
        await File(tempPath).rename(task.outputPath);
      }

      task.updateStatus(DownloadStatus.completed);
      _downloadController.add(task);
    } catch (e) {
      task.setError(e.toString());
      _downloadController.add(task);
      await File(tempPath).delete().catchError((_) {});
    }
  }

  Future<void> _downloadAudio(DownloadTask task) async {
    final url = _getDownloadUrl(task);
    final tempPath = await _getTempPath(task);
    
    try {
      await _dio.download(
        url,
        tempPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            task.updateProgress(progress, received);
            _downloadController.add(task);
          }
        },
      );

      // Extraer audio
      await _extractAudio(tempPath, task.outputPath, task.selectedFormat);
      await File(tempPath).delete();

      task.updateStatus(DownloadStatus.completed);
      _downloadController.add(task);
    } catch (e) {
      task.setError(e.toString());
      _downloadController.add(task);
      await File(tempPath).delete().catchError((_) {});
    }
  }

  Future<void> _downloadSubtitles(DownloadTask task) async {
    final url = _getDownloadUrl(task);
    
    try {
      await _dio.download(
        url,
        task.outputPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            task.updateProgress(progress, received);
            _downloadController.add(task);
          }
        },
      );

      task.updateStatus(DownloadStatus.completed);
      _downloadController.add(task);
    } catch (e) {
      task.setError(e.toString());
      _downloadController.add(task);
    }
  }

  Future<void> _convertFormat(String inputPath, String outputPath, String format) async {
    final arguments = ['-i', inputPath, outputPath];
    final result = await _ffmpeg.executeWithArguments(arguments);
    
    if (result != 0) {
      throw Exception('Error al convertir el formato del video');
    }
  }

  Future<void> _extractAudio(String inputPath, String outputPath, String format) async {
    final arguments = ['-i', inputPath, '-vn', '-acodec', 'libmp3lame', outputPath];
    final result = await _ffmpeg.executeWithArguments(arguments);
    
    if (result != 0) {
      throw Exception('Error al extraer el audio');
    }
  }

  Future<String> _getOutputPath(VideoInfo info, DownloadType type, String format) async {
    final basePath = await getDownloadPath();
    final fileName = _sanitizeFileName('${info.title}.${format.toLowerCase()}');
    
    String subPath = '';
    switch (type) {
      case DownloadType.video:
        subPath = 'videos';
        break;
      case DownloadType.audio:
        subPath = 'audio';
        break;
      case DownloadType.subtitle:
        subPath = 'subtitles';
        break;
    }

    final directory = Directory('$basePath/$subPath');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return '${directory.path}/$fileName';
  }

  Future<String> _getTempPath(DownloadTask task) async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/${task.id}_temp';
  }

  String _getDownloadUrl(DownloadTask task) {
    if (task.type == DownloadType.video) {
      final quality = task.videoInfo.qualities.firstWhere(
        (q) => q.label == task.selectedQuality,
      );
      return quality.url;
    } else if (task.type == DownloadType.audio) {
      final format = task.videoInfo.audioFormats.firstWhere(
        (f) => f.label == task.selectedQuality,
      );
      return format.url;
    } else {
      // URL para subtítulos
      return '${task.videoInfo.id}/subtitles';
    }
  }

  int _calculateTotalBytes(VideoInfo info, String quality, DownloadType type) {
    if (type == DownloadType.video) {
      final videoQuality = info.qualities.firstWhere(
        (q) => q.label == quality,
        orElse: () => info.qualities.first,
      );
      return videoQuality.filesize;
    } else if (type == DownloadType.audio) {
      final audioFormat = info.audioFormats.firstWhere(
        (f) => f.label == quality,
        orElse: () => info.audioFormats.first,
      );
      return audioFormat.filesize;
    }
    return 0;
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  void pauseDownload(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null) {
      task.pause();
      _downloadController.add(task);
    }
  }

  void resumeDownload(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null) {
      task.resume();
      _downloadController.add(task);
    }
  }

  void cancelDownload(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null) {
      task.cancel();
      _downloadController.add(task);
      _activeTasks.remove(taskId);
    }
  }

  List<DownloadTask> getActiveTasks() {
    return _activeTasks.values.toList();
  }

  void dispose() {
    _downloadController.close();
  }
}
