import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  late SharedPreferences _prefs;
  
  // Tema
  bool _darkMode = false;
  String _accentColor = '#000000';
  double _fontSize = 14.0;

  // Descargas
  String _defaultVideoQuality = '720p';
  String _defaultAudioQuality = 'mp3_320';
  String _downloadLocation = '/storage/emulated/0/Download';
  bool _autoDownload = false;
  bool _downloadOverWifiOnly = true;
  int _maxConcurrentDownloads = 3;
  bool _createPlaylistFolder = true;

  // Privacidad y Seguridad
  bool _useVpn = false;
  bool _useFingerprint = false;
  String? _privatefolderPassword;
  bool _saveHistory = true;

  // Notificaciones
  bool _showNotifications = true;
  bool _notifyOnComplete = true;
  bool _notifyOnError = true;

  // Reproducción
  bool _enableFloatingWindow = true;
  bool _autoPlayNextVideo = true;
  bool _rememberPlaybackPosition = true;
  bool _enableBackgroundPlayback = true;

  // Características Avanzadas
  bool _enableVoiceCommands = true;
  bool _enableMusicRecognition = true;
  bool _enableAutoSubtitles = true;
  bool _enableLinkDetection = true;

  // Idioma y Región
  String _language = 'es';
  String _country = 'ES';

  AppSettings() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Cargar configuraciones guardadas
    _darkMode = _prefs.getBool('darkMode') ?? false;
    _accentColor = _prefs.getString('accentColor') ?? '#000000';
    _fontSize = _prefs.getDouble('fontSize') ?? 14.0;
    _defaultVideoQuality = _prefs.getString('defaultVideoQuality') ?? '720p';
    _defaultAudioQuality = _prefs.getString('defaultAudioQuality') ?? 'mp3_320';
    _downloadLocation = _prefs.getString('downloadLocation') ?? '/storage/emulated/0/Download';
    _autoDownload = _prefs.getBool('autoDownload') ?? false;
    _downloadOverWifiOnly = _prefs.getBool('downloadOverWifiOnly') ?? true;
    _maxConcurrentDownloads = _prefs.getInt('maxConcurrentDownloads') ?? 3;
    _createPlaylistFolder = _prefs.getBool('createPlaylistFolder') ?? true;
    _useVpn = _prefs.getBool('useVpn') ?? false;
    _useFingerprint = _prefs.getBool('useFingerprint') ?? false;
    _privatefolderPassword = _prefs.getString('privatefolderPassword');
    _saveHistory = _prefs.getBool('saveHistory') ?? true;
    _showNotifications = _prefs.getBool('showNotifications') ?? true;
    _notifyOnComplete = _prefs.getBool('notifyOnComplete') ?? true;
    _notifyOnError = _prefs.getBool('notifyOnError') ?? true;
    _enableFloatingWindow = _prefs.getBool('enableFloatingWindow') ?? true;
    _autoPlayNextVideo = _prefs.getBool('autoPlayNextVideo') ?? true;
    _rememberPlaybackPosition = _prefs.getBool('rememberPlaybackPosition') ?? true;
    _enableBackgroundPlayback = _prefs.getBool('enableBackgroundPlayback') ?? true;
    _enableVoiceCommands = _prefs.getBool('enableVoiceCommands') ?? true;
    _enableMusicRecognition = _prefs.getBool('enableMusicRecognition') ?? true;
    _enableAutoSubtitles = _prefs.getBool('enableAutoSubtitles') ?? true;
    _enableLinkDetection = _prefs.getBool('enableLinkDetection') ?? true;
    _language = _prefs.getString('language') ?? 'es';
    _country = _prefs.getString('country') ?? 'ES';
    
    notifyListeners();
  }

  // Getters
  bool get darkMode => _darkMode;
  String get accentColor => _accentColor;
  double get fontSize => _fontSize;
  String get defaultVideoQuality => _defaultVideoQuality;
  String get defaultAudioQuality => _defaultAudioQuality;
  String get downloadLocation => _downloadLocation;
  bool get autoDownload => _autoDownload;
  bool get downloadOverWifiOnly => _downloadOverWifiOnly;
  int get maxConcurrentDownloads => _maxConcurrentDownloads;
  bool get createPlaylistFolder => _createPlaylistFolder;
  bool get useVpn => _useVpn;
  bool get useFingerprint => _useFingerprint;
  String? get privatefolderPassword => _privatefolderPassword;
  bool get saveHistory => _saveHistory;
  bool get showNotifications => _showNotifications;
  bool get notifyOnComplete => _notifyOnComplete;
  bool get notifyOnError => _notifyOnError;
  bool get enableFloatingWindow => _enableFloatingWindow;
  bool get autoPlayNextVideo => _autoPlayNextVideo;
  bool get rememberPlaybackPosition => _rememberPlaybackPosition;
  bool get enableBackgroundPlayback => _enableBackgroundPlayback;
  bool get enableVoiceCommands => _enableVoiceCommands;
  bool get enableMusicRecognition => _enableMusicRecognition;
  bool get enableAutoSubtitles => _enableAutoSubtitles;
  bool get enableLinkDetection => _enableLinkDetection;
  String get language => _language;
  String get country => _country;

  // Setters con persistencia
  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setAccentColor(String value) async {
    _accentColor = value;
    await _prefs.setString('accentColor', value);
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    _fontSize = value;
    await _prefs.setDouble('fontSize', value);
    notifyListeners();
  }

  Future<void> setDefaultVideoQuality(String value) async {
    _defaultVideoQuality = value;
    await _prefs.setString('defaultVideoQuality', value);
    notifyListeners();
  }

  Future<void> setDefaultAudioQuality(String value) async {
    _defaultAudioQuality = value;
    await _prefs.setString('defaultAudioQuality', value);
    notifyListeners();
  }

  Future<void> setDownloadLocation(String value) async {
    _downloadLocation = value;
    await _prefs.setString('downloadLocation', value);
    notifyListeners();
  }

  Future<void> setAutoDownload(bool value) async {
    _autoDownload = value;
    await _prefs.setBool('autoDownload', value);
    notifyListeners();
  }

  Future<void> setDownloadOverWifiOnly(bool value) async {
    _downloadOverWifiOnly = value;
    await _prefs.setBool('downloadOverWifiOnly', value);
    notifyListeners();
  }

  Future<void> setMaxConcurrentDownloads(int value) async {
    _maxConcurrentDownloads = value;
    await _prefs.setInt('maxConcurrentDownloads', value);
    notifyListeners();
  }

  Future<void> setCreatePlaylistFolder(bool value) async {
    _createPlaylistFolder = value;
    await _prefs.setBool('createPlaylistFolder', value);
    notifyListeners();
  }

  Future<void> setUseVpn(bool value) async {
    _useVpn = value;
    await _prefs.setBool('useVpn', value);
    notifyListeners();
  }

  Future<void> setUseFingerprint(bool value) async {
    _useFingerprint = value;
    await _prefs.setBool('useFingerprint', value);
    notifyListeners();
  }

  Future<void> setPrivatefolderPassword(String? value) async {
    _privatefolderPassword = value;
    if (value != null) {
      await _prefs.setString('privatefolderPassword', value);
    } else {
      await _prefs.remove('privatefolderPassword');
    }
    notifyListeners();
  }

  Future<void> setSaveHistory(bool value) async {
    _saveHistory = value;
    await _prefs.setBool('saveHistory', value);
    notifyListeners();
  }

  // Métodos de utilidad
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Locale get locale => Locale(_language, _country);

  Map<String, dynamic> toJson() {
    return {
      'darkMode': _darkMode,
      'accentColor': _accentColor,
      'fontSize': _fontSize,
      'defaultVideoQuality': _defaultVideoQuality,
      'defaultAudioQuality': _defaultAudioQuality,
      'downloadLocation': _downloadLocation,
      'autoDownload': _autoDownload,
      'downloadOverWifiOnly': _downloadOverWifiOnly,
      'maxConcurrentDownloads': _maxConcurrentDownloads,
      'createPlaylistFolder': _createPlaylistFolder,
      'useVpn': _useVpn,
      'useFingerprint': _useFingerprint,
      'saveHistory': _saveHistory,
      'showNotifications': _showNotifications,
      'notifyOnComplete': _notifyOnComplete,
      'notifyOnError': _notifyOnError,
      'enableFloatingWindow': _enableFloatingWindow,
      'autoPlayNextVideo': _autoPlayNextVideo,
      'rememberPlaybackPosition': _rememberPlaybackPosition,
      'enableBackgroundPlayback': _enableBackgroundPlayback,
      'enableVoiceCommands': _enableVoiceCommands,
      'enableMusicRecognition': _enableMusicRecognition,
      'enableAutoSubtitles': _enableAutoSubtitles,
      'enableLinkDetection': _enableLinkDetection,
      'language': _language,
      'country': _country,
    };
  }
}
