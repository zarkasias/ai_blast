import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'animated_block.dart';

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
            color: Colors.transparent,
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: GameProvider.gridSize,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: GameProvider.gridSize * GameProvider.gridSize,
            itemBuilder: (context, index) {
              final row = index ~/ GameProvider.gridSize;
              final col = index % GameProvider.gridSize;
              
              // Additional safety check for grid access
              if (row >= gameProvider.grid.length || 
                  col >= gameProvider.grid[row].length) {
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

              final block = gameProvider.grid[row][col];

              if (block == null) {
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
} 