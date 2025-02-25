import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/intro_screen.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize audio service
  final audioService = AudioService();
  await audioService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AI Blocker',
        theme: ThemeData(
          primaryColor: const Color(0xFF43CEA2),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF43CEA2),
            primary: const Color(0xFF43CEA2),
            secondary: const Color(0xFF185A9D),
          ),
          scaffoldBackgroundColor: Colors.transparent,
          fontFamily: 'Roboto',
        ),
        home: const IntroScreen(),
      ),
    );
  }
}
