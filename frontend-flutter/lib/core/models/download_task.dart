import 'package:flutter/foundation.dart';
import 'video_info.dart';

enum DownloadStatus {
  queued,
  downloading,
  paused,
  completed,
  failed,
  cancelled
}

enum DownloadType {
  video,
  audio,
  subtitle
}

class DownloadTask with ChangeNotifier {
  final String id;
  final VideoInfo videoInfo;
  final DownloadType type;
  final String outputPath;
  final String selectedQuality;
  final String selectedFormat;
  DownloadStatus _status;
  double _progress;
  String? _error;
  DateTime startTime;
  DateTime? endTime;
  double _downloadSpeed;
  int _bytesDownloaded;
  final int totalBytes;
  bool _isPrivate;

  DownloadTask({
    required this.id,
    required this.videoInfo,
    required this.type,
    required this.outputPath,
    required this.selectedQuality,
    required this.selectedFormat,
    required this.totalBytes,
    DownloadStatus status = DownloadStatus.queued,
    double progress = 0.0,
    String? error,
    double downloadSpeed = 0.0,
    int bytesDownloaded = 0,
    bool isPrivate = false,
  })  : _status = status,
        _progress = progress,
        _error = error,
        startTime = DateTime.now(),
        _downloadSpeed = downloadSpeed,
        _bytesDownloaded = bytesDownloaded,
        _isPrivate = isPrivate;

  DownloadStatus get status => _status;
  double get progress => _progress;
  String? get error => _error;
  double get downloadSpeed => _downloadSpeed;
  int get bytesDownloaded => _bytesDownloaded;
  bool get isPrivate => _isPrivate;

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  String get remainingTime {
    if (_downloadSpeed <= 0) return '--:--';
    final remainingBytes = totalBytes - _bytesDownloaded;
    final seconds = remainingBytes / (_downloadSpeed * 1024 * 1024);
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void updateProgress(double newProgress, int newBytesDownloaded) {
    _progress = newProgress;
    _bytesDownloaded = newBytesDownloaded;
    
    // Calculate download speed
    final now = DateTime.now();
    final duration = now.difference(startTime).inSeconds;
    if (duration > 0) {
      _downloadSpeed = _bytesDownloaded / (duration * 1024 * 1024); // MB/s
    }
    
    notifyListeners();
  }

  void updateStatus(DownloadStatus newStatus) {
    _status = newStatus;
    if (newStatus == DownloadStatus.completed || 
        newStatus == DownloadStatus.failed ||
        newStatus == DownloadStatus.cancelled) {
      endTime = DateTime.now();
    }
    notifyListeners();
  }

  void setError(String errorMessage) {
    _error = errorMessage;
    _status = DownloadStatus.failed;
    endTime = DateTime.now();
    notifyListeners();
  }

  void togglePrivate() {
    _isPrivate = !_isPrivate;
    notifyListeners();
  }

  void pause() {
    if (_status == DownloadStatus.downloading) {
      _status = DownloadStatus.paused;
      notifyListeners();
    }
  }

  void resume() {
    if (_status == DownloadStatus.paused) {
      _status = DownloadStatus.downloading;
      notifyListeners();
    }
  }

  void cancel() {
    _status = DownloadStatus.cancelled;
    endTime = DateTime.now();
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoInfo': videoInfo.toJson(),
      'type': type.toString(),
      'outputPath': outputPath,
      'selectedQuality': selectedQuality,
      'selectedFormat': selectedFormat,
      'status': _status.toString(),
      'progress': _progress,
      'error': _error,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'downloadSpeed': _downloadSpeed,
      'bytesDownloaded': _bytesDownloaded,
      'totalBytes': totalBytes,
      'isPrivate': _isPrivate,
    };
  }

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    return DownloadTask(
      id: json['id'] as String,
      videoInfo: VideoInfo.fromJson(json['videoInfo']),
      type: DownloadType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      outputPath: json['outputPath'] as String,
      selectedQuality: json['selectedQuality'] as String,
      selectedFormat: json['selectedFormat'] as String,
      status: DownloadStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      progress: json['progress'] as double,
      error: json['error'] as String?,
      downloadSpeed: json['downloadSpeed'] as double,
      bytesDownloaded: json['bytesDownloaded'] as int,
      totalBytes: json['totalBytes'] as int,
      isPrivate: json['isPrivate'] as bool,
    );
  }
}
