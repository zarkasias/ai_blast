import 'package:flutter/material.dart';
import '../models/level_config.dart';

class LevelObjectives extends StatelessWidget {
  final Map<LevelObjective, int> objectiveProgress;
  final Map<LevelObjective, int> objectiveTargets;
  final bool isUnlocked;

  const LevelObjectives({
    Key? key,
    required this.objectiveProgress,
    required this.objectiveTargets,
    this.isUnlocked = true,
  }) : super(key: key);

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

  IconData _getObjectiveIcon(LevelObjective objective) {
    switch (objective) {
      case LevelObjective.score:
        return Icons.stars_rounded;
      case LevelObjective.clearBlocks:
        return Icons.grid_view_rounded;
      case LevelObjective.collectItems:
        return Icons.catching_pokemon_rounded;
      case LevelObjective.breakIce:
        return Icons.ac_unit_rounded;
      case LevelObjective.surviveMoves:
        return Icons.timer_rounded;
      case LevelObjective.matchBombs:
        return Icons.flash_on_rounded;
      case LevelObjective.matchRockets:
        return Icons.rocket_launch_rounded;
      case LevelObjective.matchRainbow:
        return Icons.auto_awesome_rounded;
      case LevelObjective.usePortals:
        return Icons.blur_circular_rounded;
      case LevelObjective.createSpecials:
        return Icons.auto_fix_high_rounded;
      case LevelObjective.chainReaction:
        return Icons.bolt_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: objectiveTargets.entries.map((entry) {
        final objective = entry.key;
        final target = entry.value;
        final progress = objectiveProgress[objective] ?? 0;
        final isComplete = progress >= target;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Objective Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isComplete
                      ? const Color(0xFF43CEA2).withOpacity(0.2)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getObjectiveIcon(objective),
                  color: isComplete
                      ? const Color(0xFF43CEA2)
                      : const Color(0xFF185A9D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Objective Description and Progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getObjectiveDescription(objective),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? const Color(0xFF185A9D)
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: target > 0 ? progress / target : 0,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete
                              ? const Color(0xFF43CEA2)
                              : const Color(0xFF185A9D),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Progress Text
              Text(
                '$progress/$target',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isComplete
                      ? const Color(0xFF43CEA2)
                      : const Color(0xFF185A9D),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 