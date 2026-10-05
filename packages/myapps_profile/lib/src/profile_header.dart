import 'package:flutter/material.dart';

/// Shared profile row; applications own state and editing flows.
class MyAppsProfileHeader extends StatelessWidget {
  final Widget avatar;
  final String? name;
  final String namePlaceholder;
  final String editHint;
  final VoidCallback onEdit;

  /// Purpose: Construct a localized profile row.
  /// Inputs: Avatar, optional name, placeholder, hint and edit callback.
  /// Returns: A profile header widget.
  /// Side effects: None.
  /// Notes: App providers supply current values.
  const MyAppsProfileHeader({
    super.key,
    required this.avatar,
    required this.name,
    required this.namePlaceholder,
    required this.editHint,
    required this.onEdit,
  });

  /// Purpose: Render the avatar/name row with the current theme.
  /// Inputs: `context`.
  /// Returns: A tappable list tile.
  /// Side effects: Calls onEdit when tapped.
  /// Notes: Unset names use the secondary foreground color.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: avatar,
      title: Text(
        name ?? namePlaceholder,
        style: theme.textTheme.titleLarge?.copyWith(
          color: name == null ? theme.colorScheme.onSurfaceVariant : null,
        ),
      ),
      subtitle: Text(editHint),
      trailing: const Icon(Icons.edit_outlined),
      onTap: onEdit,
    );
  }
}
