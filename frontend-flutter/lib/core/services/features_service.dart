import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:local_auth/local_auth.dart';
import '../models/app_settings.dart';
import 'api_service.dart';

class FeaturesService {
  final FlutterLocalNotificationsPlugin _notifications;
  final SpeechToText _speechToText;
  final LocalAuthentication _localAuth;
  final ApiService _apiService;
  final AppSettings _settings;

  bool _isListening = false;
  StreamController<String>? _voiceCommandController;

  FeaturesService(
    this._notifications,
    this._speechToText,
    this._localAuth,
    this._apiService,
    this._settings,
  ) {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Inicializar notificaciones
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notifications.initialize(initializationSettings);

    // Inicializar reconocimiento de voz
    await _speechToText.initialize();
  }

  // Notificaciones
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_settings.showNotifications) return;

    const androidDetails = AndroidNotificationDetails(
      'downloads_channel',
      'Downloads',
      channelDescription: 'Notificaciones de descargas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Comandos de voz
  Stream<String> get voiceCommandStream {
    _voiceCommandController ??= StreamController<String>.broadcast();
    return _voiceCommandController!.stream;
  }

  Future<void> startListening() async {
    if (!_settings.enableVoiceCommands || _isListening) return;

    _isListening = true;
    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _processVoiceCommand(result.recognizedWords);
          }
        },
      );
    } catch (e) {
      _isListening = false;
      rethrow;
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechToText.stop();
    _isListening = false;
  }

  Future<void> _processVoiceCommand(String command) async {
    try {
      final result = await _apiService.processVoiceCommand(command);
      _voiceCommandController?.add(command);
      
      // Procesar el resultado según el tipo de comando
      if (result['type'] == 'download') {
        // Iniciar descarga
        showNotification(
          title: 'Nuevo comando de voz',
          body: 'Iniciando descarga: ${result['title']}',
        );
      }
    } catch (e) {
      showNotification(
        title: 'Error',
        body: 'No se pudo procesar el comando de voz',
      );
    }
  }

  // Autenticación biométrica
  Future<bool> authenticateWithBiometrics() async {
    if (!_settings.useFingerprint) return true;

    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Por favor, autentícate para acceder al contenido privado',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Limpieza de recursos
  void dispose() {
    _voiceCommandController?.close();
    stopListening();
  }

  // Estado de los servicios
  bool get isListening => _isListening;
}
