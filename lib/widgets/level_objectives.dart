import 'package:flutter/material.dart';
import '../models/level_config.dart';

class LevelObjectives extends StatelessWidget {
  final Map<LevelObjective, int> objectiveProgress;
  final Map<LevelObjective, int> objectiveTargets;
  final bool isUnlocked;

  // Static map to store objective assets
  static final Map<LevelObjective, ObjectiveAsset> _objectiveAssets = {
    LevelObjective.score: const ObjectiveAsset(isImage: true, value: 'assets/icons/star/gold_star_64px.png'),
    LevelObjective.breakIce: const ObjectiveAsset(isImage: true, value: 'assets/icons/ice/ice_outline_64px.png'),
    LevelObjective.matchRockets: const ObjectiveAsset(isImage: true, value: 'assets/icons/rocket/rocket_64px.png'),
    LevelObjective.clearBlocks: const ObjectiveAsset(isImage: false, value: Icons.grid_view_rounded),
    LevelObjective.matchBombs: const ObjectiveAsset(isImage: true, value: 'assets/icons/bomb/bomb_gold_64px.png'),
    LevelObjective.usePortals: const ObjectiveAsset(isImage: true, value: 'assets/icons/portal/portal_purple_64px.png'),
    LevelObjective.collectItems: const ObjectiveAsset(isImage: false, value: Icons.catching_pokemon_rounded),
    LevelObjective.surviveMoves: const ObjectiveAsset(isImage: false, value: Icons.timer_rounded),
    LevelObjective.matchRainbow: const ObjectiveAsset(isImage: false, value: Icons.auto_awesome_rounded),
    LevelObjective.createSpecials: const ObjectiveAsset(isImage: false, value: Icons.auto_fix_high_rounded),
    LevelObjective.chainReaction: const ObjectiveAsset(isImage: false, value: Icons.bolt_rounded),
  };

  // Static map to store objective descriptions
  static final Map<LevelObjective, String> _objectiveDescriptions = {
    LevelObjective.score: 'Reach target score',
    LevelObjective.clearBlocks: 'Clear blocks',
    LevelObjective.collectItems: 'Collect items',
    LevelObjective.breakIce: 'Break ice blocks',
    LevelObjective.surviveMoves: 'Survive moves',
    LevelObjective.matchBombs: 'Match bomb blocks',
    LevelObjective.matchRockets: 'Match rocket blocks',
    LevelObjective.matchRainbow: 'Match rainbow blocks',
    LevelObjective.usePortals: 'Use portal connections',
    LevelObjective.createSpecials: 'Create special blocks',
    LevelObjective.chainReaction: 'Create chain reactions',
  };

  const LevelObjectives({
    Key? key,
    required this.objectiveProgress,
    required this.objectiveTargets,
    this.isUnlocked = true,
  }) : super(key: key);

  String _getObjectiveDescription(LevelObjective objective) {
    return _objectiveDescriptions[objective] ?? 'Unknown objective';
  }

  ObjectiveAsset _getObjectiveAsset(LevelObjective objective) {
    return _objectiveAssets[objective] ?? 
           const ObjectiveAsset(isImage: false, value: Icons.help_outline_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final objectives = objectiveTargets.entries.map((entry) {
      final objective = entry.key;
      final target = entry.value;
      final progress = objectiveProgress[objective] ?? 0;
      final isComplete = progress >= target;
      final asset = _getObjectiveAsset(objective);

      return _ObjectiveItem(
        objective: objective,
        target: target,
        progress: progress,
        isComplete: isComplete,
        asset: asset,
        isUnlocked: isUnlocked,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: objectives,
    );
  }
}

// Separate stateless widget for each objective item
class _ObjectiveItem extends StatelessWidget {
  final LevelObjective objective;
  final int target;
  final int progress;
  final bool isComplete;
  final ObjectiveAsset asset;
  final bool isUnlocked;

  const _ObjectiveItem({
    Key? key,
    required this.objective,
    required this.target,
    required this.progress,
    required this.isComplete,
    required this.asset,
    required this.isUnlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isComplete
                  ? const Color(0xFF43CEA2).withOpacity(0.2)
                  : Colors.grey[100]!.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: asset.isImage
                ? Image.asset(
                    asset.value as String,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    asset.value,
                    color: isComplete
                        ? const Color(0xFF43CEA2)
                        : const Color(0xFF185A9D),
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LevelObjectives._objectiveDescriptions[objective] ?? 'Unknown objective',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? const Color(0xFF185A9D)
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
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
  }
}

class ObjectiveAsset {
  final bool isImage;
  final dynamic value;

  const ObjectiveAsset({
    required this.isImage,
    required this.value,
  });
}
