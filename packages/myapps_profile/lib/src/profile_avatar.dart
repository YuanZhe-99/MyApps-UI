import 'dart:io';
import 'package:flutter/material.dart';
import 'profile_data.dart';

/// The stateless rendering behind the app provider wrapper, taking the profile as an
/// argument so tests and previews need no provider.
class MyAppsProfileAvatar extends StatelessWidget {
  final ProfileData profile;
  final double radius;
  final Future<File> Function(String path) resolveImage;

  /// Purpose: Create an avatar view for a given profile.
  /// Inputs: `profile`, `radius`.
  /// Returns: A new `MyAppsProfileAvatar`.
  /// Side effects: None.
  /// Notes: None.
  const MyAppsProfileAvatar({
    super.key,
    required this.profile,
    this.radius = 18,
    required this.resolveImage,
  });

  /// Purpose: Build the placeholder shown without an image.
  /// Inputs: `context`.
  /// Returns: A filled circle with an initial or a person icon.
  /// Side effects: None.
  /// Notes: Internal helper used within this file only.
  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = profile.name;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      child: name == null
          ? Icon(Icons.person, size: radius * 1.2)
          : Text(
              name.characters.first.toUpperCase(),
              style: TextStyle(
                fontSize: radius * 0.9,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }

  /// Purpose: Build the avatar circle.
  /// Inputs: `context`.
  /// Returns: The image in a circle, or the placeholder.
  /// Side effects: Resolves the avatar file path asynchronously.
  /// Notes: None.
  @override
  Widget build(BuildContext context) {
    final avatar = profile.avatar;
    if (avatar == null) return _placeholder(context);
    return FutureBuilder<File>(
      key: ValueKey(avatar),
      future: resolveImage(avatar),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) return _placeholder(context);
        return ClipOval(
          child: Image.file(
            file,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, _, _) => _placeholder(context),
          ),
        );
      },
    );
  }
}
