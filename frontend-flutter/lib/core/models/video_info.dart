class VideoInfo {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String duration;
  final String author;
  final String platform;
  final List<VideoQuality> qualities;
  final List<AudioFormat> audioFormats;
  final bool hasSubtitles;
  final Map<String, dynamic>? metadata;

  VideoInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.duration,
    required this.author,
    required this.platform,
    required this.qualities,
    required this.audioFormats,
    this.hasSubtitles = false,
    this.metadata,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String,
      duration: json['duration'] as String,
      author: json['author'] as String,
      platform: json['platform'] as String,
      qualities: (json['qualities'] as List)
          .map((q) => VideoQuality.fromJson(q))
          .toList(),
      audioFormats: (json['audio_formats'] as List)
          .map((a) => AudioFormat.fromJson(a))
          .toList(),
      hasSubtitles: json['has_subtitles'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'duration': duration,
      'author': author,
      'platform': platform,
      'qualities': qualities.map((q) => q.toJson()).toList(),
      'audio_formats': audioFormats.map((a) => a.toJson()).toList(),
      'has_subtitles': hasSubtitles,
      'metadata': metadata,
    };
  }
}

class VideoQuality {
  final String label;
  final String url;
  final String format;
  final int width;
  final int height;
  final int filesize;

  VideoQuality({
    required this.label,
    required this.url,
    required this.format,
    required this.width,
    required this.height,
    required this.filesize,
  });

  factory VideoQuality.fromJson(Map<String, dynamic> json) {
    return VideoQuality(
      label: json['label'] as String,
      url: json['url'] as String,
      format: json['format'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      filesize: json['filesize'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'url': url,
      'format': format,
      'width': width,
      'height': height,
      'filesize': filesize,
    };
  }
}

class AudioFormat {
  final String label;
  final String url;
  final String format;
  final int bitrate;
  final int filesize;

  AudioFormat({
    required this.label,
    required this.url,
    required this.format,
    required this.bitrate,
    required this.filesize,
  });

  factory AudioFormat.fromJson(Map<String, dynamic> json) {
    return AudioFormat(
      label: json['label'] as String,
      url: json['url'] as String,
      format: json['format'] as String,
      bitrate: json['bitrate'] as int,
      filesize: json['filesize'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'url': url,
      'format': format,
      'bitrate': bitrate,
      'filesize': filesize,
    };
  }
}
