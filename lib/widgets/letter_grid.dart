import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../utils/adjacency_validator.dart';
import 'letter_tile.dart';

/// Interactive letter grid with swipe detection
/// Supports "Word Blobs" - connected backgrounds for found words
class LetterGrid extends StatefulWidget {
  const LetterGrid({super.key});

  @override
  State<LetterGrid> createState() => _LetterGridState();
}

class _LetterGridState extends State<LetterGrid> {
  final GlobalKey _gridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (!gameProvider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth =
                constraints.maxWidth - (AppTheme.tileSpacing * 2);
            final availableHeight =
                constraints.maxHeight - (AppTheme.tileSpacing * 2);

            final tileWidthBased = (availableWidth -
                    (AppTheme.tileSpacing * (gameProvider.gameData.cols - 1))) /
                gameProvider.gameData.cols;
            final tileHeightBased = (availableHeight -
                    (AppTheme.tileSpacing * (gameProvider.gameData.rows - 1))) /
                gameProvider.gameData.rows;

            final tileSize = tileWidthBased < tileHeightBased
                ? tileWidthBased
                : tileHeightBased;

            final totalGridWidth = (gameProvider.gameData.cols * tileSize) +
                ((gameProvider.gameData.cols - 1) * AppTheme.tileSpacing);
            final totalGridHeight = (gameProvider.gameData.rows * tileSize) +
                ((gameProvider.gameData.rows - 1) * AppTheme.tileSpacing);

            final offsetX = (constraints.maxWidth - totalGridWidth) / 2;
            final offsetY = (constraints.maxHeight - totalGridHeight) / 2;

            return GestureDetector(
              onPanStart: (details) => _handlePanStart(
                  details, gameProvider, tileSize, offsetX, offsetY),
              onPanUpdate: (details) => _handlePanUpdate(
                  details, gameProvider, tileSize, offsetX, offsetY),
              onPanEnd: (details) => _handlePanEnd(gameProvider),
              child: Container(
                key: _gridKey,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: Colors.transparent,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      gameProvider.gameData.rows,
                      (row) => _buildRow(row, gameProvider, tileSize),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRow(int row, GameProvider gameProvider, double tileSize) {
    return Padding(
      padding: EdgeInsets.only(
          bottom:
              row < gameProvider.gameData.rows - 1 ? AppTheme.tileSpacing : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          gameProvider.gameData.cols,
          (col) {
            final tile = gameProvider.grid[row][col];
            final colorIndex = _getColorIndexForTile(tile, gameProvider);
            final connections =
                _getConnectionsForTile(tile.position, gameProvider);

            return Padding(
              padding: EdgeInsets.only(
                  right: col < gameProvider.gameData.cols - 1
                      ? AppTheme.tileSpacing
                      : 0),
              child: LetterTileWidget(
                tile: tile,
                size: tileSize,
                colorIndex: colorIndex,
                connections: connections,
              ),
            );
          },
        ),
      ),
    );
  }

  int _getColorIndexForTile(LetterTile tile, GameProvider gameProvider) {
    for (final foundWord in gameProvider.foundWords) {
      if (foundWord.positions.contains(tile.position)) {
        return foundWord.colorIndex;
      }
    }
    return 0;
  }

  /// Check which adjacent tiles belong to the same found word
  Set<String> _getConnectionsForTile(
      GridPosition pos, GameProvider gameProvider) {
    final connections = <String>{};
    FoundWord? parentWord;

    for (final word in gameProvider.foundWords) {
      if (word.positions.contains(pos)) {
        parentWord = word;
        break;
      }
    }

    if (parentWord == null) return connections;

    // Check 4 directions
    final neighbors = {
      'top': GridPosition(pos.row - 1, pos.col),
      'bottom': GridPosition(pos.row + 1, pos.col),
      'left': GridPosition(pos.row, pos.col - 1),
      'right': GridPosition(pos.row, pos.col + 1),
    };

    neighbors.forEach((dir, nPos) {
      if (parentWord!.positions.contains(nPos)) {
        connections.add(dir);
      }
    });

    return connections;
  }

  void _handlePanStart(DragStartDetails details, GameProvider gameProvider,
      double tileSize, double offsetX, double offsetY) {
    final position = _getPositionFromLocalCoordinates(
        details.localPosition, gameProvider, tileSize, offsetX, offsetY);
    if (position != null) {
      gameProvider.startSelection(position);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, GameProvider gameProvider,
      double tileSize, double offsetX, double offsetY) {
    final position = _getPositionFromLocalCoordinates(
        details.localPosition, gameProvider, tileSize, offsetX, offsetY);
    if (position != null) {
      gameProvider.addToSelection(position);
    }
  }

  void _handlePanEnd(GameProvider gameProvider) {
    gameProvider.endSelection();
  }

  GridPosition? _getPositionFromLocalCoordinates(
      Offset localPosition,
      GameProvider gameProvider,
      double tileSize,
      double offsetX,
      double offsetY) {
    return AdjacencyValidator.getPositionFromCoordinates(
      dx: localPosition.dx,
      dy: localPosition.dy,
      gridStartX: offsetX,
      gridStartY: offsetY,
      tileSize: tileSize + AppTheme.tileSpacing,
      rows: gameProvider.gameData.rows,
      cols: gameProvider.gameData.cols,
    );
  }
}
