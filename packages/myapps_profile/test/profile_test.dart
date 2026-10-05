import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:myapps_profile/myapps_profile.dart';

/// Purpose: Verify data compatibility, queued writes and avatar lifecycle.
/// Inputs: None.
/// Returns: None.
/// Side effects: Registers tests using disposable directories.
/// Notes: No application storage or synchronization implementation is imported.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final early = DateTime.utc(2026, 9, 1);
  final late = DateTime.utc(2026, 9, 2);
  test('old JSON, independent merge and explicit removal stay compatible', () {
    final local = ProfileData.fromJson({
      'version': 1,
      'displayName': 'Local',
      'displayNameUpdatedAt': late.toIso8601String(),
      'avatar': 'images/avatar_old.jpg',
      'avatarUpdatedAt': early.toIso8601String(),
      'future': {'nested': 1},
    });
    final remote = ProfileData(avatarUpdatedAt: late, extraJson: {'other': 2});
    final merged = mergeProfile(local, remote);
    expect(merged.name, 'Local');
    expect(merged.toJson()['avatar'], isNull);
    expect(merged.toJson()['future'], {'nested': 1});
    expect(merged.toJson()['other'], 2);
    expect(
      mergeProfileJson(encodeProfile(merged), encodeProfile(merged)),
      encodeProfile(merged),
    );
    expect(mergeProfile(local, local).name, local.name);
    expect(() => ProfileData.fromJson([]), throwsFormatException);
  });

  group('repository', () {
    late Directory root;
    late ProfileRepository repository;
    var notifications = 0;
    setUp(() async {
      root = await Directory.systemTemp.createTemp('myapps_profile_test');
      notifications = 0;
      repository = ProfileRepository(
        getAppDir: () async => root,
        writeJson: (file, text) async {
          final temporary = File('${file.path}.tmp');
          await temporary.writeAsString(text, flush: true);
          await temporary.rename(file.path);
        },
        onSaved: () => notifications++,
      );
    });
    tearDown(() async => root.delete(recursive: true));
    test('queued edits, unchanged name and corrupt-file recovery', () async {
      await Future.wait([
        repository.setName('  First  '),
        repository.update(
          (data) => data.withAvatar('images/avatar_a.jpg', early),
        ),
      ]);
      expect((await repository.load()).name, 'First');
      expect((await repository.load()).avatar, 'images/avatar_a.jpg');
      final file = File('${root.path}/profile.json');
      final before = await file.readAsString();
      await repository.setName('First');
      expect(await file.readAsString(), before);
      expect(notifications, 2);
      await file.writeAsString('{broken');
      await expectLater(
        repository.setName('Never overwrite'),
        throwsFormatException,
      );
      expect(await file.readAsString(), '{broken');
      await file.delete();
      await repository.setName('Recovered');
      expect((await repository.load()).name, 'Recovered');
    });
    test(
      'new avatar names and local cleanup preserve unrelated images',
      () async {
        final jpeg = squareAvatarJpeg(
          Uint8List.fromList(img.encodePng(img.Image(width: 40, height: 20))),
          512,
        );
        final first = await repository.setAvatarJpeg(jpeg);
        final second = await repository.setAvatarJpeg(jpeg);
        expect(first.avatar, isNot(second.avatar));
        expect(
          await (await repository.resolveImage(first.avatar!)).exists(),
          isFalse,
        );
        expect(await repository.readAvatarBytes(), jpeg);
        final unrelated = File('${root.path}/images/cover.jpg');
        await unrelated.writeAsBytes(jpeg);
        await repository.update(
          (data) => data.withAvatar('images/cover.jpg', late),
        );
        await repository.removeAvatar();
        expect(await unrelated.exists(), isTrue);
        expect(
          jsonDecode(
            await File('${root.path}/profile.json').readAsString(),
          )['avatar'],
          isNull,
        );
      },
    );
    test('missing synced image is readable after it arrives', () async {
      await repository.update(
        (data) => data.withAvatar('images/avatar_remote.jpg', early),
      );
      expect(await repository.readAvatarBytes(), isNull);
      final file = await repository.resolveImage('images/avatar_remote.jpg');
      await file.parent.create(recursive: true);
      await file.writeAsBytes([1, 2, 3]);
      expect(await repository.readAvatarBytes(), [1, 2, 3]);
    });
  });

  test(
    'image preparation, crop and isolate helpers preserve the chosen pixels',
    () async {
      final image = img.Image(width: 200, height: 100);
      img.fillRect(
        image,
        x1: 100,
        y1: 0,
        x2: 199,
        y2: 99,
        color: img.ColorRgb8(0, 0, 255),
      );
      final source = await prepareAvatarSourceInBackground(
        Uint8List.fromList(img.encodePng(image)),
      );
      final jpeg = await cropAvatarJpegInBackground(
        source.bytes,
        x: 100,
        y: 0,
        side: 100,
        size: 64,
      );
      final result = img.decodeJpg(jpeg)!;
      expect(result.width, 64);
      expect(result.getPixel(32, 32).b, greaterThan(200));
      expect(
        () => prepareAvatarSource(Uint8List.fromList([1, 2])),
        throwsFormatException,
      );
    },
  );

  testWidgets(
    'editor reports invalid input and cancel leaves without an image',
    (tester) async {
      const labels = AvatarEditorLabels(
        title: 'Edit',
        rotate: 'Rotate',
        reset: 'Reset',
        error: 'Invalid image',
        hint: 'Drag to frame',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showProfileAvatarEditor(
                context,
                Uint8List.fromList([1, 2, 3]),
                labels: labels,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Invalid image'), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
