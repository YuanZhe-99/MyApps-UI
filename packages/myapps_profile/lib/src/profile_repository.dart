import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'profile_data.dart';
import 'profile_merge.dart';

/// Owns `profile.json` (0.6.0): the user's display name and avatar.
///
/// The file is registered in `lib/app/data_modules.dart`, so it syncs over
/// WebDAV and is backed up; a save therefore notifies auto-sync. Every write
/// is a read-modify-write through [update], serialised inside this process.
/// The avatar image itself lives in `images/` in the app directory, which is how
/// it reaches other devices.
class ProfileRepository {
  final Future<Directory> Function() getAppDir;
  final Future<void> Function(File file, String text) writeJson;
  final VoidSavedCallback onSaved;
  final Future<File> Function(String relativePath)? imageResolver;
  final Future<void> Function(String relativePath)? imageDeleter;

  /// Purpose: Bind profile persistence to an application's storage and sync boundaries.
  /// Inputs: Directory, atomic writer, saved notification and optional image adapters.
  /// Returns: A repository instance.
  /// Side effects: None.
  /// Notes: One long-lived repository per app retains queued update ordering.
  ProfileRepository({
    required this.getAppDir,
    required this.writeJson,
    required this.onSaved,
    this.imageResolver,
    this.imageDeleter,
  });

  /// The file's name under the app directory. Must match `profileFileName`
  /// in `lib/app/data_modules.dart`.
  static const fileName = 'profile.json';

  /// Edge length in pixels of the stored square avatar.
  static const avatarSize = 512;

  Future<void> _tail = Future.value();

  /// Purpose: Resolve the file.
  /// Inputs: None.
  /// Returns: `Future<File>`.
  /// Side effects: May create the app directory.
  /// Notes: Internal helper used within this file only.
  Future<File> _file() async {
    final dir = await getAppDir();
    return File(p.join(dir.path, fileName));
  }

  /// Purpose: Resolve an app-relative image through the application's adapter.
  /// Inputs: `relativePath`.
  /// Returns: File which may not exist yet.
  /// Side effects: May resolve or create the application directory.
  /// Notes: Missing files are handled by callers.
  Future<File> resolveImage(String relativePath) async {
    if (imageResolver != null) return imageResolver!(relativePath);
    return File(p.join((await getAppDir()).path, relativePath));
  }

