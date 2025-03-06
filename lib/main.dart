import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'providers/game_provider.dart';
import 'screens/intro_screen.dart';
import 'services/audio_service.dart';
import 'widgets/loading_screen.dart';
import 'widgets/custom_cursor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    debugPrint('MyApp: Starting game initialization...');
    try {
      // Clear saved progress
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // This will clear all saved preferences
      debugPrint('MyApp: Cleared saved progress');
      
      // Initialize audio service first
      debugPrint('MyApp: Initializing audio service...');
      await _audioService.initialize();
      debugPrint('MyApp: Audio service initialized successfully');
      
      // Add a small delay to simulate asset loading
      await Future.delayed(const Duration(milliseconds: 1000));
      
      setState(() {
        _isInitialized = true;
      });
      
      // Start background music after initialization if enabled
      if (_audioService.isMusicEnabled) {
        await _audioService.startBackgroundMusic();
      }
    } catch (e) {
      debugPrint('MyApp: Error during initialization: $e');
      setState(() {
        _isInitialized = true; // Still set to true to show the game even if audio fails
      });
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    debugPrint('MyApp: Hot reload detected...');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AudioService>(
          create: (_) => _audioService,
        ),
        ChangeNotifierProvider<GameProvider>(
          create: (context) => GameProvider(
            audioService: context.read<AudioService>(),
          ),
        ),
      ],
      builder: (context, child) {
        final gameProvider = Provider.of<GameProvider>(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Block Blast',
          navigatorKey: gameProvider.navigatorKey,
          theme: ThemeData(
            primaryColor: const Color(0xFF43CEA2),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF43CEA2),
              primary: const Color(0xFF43CEA2),
              secondary: const Color(0xFF185A9D),
            ),
            scaffoldBackgroundColor: Colors.transparent,
            fontFamily: GoogleFonts.montserrat().fontFamily,
            textTheme: GoogleFonts.montserratTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          builder: (context, child) => CustomCursor(child: child ?? const SizedBox()),
          home: !_isInitialized ? const LoadingScreen() : const IntroScreen(),
        );
      },
    );
  }
}
