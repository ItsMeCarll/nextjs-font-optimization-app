import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/video_info.dart';
import '../constants/app_constants.dart';

class ApiService {
  final Dio _dio;
  final String _baseUrl;

  ApiService({String? baseUrl})
      : _baseUrl = baseUrl ?? AppConstants.baseUrl,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? AppConstants.baseUrl,
          connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
          receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        ));

  Future<VideoInfo> getVideoInfo(String url) async {
    try {
      final response = await _dio.get(
        '${AppConstants.videoInfoEndpoint}',
        queryParameters: {'url': url},
      );

      if (response.statusCode == 200) {
        return VideoInfo.fromJson(response.data);
      } else {
        throw Exception('Error al obtener información del video');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<VideoInfo>> searchVideos(String query, {
    String? platform,
    String? category,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.searchEndpoint}',
        queryParameters: {
          'query': query,
          'platform': platform,
          'category': category,
          if (filters != null) ...filters,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => VideoInfo.fromJson(json)).toList();
      } else {
        throw Exception('Error en la búsqueda');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, String>> getSubtitles(String videoId, {String? language}) async {
    try {
      final response = await _dio.get(
        '${AppConstants.transcribeEndpoint}/$videoId',
        queryParameters: {
          if (language != null) 'language': language,
        },
      );

      if (response.statusCode == 200) {
        return Map<String, String>.from(response.data['subtitles']);
      } else {
        throw Exception('Error al obtener subtítulos');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<String> transcribeAudio(String videoId) async {
    try {
      final response = await _dio.post(
        '${AppConstants.transcribeEndpoint}/$videoId',
      );

      if (response.statusCode == 200) {
        return response.data['transcription'];
      } else {
        throw Exception('Error al transcribir audio');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> recognizeMusic(String audioData) async {
    try {
      final response = await _dio.post(
        '/recognize-music',
        data: {
          'audio_data': audioData,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al reconocer la música');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> processVoiceCommand(String command) async {
    try {
      final response = await _dio.post(
        '/voice-command',
        data: {
          'command': command,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al procesar comando de voz');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<bool> checkVpnStatus() async {
    try {
      final response = await _dio.get('/vpn/status');
      return response.data['connected'] ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> connectVpn() async {
    try {
      await _dio.post('/vpn/connect');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> disconnectVpn() async {
    try {
      await _dio.post('/vpn/disconnect');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tiempo de espera agotado. Por favor, verifica tu conexión.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Error desconocido';
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('La solicitud fue cancelada');
      default:
        return Exception('Error de conexión. Por favor, verifica tu conexión a internet.');
    }
  }

  // Método para agregar interceptores personalizados
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  // Método para configurar headers globales
  void setGlobalHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  // Método para limpiar la caché de la API
  Future<void> clearCache() async {
    // Implementar limpieza de caché si se usa
  }
}