  /// Purpose: Load the profile.
  /// Inputs: None.
  /// Returns: `Future<ProfileData>` — empty when the file is absent or
  /// unreadable.
  /// Side effects: Reads the file.
  /// Notes: None.
  Future<ProfileData> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return ProfileData();
      final text = await file.readAsString();
      if (text.trim().isEmpty) return ProfileData();
      return ProfileData.fromJson(jsonDecode(text));
    } catch (_) {
      return ProfileData();
    }
  }

  /// Purpose: Apply one change to the profile and save it.
  /// Inputs: `mutate` — returns the new profile from the loaded one.
  /// Returns: `Future<ProfileData>` — the profile after the change.
  /// Side effects: Writes the file atomically and notifies auto-sync, but
  /// only when the bytes changed.
  /// Notes: Calls are queued, so concurrent updates apply one after another.
  /// Throws a [FormatException] and leaves the file untouched when it exists
  /// but cannot be parsed; a blank file counts as empty.
  Future<ProfileData> update(ProfileData Function(ProfileData data) mutate) {
    final done = Completer<ProfileData>();
    _tail = _tail.then((_) async {
      try {
        done.complete(await _apply(mutate));
      } catch (e, s) {
        done.completeError(e, s);
      }
    });
    return done.future;
  }

  /// Purpose: Run one queued update.
  /// Inputs: `mutate`.
  /// Returns: `Future<ProfileData>`.
  /// Side effects: See [update].
  /// Notes: Internal helper used within this file only.
  Future<ProfileData> _apply(
    ProfileData Function(ProfileData data) mutate,
  ) async {
    final file = await _file();
    final before = await file.exists() ? await file.readAsString() : null;
    ProfileData data;
    if (before == null || before.trim().isEmpty) {
      data = ProfileData();
    } else {
      try {
        data = ProfileData.fromJson(jsonDecode(before));
      } catch (e) {
        // Saving over an unreadable file would erase the profile on every
        // device once synced. The bytes stay on disk untouched.
        throw FormatException('profile.json is unreadable: $e');
      }
    }
    data = mutate(data);
    final after = encodeProfile(data);
    if (after == before) return data;
    await writeJson(file, after);
    onSaved();
    return data;
  }

  /// Purpose: Set or clear the display name.
  /// Inputs: `name` — trimmed; empty clears it.
  /// Returns: `Future<ProfileData>`.
  /// Side effects: Writes the file when the name changed.
  /// Notes: An unchanged name keeps its old timestamp, so it does not win a
  /// merge it should not.
  Future<ProfileData> setName(String name) {
    final trimmed = name.trim();
    final value = trimmed.isEmpty ? null : trimmed;
    return update(
      (d) => d.name == value ? d : d.withName(value, DateTime.now().toUtc()),
    );
  }

  /// Purpose: Read the current avatar image, to adjust it again (0.6.1).
  /// Inputs: None.
  /// Returns: `Future<Uint8List?>` — the avatar's bytes, or null when there
  /// is no avatar or its file has not arrived on this device yet.
  /// Side effects: Reads one file under `images/`.
  /// Notes: The stored avatar is already a 512-pixel square, so adjusting it
  /// can only zoom further in, rotate or re-centre.
  Future<Uint8List?> readAvatarBytes() async {
    final rel = (await load()).avatar;
    if (rel == null) return null;
    try {
      final file = await resolveImage(rel);
      return await file.exists() ? await file.readAsBytes() : null;
    } catch (_) {
      return null;
    }
  }

  /// Purpose: Store an edited avatar (0.6.1).
  /// Inputs: `jpeg` — the editor's square JPEG ([avatarSize] pixels).
  /// Returns: `Future<ProfileData>` — the new profile.
  /// Side effects: Writes a new `images/avatar_<uuid>.jpg`, writes
  /// `profile.json`, and deletes the previous avatar file on this device.
  /// Notes: Every avatar gets a fresh file name, because image sync never
  /// overwrites a file that already exists on the other side.
  Future<ProfileData> setAvatarJpeg(Uint8List jpeg) async {
    final appDir = await getAppDir();
    final imagesDir = Directory(p.join(appDir.path, 'images'));
    await imagesDir.create(recursive: true);
    final rel = 'images/avatar_${const Uuid().v4()}.jpg';
    await File(p.join(appDir.path, rel)).writeAsBytes(jpeg, flush: true);
    String? previous;
    final data = await update((d) {
      previous = d.avatar;
      return d.withAvatar(rel, DateTime.now().toUtc());
    });
    await _deleteQuietly(previous);
    return data;
  }

  /// Purpose: Remove the avatar.
  /// Inputs: None.
  /// Returns: `Future<ProfileData>`.
  /// Side effects: Writes `profile.json` with an explicit removal and
  /// deletes the avatar file on this device.
  /// Notes: The removal is timestamped, so it syncs to other devices.
  Future<ProfileData> removeAvatar() async {
    String? previous;
    final data = await update((d) {
      previous = d.avatar;
      if (d.avatar == null) return d;
      return d.withAvatar(null, DateTime.now().toUtc());
    });
    await _deleteQuietly(previous);
    return data;
  }

  /// Purpose: Delete a replaced avatar file, ignoring failures.
  /// Inputs: `rel` — relative path, or null.
  /// Returns: None.
  /// Side effects: May delete one file under `images/`.
  /// Notes: Internal helper used within this file only. Only files this
  /// store created (`images/avatar_*`) are ever deleted, never other images.
  Future<void> _deleteQuietly(String? rel) async {
    if (rel == null || !p.basename(rel).startsWith('avatar_')) return;
    try {
      final file = await resolveImage(rel);
      if (imageDeleter != null) {
        await imageDeleter!(rel);
      } else if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}

/// Saved notification without an application or state-management dependency.
typedef VoidSavedCallback = void Function();
