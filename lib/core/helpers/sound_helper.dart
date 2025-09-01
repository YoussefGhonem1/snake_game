import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundHelper {
  static final SoundHelper _instance = SoundHelper._internal();
  static SoundHelper get instance => _instance;

  late AudioPlayer _audioPlayer;
  bool _soundEnabled = true;

  SoundHelper._internal() {
    _audioPlayer = AudioPlayer();
    initialize();
  }

  // Initialize sound settings
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
  }

  // Toggle sound on/off
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
  }

  bool get isSoundEnabled => _soundEnabled;

  // Play sound effects
  Future<void> playEatSound() async {
    if (!_soundEnabled) return;

    try {
      // Play sound immediately without stopping (for instant response)
      _audioPlayer.play(
        AssetSource('sounds/coin-collect-retro-8-bit-sound-effect-145251.wav'),
      );
    } catch (e) {
      // Fallback to system sound or ignore
      print('Sound error: $e');
    }
  }

  Future<void> playGameOverSound() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/game over.mp3'));
    } catch (e) {
      print('Sound error: $e');
    }
  }

  Future<void> playLevelCompleteSound() async {
    if (!_soundEnabled) return;
    try {
      // Assuming 'level_win.mp3' is the correct asset.
      await _audioPlayer.play(AssetSource('sounds/level_win.mp3.mp3'));
    } catch (e) {
      print('Sound error: $e');
    }
  }

  Future<void> playMoveSound() async {
    if (!_soundEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/move.mp3'));
    } catch (e) {
      print('Sound error: $e');
    }
  }

  Future<void> playButtonClickSound() async {
    if (!_soundEnabled) return;
    try {
      // Play sound immediately without stopping (for instant response)
      _audioPlayer.play(AssetSource('sounds/retro-select-236670.mp3'));
    } catch (e) {
      print('Sound error: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
