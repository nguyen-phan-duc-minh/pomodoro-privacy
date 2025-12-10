import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  Future<void> playStudyStart() async {
    if (!_isEnabled) return;
    await _playBeep(frequency: 800, duration: 200);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playBeep(frequency: 1000, duration: 200);
  }

  Future<void> playStudyComplete() async {
    if (!_isEnabled) return;
    await _playBeep(frequency: 1000, duration: 300);
    await Future.delayed(const Duration(milliseconds: 100));
    await _playBeep(frequency: 800, duration: 300);
  }

  Future<void> playBreakStart() async {
    if (!_isEnabled) return;
    await _playBeep(frequency: 600, duration: 400);
  }

  Future<void> playBreakComplete() async {
    if (!_isEnabled) return;
    await _playBeep(frequency: 1200, duration: 200);
    await Future.delayed(const Duration(milliseconds: 50));
    await _playBeep(frequency: 1400, duration: 200);
    await Future.delayed(const Duration(milliseconds: 50));
    await _playBeep(frequency: 1600, duration: 200);
  }

  Future<void> playCycleComplete() async {
    if (!_isEnabled) return;
    for (int i = 0; i < 3; i++) {
      await _playBeep(frequency: 1000 + (i * 200), duration: 150);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _playBeep({required double frequency, required int duration}) async {
    try {
      await _player.play(AssetSource('audio/beep.mp3'), 
        volume: 0.5,
        mode: PlayerMode.lowLatency,
      );
      await Future.delayed(Duration(milliseconds: duration));
      await _player.stop();
    } catch (e) {
      // Audio playback failed, ignore
    }
  }

  void dispose() {
    _player.dispose();
  }
}
