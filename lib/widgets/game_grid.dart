import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'animated_block.dart';
import 'dart:math';

class GameGrid extends StatelessWidget {
  const GameGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Safety check for grid initialization
        if (gameProvider.grid.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: gameProvider.currentLevelConfig.gridBackgroundColor ?? Colors.transparent,
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gameProvider.currentLevelConfig.gridCols,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: gameProvider.currentLevelConfig.gridRows * gameProvider.currentLevelConfig.gridCols,
            itemBuilder: (context, index) {
              final row = index ~/ gameProvider.currentLevelConfig.gridCols;
              final col = index % gameProvider.currentLevelConfig.gridCols;
              
              // Additional safety check for grid access
              if (row >= gameProvider.grid.length || 
                  col >= gameProvider.grid[row].length) {
                return _buildEmptyCell();
              }

              final block = gameProvider.grid[row][col];

              // Check if this is a blocked cell
              if (block == null) {
                if (gameProvider.currentLevelConfig.blockedCells?.contains(Point(row, col)) ?? false) {
                  return _buildBlockedCell();
                }
                return _buildEmptyCell();
              }

              return AnimatedBlock(
                block: block,
                onTap: () => gameProvider.selectBlock(row, col),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyCell() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildBlockedCell() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[600]!.withOpacity(0.3),
          width: 2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[700]!.withOpacity(0.5),
            Colors.grey[900]!.withOpacity(0.5),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.block,
          color: Colors.white54,
          size: 24,
        ),
      ),
    );
  }
} 