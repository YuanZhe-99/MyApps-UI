/// The two interface styles the user can choose between.
///
/// [expressive] is the default. It approximates Material 3 Expressive at the
/// theme level (Flutter ships no Expressive components) and gives narrow
/// windows the floating island navigation bar. [material3] is stock
/// Material 3 with the classic full-width bottom bar.
enum AppUiStyle {
  /// Stock Material 3 and the classic full-width bottom bar.
  material3,

  /// Theme-level Material 3 Expressive approximation and the floating island
  /// bottom bar.
  expressive,
}

/// Where the shell puts its navigation, for both interface styles.
///
/// [bottom] (the default) keeps the bottom bar on every window; [sideOnWide]
/// switches to the side rail once the window is wide enough
/// (600 logical pixels); [side] uses the rail everywhere, phones included,
/// which is not recommended because the rail takes width from the content.
enum NavPlacement {
  /// Bottom bar on every window.
  bottom,

  /// Side rail on wide windows, bottom bar on narrow ones.
  sideOnWide,

  /// Side rail on every window.
  side,
}
