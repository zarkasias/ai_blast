import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _selectPlayer;
  AudioPlayer? _matchPlayer;
  AudioPlayer? _burstPlayer;
  AudioPlayer? _musicPlayer;
  bool _isSoundEffectsEnabled = true;
  bool _isMusicEnabled = true;
  bool _isInitialized = false;
  bool _isMusicPlaying = false;

  bool get isSoundEffectsEnabled => _isSoundEffectsEnabled;
  bool get isMusicEnabled => _isMusicEnabled;

  Future<void> _disposeAllPlayers() async {
    debugPrint('AudioService: Disposing all players...');
    
    // Dispose each player individually to handle nulls properly
    if (_selectPlayer != null) await _selectPlayer!.dispose();
    if (_matchPlayer != null) await _matchPlayer!.dispose();
    if (_burstPlayer != null) await _burstPlayer!.dispose();
    if (_musicPlayer != null) await _musicPlayer!.dispose();
    
    _selectPlayer = null;
    _matchPlayer = null;
    _burstPlayer = null;
    _musicPlayer = null;
    _isMusicPlaying = false;
    debugPrint('AudioService: All players disposed');
  }

  Future<void> initialize() async {
    debugPrint('AudioService: Starting initialization...');
    
    // Reset initialization state
    _isInitialized = false;
    
    // Clean up existing players
    await _disposeAllPlayers();
    
    try {
      // Create new players
      _selectPlayer = AudioPlayer();
      _matchPlayer = AudioPlayer();
      _burstPlayer = AudioPlayer();
      _musicPlayer = AudioPlayer();

      // Configure all players
      debugPrint('AudioService: Configuring audio players...');
      await Future.wait([
        // Sound effects configuration
        _selectPlayer!.setReleaseMode(ReleaseMode.stop).then((_) => debugPrint('Select player release mode set')),
        _matchPlayer!.setReleaseMode(ReleaseMode.stop).then((_) => debugPrint('Match player release mode set')),
        _burstPlayer!.setReleaseMode(ReleaseMode.stop).then((_) => debugPrint('Burst player release mode set')),
        _selectPlayer!.setPlayerMode(PlayerMode.lowLatency).then((_) => debugPrint('Select player mode set')),
        _matchPlayer!.setPlayerMode(PlayerMode.lowLatency).then((_) => debugPrint('Match player mode set')),
        _burstPlayer!.setPlayerMode(PlayerMode.lowLatency).then((_) => debugPrint('Burst player mode set')),
        // Background music configuration
        _musicPlayer!.setReleaseMode(ReleaseMode.loop).then((_) => debugPrint('Music player release mode set')),
        _musicPlayer!.setPlayerMode(PlayerMode.mediaPlayer).then((_) => debugPrint('Music player mode set')),
      ]);

      // Set volumes
      debugPrint('AudioService: Setting volumes...');
      await Future.wait([
        _selectPlayer!.setVolume(1.0).then((_) => debugPrint('Select player volume set')),
        _matchPlayer!.setVolume(1.0).then((_) => debugPrint('Match player volume set')),
        _burstPlayer!.setVolume(1.0).then((_) => debugPrint('Burst player volume set')),
        _musicPlayer!.setVolume(0.3).then((_) => debugPrint('Music player volume set')),
      ]);

      // Set sources
      debugPrint('AudioService: Setting up audio sources...');
      await Future.wait([
        _selectPlayer!.setSource(AssetSource('sounds/select.mp3')).then((_) => debugPrint('Select player source set')),
        _matchPlayer!.setSource(AssetSource('sounds/match.mp3')).then((_) => debugPrint('Match player source set')),
        _burstPlayer!.setSource(AssetSource('sounds/burst.mp3')).then((_) => debugPrint('Burst player source set')),
        _musicPlayer!.setSource(AssetSource('music/background.mp3')).then((_) => debugPrint('Music player source set')),
      ]);

      _isInitialized = true;
      debugPrint('AudioService: Initialization complete');

      // Start background music immediately after initialization if enabled
      if (_isMusicEnabled) {
        await startBackgroundMusic();
      }
    } catch (e, stackTrace) {
      debugPrint('AudioService: Error during initialization: $e');
      debugPrint('AudioService: Stack trace: $stackTrace');
      _isSoundEffectsEnabled = false;
      _isMusicEnabled = false;
      _isInitialized = false;
      await _disposeAllPlayers();
    }
  }

  Future<void> startBackgroundMusic() async {
    if (!_isMusicEnabled || !_isInitialized) {
      debugPrint('AudioService: Cannot start music - enabled: $_isMusicEnabled, initialized: $_isInitialized');
      return;
    }

    if (_isMusicPlaying && _musicPlayer != null) {
      debugPrint('AudioService: Music is already playing, skipping start');
      return;
    }

    try {
      debugPrint('AudioService: Starting background music...');
      
      // Dispose of existing music player
      if (_musicPlayer != null) {
        debugPrint('AudioService: Disposing existing music player...');
        await _musicPlayer!.stop();
        await _musicPlayer!.dispose();
        _musicPlayer = null;
        _isMusicPlaying = false;
      }

      // Create and configure new music player
      debugPrint('AudioService: Creating new music player...');
      _musicPlayer = AudioPlayer();
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setPlayerMode(PlayerMode.mediaPlayer);
      await _musicPlayer!.setVolume(0.3);
      await _musicPlayer!.setSource(AssetSource('music/background.mp3'));
      
      // Start playback
      await _musicPlayer!.resume();
      _isMusicPlaying = true;
      debugPrint('AudioService: Background music started successfully');
    } catch (e) {
      debugPrint('AudioService: Error playing background music: $e');
      _isMusicPlaying = false;
      // Clean up on error
      if (_musicPlayer != null) {
        await _musicPlayer!.dispose();
        _musicPlayer = null;
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (!_isMusicPlaying || _musicPlayer == null) return;
    try {
      debugPrint('AudioService: Stopping background music...');
      await _musicPlayer!.stop();
      _isMusicPlaying = false;
      debugPrint('AudioService: Background music stopped');
    } catch (e) {
      debugPrint('AudioService: Error stopping background music: $e');
    }
  }

  Future<void> playSelectSound() async {
    if (!_isSoundEffectsEnabled || !_isInitialized || _selectPlayer == null) {
      debugPrint('AudioService: Cannot play select sound - enabled: $_isSoundEffectsEnabled, initialized: $_isInitialized');
      return;
    }
    try {
      await _selectPlayer!.stop();
      await _selectPlayer!.play(AssetSource('sounds/select.mp3'));
    } catch (e) {
      debugPrint('AudioService: Error playing select sound: $e');
    }
  }

  Future<void> playMatchSound() async {
    if (!_isSoundEffectsEnabled || !_isInitialized || _matchPlayer == null) {
      debugPrint('AudioService: Cannot play match sound - enabled: $_isSoundEffectsEnabled, initialized: $_isInitialized');
      return;
    }
    try {
      await _matchPlayer!.stop();
      await _matchPlayer!.play(AssetSource('sounds/match.mp3'));
    } catch (e) {
      debugPrint('AudioService: Error playing match sound: $e');
    }
  }

  Future<void> playBurstSound() async {
    if (!_isSoundEffectsEnabled || !_isInitialized || _burstPlayer == null) {
      debugPrint('AudioService: Cannot play burst sound - enabled: $_isSoundEffectsEnabled, initialized: $_isInitialized');
      return;
    }
    try {
      await _burstPlayer!.stop();
      await _burstPlayer!.play(AssetSource('sounds/burst.mp3'));
    } catch (e) {
      debugPrint('AudioService: Error playing burst sound: $e');
    }
  }

  void toggleSoundEffects() {
    _isSoundEffectsEnabled = !_isSoundEffectsEnabled;
    debugPrint('AudioService: Sound effects ${_isSoundEffectsEnabled ? "enabled" : "disabled"}');
  }

  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    if (_isMusicEnabled) {
      startBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
    debugPrint('AudioService: Music ${_isMusicEnabled ? "enabled" : "disabled"}');
  }

  Future<void> dispose() async {
    await _disposeAllPlayers();
  }
} 