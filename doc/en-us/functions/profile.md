# Profile API

| Source | Public declarations |
|---|---|
| profile_data.dart | ProfileData: fromJson, toJson, name, withName, withAvatar |
| profile_merge.dart | encodeProfile, mergeProfile, mergeProfileJson |
| avatar_image.dart | AvatarSource, prepareAvatarSource, cropAvatarJpeg, squareAvatarJpeg, background helpers |
| profile_repository.dart | ProfileRepository: load, update, setName, resolveImage, readAvatarBytes, setAvatarJpeg, removeAvatar |
| avatar_editor.dart | AvatarEditorLabels, ProfileAvatarEditorPage, showProfileAvatarEditor |
| profile_avatar.dart | MyAppsProfileAvatar |
| profile_header.dart | MyAppsProfileHeader |

Constructors bind immutable configuration without I/O. Model and merge functions
are pure and preserve unknown fields. Repository methods read/write through supplied
adapters; successful changed writes notify once. Image functions allocate output bytes;
background helpers spawn isolates. Editor state owns framing and returns bytes without
saving. Avatar and header builds resolve files or invoke supplied callbacks.
Private helpers parse UTC timestamps, collect unknown JSON, compare field times, decode
images and perform queued writes/local cleanup. See [../profile.md](../profile.md).
