import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../models/tile_state.dart';
import '../theme/app_theme.dart';

/// Individual letter tile widget with animated state transitions
/// Now supports "connections" to adjacent tiles for word blobs
class LetterTileWidget extends StatelessWidget {
  final LetterTile tile;
  final double size;
  final int colorIndex;
  final Set<String> connections; // 'top', 'bottom', 'left', 'right'

  const LetterTileWidget({
    super.key,
    required this.tile,
    required this.size,
    this.colorIndex = 0,
    this.connections = const {},
  });

  @override
  Widget build(BuildContext context) {
    final stateString = _tileStateToString(tile.state);
    final backgroundColor =
        AppTheme.getTileColor(stateString, colorIndex: colorIndex);
    final borderColor =
        AppTheme.getTileBorderColor(stateString, colorIndex: colorIndex);

    // Calculate radius based on connections
    final double baseRadius = AppTheme.radiusM;
    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(
          connections.contains('top') || connections.contains('left')
              ? 0
              : baseRadius),
      topRight: Radius.circular(
          connections.contains('top') || connections.contains('right')
              ? 0
              : baseRadius),
      bottomLeft: Radius.circular(
          connections.contains('bottom') || connections.contains('left')
              ? 0
              : baseRadius),
      bottomRight: Radius.circular(
          connections.contains('bottom') || connections.contains('right')
              ? 0
              : baseRadius),
    );

    final showConnections = tile.state == TileState.correct;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Connection bridges (to fill gaps)
        if (showConnections) ...[
          if (connections.contains('right'))
            Positioned(
              right: -AppTheme.tileSpacing,
              top: 0,
              bottom: 0,
              width: AppTheme.tileSpacing + 2,
              child: Container(color: backgroundColor),
            ),
          if (connections.contains('bottom'))
            Positioned(
              bottom: -AppTheme.tileSpacing,
              left: 0,
              right: 0,
              height: AppTheme.tileSpacing + 2,
              child: Container(color: backgroundColor),
            ),
        ],

        // Main tile
        AnimatedContainer(
          duration: AppTheme.mediumAnimation,
          curve: AppTheme.defaultCurve,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: showConnections
                ? borderRadius
                : BorderRadius.circular(baseRadius),
            border: showConnections
                ? null // Remove border for connected tiles to look seamless
                : Border.all(color: borderColor, width: 2),
            boxShadow: tile.state == TileState.normal
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              tile.letter,
              style: TextStyle(
                fontSize: size * 0.45,
                fontWeight: FontWeight.bold,
                color: tile.state == TileState.normal
                    ? Theme.of(context).textTheme.displayLarge?.color
                    : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _tileStateToString(TileState state) {
    switch (state) {
      case TileState.selected:
        return 'selected';
      case TileState.correct:
        return 'correct';
      case TileState.incorrect:
        return 'incorrect';
      default:
        return 'normal';
    }
  }
}
