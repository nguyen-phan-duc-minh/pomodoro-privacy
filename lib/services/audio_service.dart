import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  bool _isEnabled = true;
  Timer? _fadeTimer;
  double _currentVolume = 0.3;
  bool _isPlaying = false;

  final List<String> _backgroundTracks = [
    'audio/breezy-escape-chill-background-music-271240.mp3',
    'audio/calming-rain-audio.mp3',
    'audio/chill-lofi-beat-349110.mp3',
    'audio/christmas-lofi-background-chill-beat-439850.mp3',
    'audio/days-of-serenity-chill-background-music-271259.mp3',
    'audio/lofi-chill-372954.mp3',
    'audio/morning-coffee-aroma-271256.mp3',
    'audio/peace-in-every-note-chill-background-music-271253.mp3',
  ];

  bool get isEnabled => _isEnabled;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    }
  }

  Future<void> _playTingWithVibration() async {
    try {
      await _effectPlayer.play(
        AssetSource('audio/ting_audio.mp3'),
        volume: 1.0,
        mode: PlayerMode.lowLatency,
      );

      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 500, amplitude: 255);
        }
      } catch (e) {}
    } catch (e) {}
  }

  Future<void> playStudyStart() async {
    if (!_isEnabled) return;
    await _playTingWithVibration();
    await playBackgroundMusic();
  }

  Future<void> playStudyComplete() async {
    if (!_isEnabled) return;
    await _playTingWithVibration();
    await stopBackgroundMusic();
  }

  Future<void> playBreakStart() async {
    if (!_isEnabled) return;
    await _playTingWithVibration();
  }

  Future<void> playBreakComplete() async {
    if (!_isEnabled) return;
    await _playTingWithVibration();
  }

  Future<void> playCycleComplete() async {
    if (!_isEnabled) return;
    await _playTingWithVibration();
  }

  Future<void> playBackgroundMusic() async {
    if (!_isEnabled) return;
    _isPlaying = true;
    await _playRandomTrack();
  }

  Future<void> _playRandomTrack() async {
    if (!_isPlaying || !_isEnabled) return;

    try {
      final random = Random();
      final trackIndex = random.nextInt(_backgroundTracks.length);
      final track = _backgroundTracks[trackIndex];

      _currentVolume = 0.0;
      await _backgroundPlayer.play(
        AssetSource(track),
        volume: _currentVolume,
        mode: PlayerMode.mediaPlayer,
      );

      await _fadeIn();

      _backgroundPlayer.onPlayerComplete.listen((_) async {
        if (!_isPlaying) return;

        await _fadeOut();

        await Future.delayed(const Duration(milliseconds: 500));

        await _playRandomTrack();
      });
    } catch (e) {
      await Future.delayed(const Duration(seconds: 2));
      if (_isPlaying) {
        await _playRandomTrack();
      }
    }
  }

  Future<void> _fadeIn() async {
    _fadeTimer?.cancel();
    const targetVolume = 0.3;
    const steps = 20;
    const stepDuration = Duration(milliseconds: 100);

    for (int i = 0; i <= steps; i++) {
      if (!_isPlaying) break;
      _currentVolume = (targetVolume / steps) * i;
      await _backgroundPlayer.setVolume(_currentVolume);
      await Future.delayed(stepDuration);
    }
  }

  Future<void> _fadeOut() async {
    _fadeTimer?.cancel();
    const steps = 15;
    const stepDuration = Duration(milliseconds: 100);

    for (int i = steps; i >= 0; i--) {
      if (!_isPlaying) break;
      _currentVolume = (0.3 / steps) * i;
      await _backgroundPlayer.setVolume(_currentVolume);
      await Future.delayed(stepDuration);
    }
  }

  Future<void> stopBackgroundMusic() async {
    _isPlaying = false;
    _fadeTimer?.cancel();

    try {
      await _fadeOut();
      await _backgroundPlayer.stop();
    } catch (e) {}
  }

  void dispose() {
    _fadeTimer?.cancel();
    _effectPlayer.dispose();
    _backgroundPlayer.dispose();
  }
}
