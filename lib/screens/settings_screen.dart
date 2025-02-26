import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image Layer
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/blast-bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay Layer
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF7DDFC8).withOpacity(0.1),
                  const Color(0xFF4389C8).withOpacity(0.1),
                ],
              ),
            ),
          ),
          // Content Layer with SafeArea
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
                  child: Container(
                    color: const Color.fromARGB(180, 255, 255, 255),
                    height: 70,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF185A9D),
                            size: 28,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'SETTINGS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF185A9D),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        // Placeholder to balance the back button
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Settings List
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(180, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Audio',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Montserrat',
                            color: Color(0xFF185A9D),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Background Music Toggle
                        ListTile(
                          leading: Icon(
                            _audioService.isMusicEnabled
                                ? Icons.music_note_rounded
                                : Icons.music_off_rounded,
                            color: const Color(0xFF43CEA2),
                            size: 28,
                          ),
                          title: const Text(
                            'Background Music',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          trailing: Switch(
                            value: _audioService.isMusicEnabled,
                            onChanged: (value) {
                              setState(() {
                                _audioService.toggleMusic();
                              });
                            },
                            activeColor: const Color(0xFF43CEA2),
                          ),
                        ),
                        // Sound Effects Toggle
                        ListTile(
                          leading: Icon(
                            _audioService.isSoundEffectsEnabled
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            color: const Color(0xFF43CEA2),
                            size: 28,
                          ),
                          title: const Text(
                            'Sound Effects',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          trailing: Switch(
                            value: _audioService.isSoundEffectsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _audioService.toggleSoundEffects();
                              });
                            },
                            activeColor: const Color(0xFF43CEA2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 