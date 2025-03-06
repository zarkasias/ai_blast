import 'package:flutter/material.dart';
import '../models/level_config.dart';
import 'level_screen.dart';

class LevelCompleteScreen extends StatefulWidget {
  final int score;
  final int level;
  final Map<LevelObjective, int> objectiveProgress;
  final LevelConfig levelConfig;
  final bool isLastLevel;

  const LevelCompleteScreen({
    Key? key,
    required this.score,
    required this.level,
    required this.objectiveProgress,
    required this.levelConfig,
    required this.isLastLevel,
  }) : super(key: key);

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late List<bool> _objectivesRevealed;
  bool _showNextButton = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _objectivesRevealed = List.generate(
      widget.levelConfig.objectives.length,
      (index) => false,
    );

    _animateObjectives();
  }

  void _animateObjectives() async {
    await _controller.forward();
    
    for (int i = 0; i < _objectivesRevealed.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _objectivesRevealed[i] = true;
      });
    }

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _showNextButton = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: SingleChildScrollView(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Level Complete Icon and Text
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB75E),
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LEVEL ${widget.level} COMPLETE!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF185A9D),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Objectives
                  ...List.generate(widget.levelConfig.objectives.length, (index) {
                    final objective = widget.levelConfig.objectives[index];
                    final progress = widget.objectiveProgress[objective] ?? 0;
                    final target = widget.levelConfig.objectiveTargets[objective] ?? 0;
                    final isComplete = progress >= target;

                    return AnimatedOpacity(
                      opacity: _objectivesRevealed[index] ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isComplete ? const Color(0xFF43CEA2).withOpacity(0.1) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isComplete ? const Color(0xFF43CEA2) : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isComplete ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: isComplete ? const Color(0xFF43CEA2) : Colors.grey[400],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getObjectiveDescription(objective),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isComplete ? const Color(0xFF185A9D) : Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '$progress/$target',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: isComplete ? const Color.fromARGB(255, 2, 119, 82) : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Rewards Section
                  if (widget.levelConfig.rewards.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'REWARDS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF185A9D),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: widget.levelConfig.rewards.entries.map((reward) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB75E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFB75E),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getRewardIcon(reward.key),
                                color: const Color(0xFFFFB75E),
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${reward.value}x ${_getRewardName(reward.key)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF185A9D),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Next Level or Level Select Button
                  if (_showNextButton)
                    Column(
                      children: [
                        if (!widget.isLastLevel)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const LevelScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF43CEA2),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'NEXT LEVEL',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LevelScreen()),
                            );
                          },
                          child: const Text(
                            'LEVEL SELECT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF185A9D),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getObjectiveDescription(LevelObjective objective) {
    switch (objective) {
      case LevelObjective.score:
        return 'Reach target score';
      case LevelObjective.clearBlocks:
        return 'Clear blocks';
      case LevelObjective.collectItems:
        return 'Collect items';
      case LevelObjective.breakIce:
        return 'Break ice blocks';
      case LevelObjective.surviveMoves:
        return 'Survive moves';
      case LevelObjective.matchBombs:
        return 'Match bomb blocks';
      case LevelObjective.matchRockets:
        return 'Match rocket blocks';
      case LevelObjective.matchRainbow:
        return 'Match rainbow blocks';
      case LevelObjective.usePortals:
        return 'Use portal connections';
      case LevelObjective.createSpecials:
        return 'Create special blocks';
      case LevelObjective.chainReaction:
        return 'Create chain reactions';
      default:
        return 'Unknown objective';
    }
  }

  IconData _getRewardIcon(String rewardType) {
    switch (rewardType) {
      case 'coins':
        return Icons.monetization_on_rounded;
      case 'bomb_powerup':
        return Icons.flash_on_rounded;
      case 'rocket_powerup':
        return Icons.rocket_launch_rounded;
      case 'rainbow_powerup':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  String _getRewardName(String rewardType) {
    switch (rewardType) {
      case 'coins':
        return 'Coins';
      case 'bomb_powerup':
        return 'Bomb';
      case 'rocket_powerup':
        return 'Rocket';
      case 'rainbow_powerup':
        return 'Rainbow';
      default:
        return rewardType;
    }
  }
} 