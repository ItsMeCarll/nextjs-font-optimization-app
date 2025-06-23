import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_acr/flutter_acr.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

import '../models/app_settings.dart';
import '../models/video_info.dart';
import '../models/download_task.dart';
import 'api_service.dart';
import 'download_service.dart';
import 'features_service.dart';
import 'storage_service.dart';
import 'player_service.dart';
import 'storage_path_service.dart';
import 'auth_service.dart';

class AppService extends ChangeNotifier {
  // Servicios
  late final ApiService _apiService;
  late final DownloadService _downloadService;
  late final FeaturesService _featuresService;
  late final StorageService _storageService;
  late final PlayerService _playerService;
  late final StoragePathService _storagePathService;
  late final AuthService _authService;
  late final AppSettings _settings;

  // Estado
  bool _isLoading = false;
  String? _error;
  List<DownloadTask> _downloads = [];
  List<VideoInfo> _recentVideos = [];
  VideoInfo? _currentVideo;
  bool _isVpnActive = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DownloadTask> get downloads => _downloads;
  List<VideoInfo> get recentVideos => _recentVideos;
  VideoInfo? get currentVideo => _currentVideo;
  bool get isVpnActive => _isVpnActive;
  AppSettings get settings => _settings;
  StoragePathService get storagePathService => _storagePathService;
  AuthService get authService => _authService;
  bool get isAuthenticated => _authService.isAuthenticated;

  // Streams
  Stream<DownloadTask> get downloadStream => _downloadService.downloadStream;
  Stream<String> get voiceCommandStream => _featuresService.voiceCommandStream;
  Stream<Map<String, dynamic>> get musicRecognitionStream => 
      _featuresService.musicRecognitionStream;

  AppService() {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _setLoading(true);

      // Inicializar servicios
      _settings = AppSettings();

      _apiService = ApiService();
      
      _downloadService = DownloadService(
        Dio(),
        FlutterFFmpeg(),
        _settings,
      );

      _featuresService = FeaturesService(
        FlutterLocalNotificationsPlugin(),
        SpeechToText(),
        FlutterAcr(),
        LocalAuthentication(),
        _apiService,
        _settings,
      );

      _storagePathService = StoragePathService(_settings);
      
      _storageService = StorageService(
        const FlutterSecureStorage(),
        _settings,
        _storagePathService,
      );

      _playerService = PlayerService(_settings);
      _authService = AuthService();

      // Inicializar servicios
      await _storageService.initializeStorage();
      await Firebase.initializeApp();

      // Cargar datos iniciales
      await _loadInitialData();

      // Suscribirse a eventos
      _setupEventListeners();

    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadInitialData() async {
    // Cargar descargas activas
    _downloads = _downloadService.getActiveTasks();

    // Verificar estado de VPN
    _isVpnActive = await _apiService.checkVpnStatus();

    notifyListeners();
  }

  void _setupEventListeners() {
    // Escuchar eventos de descarga
    _downloadService.downloadStream.listen((task) {
      final index = _downloads.indexWhere((t) => t.id == task.id);
      if (index >= 0) {
        _downloads[index] = task;
      } else {
        _downloads.add(task);
      }
      notifyListeners();
    });
  }

  // Métodos de autenticación
  Future<bool> requireAuthentication(String platform) async {
    if (!_authService.hasPlatformAccess(platform)) {
      // Mostrar pantalla de autenticación si no tiene acceso
      return false;
    }
    return true;
  }

  Future<String?> getPlatformToken(String platform) async {
    return _authService.getPlatformToken(platform);
  }

  // Métodos para gestionar descargas
  Future<void> downloadVideo(String url, {
    required String quality,
    required String format,
    bool extractAudio = false,
  }) async {
    try {
      _setLoading(true);
      
      // Obtener información del video
      final videoInfo = await _apiService.getVideoInfo(url);
      _currentVideo = videoInfo;

      // Iniciar descarga
      final task = await _downloadService.startDownload(
        videoInfo: videoInfo,
        type: extractAudio ? DownloadType.audio : DownloadType.video,
        quality: quality,
        format: format,
      );

      // Agregar a recientes
      _addToRecent(videoInfo);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void pauseDownload(String taskId) {
    _downloadService.pauseDownload(taskId);
    notifyListeners();
  }

  void resumeDownload(String taskId) {
    _downloadService.resumeDownload(taskId);
    notifyListeners();
  }

  void cancelDownload(String taskId) {
    _downloadService.cancelDownload(taskId);
    _downloads.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  // Métodos para gestionar VPN
  Future<void> toggleVpn() async {
    try {
      _setLoading(true);
      if (_isVpnActive) {
        await _apiService.disconnectVpn();
      } else {
        await _apiService.connectVpn();
      }
      _isVpnActive = await _apiService.checkVpnStatus();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Métodos para gestionar características avanzadas
  Future<void> startVoiceCommand() async {
    await _featuresService.startListening();
  }

  Future<void> stopVoiceCommand() async {
    await _featuresService.stopListening();
  }

  Future<void> startMusicRecognition() async {
    await _featuresService.startMusicRecognition();
  }

  Future<void> stopMusicRecognition() async {
    await _featuresService.stopMusicRecognition();
  }

  // Métodos para gestionar archivos
  Future<void> moveToPrivate(String filePath) async {
    final success = await _storageService.moveToPrivate(filePath);
    if (!success) {
      _setError('No se pudo mover el archivo a la carpeta privada');
    }
    notifyListeners();
  }

  Future<void> moveFromPrivate(String fileName) async {
    final success = await _storageService.moveFromPrivate(fileName);
    if (!success) {
      _setError('No se pudo mover el archivo desde la carpeta privada');
    }
    notifyListeners();
  }

  // Métodos para reproducción de medios
  Future<void> playMedia(String path, MediaType type) async {
    await _playerService.playMedia(path, type);
  }

  Future<void> toggleFloatingMode() async {
    await _playerService.toggleFloatingMode();
    notifyListeners();
  }

  // Métodos de utilidad
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _addToRecent(VideoInfo video) {
    if (!_recentVideos.contains(video)) {
      _recentVideos.insert(0, video);
      if (_recentVideos.length > 10) {
        _recentVideos.removeLast();
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Limpieza de recursos
  @override
  void dispose() {
    _downloadService.dispose();
    _featuresService.dispose();
    _playerService.dispose();
    super.dispose();
  }
}
