class AppConstants {
  static const String appName = 'Video Downloader Pro';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String baseUrl = 'http://localhost:8000';
  static const String videoInfoEndpoint = '/video_info';
  static const String downloadEndpoint = '/download';
  static const String searchEndpoint = '/search';
  static const String transcribeEndpoint = '/transcribe';

  // Supported Platforms
  static const List<Map<String, dynamic>> supportedPlatforms = [
    {
      'name': 'YouTube',
      'icon': 'youtube',
      'color': 0xFFFF0000,
      'baseUrl': 'https://youtube.com'
    },
    {
      'name': 'Facebook',
      'icon': 'facebook',
      'color': 0xFF1877F2,
      'baseUrl': 'https://facebook.com'
    },
    {
      'name': 'Instagram',
      'icon': 'instagram',
      'color': 0xFFE4405F,
      'baseUrl': 'https://instagram.com'
    },
    {
      'name': 'TikTok',
      'icon': 'tiktok',
      'color': 0xFF000000,
      'baseUrl': 'https://tiktok.com'
    },
    {
      'name': 'Twitter',
      'icon': 'twitter',
      'color': 0xFF1DA1F2,
      'baseUrl': 'https://twitter.com'
    },
  ];

  // Download Quality Options
  static const List<Map<String, String>> videoQualities = [
    {'label': '4K', 'value': '2160p'},
    {'label': 'Full HD', 'value': '1080p'},
    {'label': 'HD', 'value': '720p'},
    {'label': 'SD', 'value': '480p'},
    {'label': 'Low', 'value': '360p'},
    {'label': 'Very Low', 'value': '240p'},
  ];

  // Audio Formats
  static const List<Map<String, String>> audioFormats = [
    {'label': 'High Quality MP3', 'value': 'mp3_320'},
    {'label': 'Medium Quality MP3', 'value': 'mp3_192'},
    {'label': 'Low Quality MP3', 'value': 'mp3_128'},
    {'label': 'M4A', 'value': 'm4a'},
  ];

  // Video Formats
  static const List<Map<String, String>> videoFormats = [
    {'label': 'MP4', 'value': 'mp4'},
    {'label': 'MKV', 'value': 'mkv'},
    {'label': 'WebM', 'value': 'webm'},
    {'label': 'AVI', 'value': 'avi'},
  ];

  // Storage Paths
  static const String downloadPath = 'downloads';
  static const String videoPath = 'downloads/videos';
  static const String audioPath = 'downloads/audio';
  static const String playlistPath = 'downloads/playlists';
  static const String privatePath = 'downloads/private';

  // Theme
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultIconSize = 24.0;
  static const double defaultElevation = 2.0;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Cache
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB
  static const int maxCacheAge = 7 * 24 * 60 * 60; // 7 days

  // Features
  static const bool enableVpn = true;
  static const bool enableVoiceCommands = true;
  static const bool enableMusicRecognition = true;
  static const bool enableFloatingWindow = true;
  static const bool enableBackgroundDownload = true;
  static const bool enableAutoSubtitles = true;
}
