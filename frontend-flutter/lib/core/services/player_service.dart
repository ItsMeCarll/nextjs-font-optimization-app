import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/app_settings.dart';

enum MediaType { video, audio }

class PlayerService {
  final AppSettings _settings;
  
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  VlcPlayerController? _vlcController;
  
  bool _isFloatingMode = false;
  bool _isBackgroundPlayback = false;
  
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<PlayerState> _stateController = StreamController<PlayerState>.broadcast();
  
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<PlayerState> get stateStream => _stateController.stream;
  
  PlayerService(this._settings) {
    _initAudioService();
  }

  Future<void> _initAudioService() async {
    await AudioService.init(
      builder: () => AudioPlayerHandler(_audioPlayer ?? AudioPlayer()),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.videodownloader.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );
  }

  Future<void> playMedia(String path, MediaType type) async {
    if (type == MediaType.video) {
      await _playVideo(path);
    } else {
      await _playAudio(path);
    }
  }

  Future<void> _playVideo(String path) async {
    // Liberar recursos anteriores
    await _disposeCurrentControllers();

    if (_isFloatingMode) {
      _vlcController = VlcPlayerController.file(
        path,
        hwAcc: HwAcc.full,
        options: VlcPlayerOptions(),
      );
      await _vlcController?.initialize();
      await _vlcController?.play();
    } else {
      _videoController = VideoPlayerController.file(File(path));
      await _videoController?.initialize();
      await _videoController?.play();
    }

    _startPositionTracking();
  }

  Future<void> _playAudio(String path) async {
    await _disposeCurrentControllers();
    
    _audioPlayer = AudioPlayer();
    await _audioPlayer?.setFilePath(path);
    await _audioPlayer?.play();

    if (_settings.enableBackgroundPlayback) {
      _enableBackgroundPlayback();
    }

    _startPositionTracking();
  }

  void _startPositionTracking() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_videoController?.value.isPlaying ?? false) {
        _positionController.add(_videoController!.value.position);
      } else if (_audioPlayer?.playing ?? false) {
        _positionController.add(_audioPlayer!.position);
      } else if (_vlcController?.value.isPlaying ?? false) {
        _positionController.add(_vlcController!.value.position);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> togglePlayPause() async {
    if (_videoController != null) {
      if (_videoController!.value.isPlaying) {
        await _videoController!.pause();
      } else {
        await _videoController!.play();
      }
    } else if (_audioPlayer != null) {
      if (_audioPlayer!.playing) {
        await _audioPlayer!.pause();
      } else {
        await _audioPlayer!.play();
      }
    } else if (_vlcController != null) {
      if (_vlcController!.value.isPlaying) {
        await _vlcController!.pause();
      } else {
        await _vlcController!.play();
      }
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_videoController != null) {
      await _videoController!.seekTo(position);
    } else if (_audioPlayer != null) {
      await _audioPlayer!.seek(position);
    } else if (_vlcController != null) {
      await _vlcController!.seekTo(position);
    }
  }

  Future<void> toggleFloatingMode() async {
    _isFloatingMode = !_isFloatingMode;
    if (_videoController != null) {
      final position = _videoController!.value.position;
      final path = (_videoController!.dataSource as String);
      await _playVideo(path);
      await seekTo(position);
    }
  }

  void _enableBackgroundPlayback() {
    _isBackgroundPlayback = true;
    // Configurar notificación de reproducción en segundo plano
    AudioServiceBackground.setState(
      controls: [
        MediaControl.pause,
        MediaControl.play,
        MediaControl.stop,
      ],
      processingState: AudioProcessingState.ready,
      playing: true,
    );
  }

  Future<void> _disposeCurrentControllers() async {
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
    if (_audioPlayer != null) {
      await _audioPlayer!.dispose();
      _audioPlayer = null;
    }
    if (_vlcController != null) {
      await _vlcController!.dispose();
      _vlcController = null;
    }
  }

  // Getters para el estado actual
  bool get isPlaying {
    return _videoController?.value.isPlaying ?? 
           _audioPlayer?.playing ?? 
           _vlcController?.value.isPlaying ?? 
           false;
  }

  Duration? get duration {
    return _videoController?.value.duration ?? 
           _audioPlayer?.duration ??
           _vlcController?.value.duration;
  }

  Duration? get position {
    return _videoController?.value.position ?? 
           _audioPlayer?.position ??
           _vlcController?.value.position;
  }

  bool get isFloatingMode => _isFloatingMode;
  bool get isBackgroundPlayback => _isBackgroundPlayback;

  // Limpieza de recursos
  void dispose() {
    _disposeCurrentControllers();
    _positionController.close();
    _stateController.close();
  }
}

class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player;

  AudioPlayerHandler(this._player) {
    _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
  }

  void _broadcastState() {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.pause,
        MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);
}
