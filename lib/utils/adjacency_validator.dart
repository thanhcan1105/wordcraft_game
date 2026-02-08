import '../models/game_models.dart';

/// Utility class for validating grid adjacency and positions
class AdjacencyValidator {
  /// Check if two positions are adjacent in 4 directions (up, down, left, right)
  /// Does NOT allow diagonal adjacency
  static bool areAdjacent(GridPosition pos1, GridPosition pos2) {
    final rowDiff = (pos1.row - pos2.row).abs();
    final colDiff = (pos1.col - pos2.col).abs();

    // Adjacent if exactly one step in one direction
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  /// Validate if a new position can be added to the current selection
  /// Returns true if:
  /// - Selection is empty (first tile), OR
  /// - New position is adjacent to the last selected position
  static bool canAddToSelection(
    WordSelection selection,
    GridPosition newPosition,
  ) {
    // First tile can always be added
    if (selection.isEmpty) {
      return true;
    }

    // Check if already selected
    if (selection.containsPosition(newPosition)) {
      return false;
    }

    // Check if adjacent to last position
    final lastPos = selection.lastPosition;
    if (lastPos == null) {
      return true;
    }

    return areAdjacent(lastPos, newPosition);
  }

  /// Get the grid position from screen coordinates
  /// Useful for converting touch/swipe coordinates to grid positions
  static GridPosition? getPositionFromCoordinates({
    required double dx,
    required double dy,
    required double gridStartX,
    required double gridStartY,
    required double tileSize,
    required int rows,
    required int cols,
  }) {
    // Calculate which tile was touched
    final col = ((dx - gridStartX) / tileSize).floor();
    final row = ((dy - gridStartY) / tileSize).floor();

    // Validate bounds
    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      return null;
    }

    return GridPosition(row, col);
  }

  /// Check if a position is within grid bounds
  static bool isValidPosition(GridPosition position, int rows, int cols) {
    return position.row >= 0 &&
        position.row < rows &&
        position.col >= 0 &&
        position.col < cols;
  }
}
