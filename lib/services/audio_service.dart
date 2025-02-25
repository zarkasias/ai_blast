import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _selectPlayer = AudioPlayer();
  final AudioPlayer _matchPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _isSoundEnabled = true;
  bool _isInitialized = false;
  bool _isMusicPlaying = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('AudioService: Already initialized');
      return;
    }
    
    debugPrint('AudioService: Starting initialization...');
    try {
      // Configure all players first
      debugPrint('AudioService: Configuring audio players...');
      await Future.wait([
        // Sound effects configuration
        _selectPlayer.setReleaseMode(ReleaseMode.stop),
        _matchPlayer.setReleaseMode(ReleaseMode.stop),
        _selectPlayer.setPlayerMode(PlayerMode.lowLatency),
        _matchPlayer.setPlayerMode(PlayerMode.lowLatency),
        // Background music configuration
        _musicPlayer.setReleaseMode(ReleaseMode.loop),
        _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer),
      ]);

      // Set volumes
      debugPrint('AudioService: Setting volumes...');
      await Future.wait([
        _selectPlayer.setVolume(1.0),
        _matchPlayer.setVolume(1.0),
        _musicPlayer.setVolume(0.3),
      ]);

      // Set sources
      debugPrint('AudioService: Setting up audio sources...');
      await Future.wait([
        _selectPlayer.setSource(AssetSource('sounds/select.mp3')),
        _matchPlayer.setSource(AssetSource('sounds/match.mp3')),
        _musicPlayer.setSource(AssetSource('music/background.mp3')),
      ]);

      _isInitialized = true;
      debugPrint('AudioService: Initialization complete');

      // Start background music immediately after initialization
      await startBackgroundMusic();
    } catch (e, stackTrace) {
      debugPrint('AudioService: Error during initialization: $e');
      debugPrint('AudioService: Stack trace: $stackTrace');
      _isSoundEnabled = false;
    }
  }

  Future<void> startBackgroundMusic() async {
    if (!_isSoundEnabled || !_isInitialized || _isMusicPlaying) return;
    try {
      debugPrint('AudioService: Starting background music...');
      await _musicPlayer.resume();
      _isMusicPlaying = true;
      debugPrint('AudioService: Background music started');
    } catch (e) {
      debugPrint('AudioService: Error playing background music: $e');
      _isMusicPlaying = false;
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (!_isMusicPlaying) return;
    try {
      debugPrint('AudioService: Stopping background music...');
      await _musicPlayer.pause();
      _isMusicPlaying = false;
      debugPrint('AudioService: Background music stopped');
    } catch (e) {
      debugPrint('AudioService: Error stopping background music: $e');
    }
  }

  Future<void> playSelectSound() async {
    if (!_isSoundEnabled || !_isInitialized) {
      debugPrint('AudioService: Cannot play select sound - enabled: $_isSoundEnabled, initialized: $_isInitialized');
      return;
    }
    try {
      await _selectPlayer.stop();
      await _selectPlayer.play(AssetSource('sounds/select.mp3'));
    } catch (e) {
      debugPrint('AudioService: Error playing select sound: $e');
    }
  }

  Future<void> playMatchSound() async {
    if (!_isSoundEnabled || !_isInitialized) {
      debugPrint('AudioService: Cannot play match sound - enabled: $_isSoundEnabled, initialized: $_isInitialized');
      return;
    }
    try {
      await _matchPlayer.stop();
      await _matchPlayer.play(AssetSource('sounds/match.mp3'));
    } catch (e) {
      debugPrint('AudioService: Error playing match sound: $e');
    }
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    if (_isSoundEnabled) {
      startBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
    debugPrint('AudioService: Sound ${_isSoundEnabled ? "enabled" : "disabled"}');
  }

  bool get isSoundEnabled => _isSoundEnabled;

  void dispose() {
    stopBackgroundMusic();
    _selectPlayer.dispose();
    _matchPlayer.dispose();
    _musicPlayer.dispose();
  }
} 