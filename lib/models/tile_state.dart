/// Represents the visual state of a letter tile in the grid
enum TileState {
  /// Default state - tile is not selected or part of any word
  normal,

  /// Tile is currently being selected during a swipe gesture
  selected,

  /// Tile is part of a correctly found word
  correct,

  /// Tile was selected but the word was incorrect
  incorrect,
}
