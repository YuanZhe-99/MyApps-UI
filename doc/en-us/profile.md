# Profile and avatar

`myapps_profile` owns the profile model, field merge, serialized updates, avatar
image processing, circular rendering and editor. It depends on Flutter, image,
path and uuid, with no Riverpod, router, sync-engine or platform-picker dependency.

## Application boundary

`ProfileRepository` receives the active storage root, atomic JSON writer and saved
notification. Image resolution/deletion callbacks preserve an app's image-service
behavior. Applications retain their static ProfileStore facade, picker, Riverpod
notifier, data-module registry and localized profile dialog. Shared avatar rendering
accepts a file resolver; the editor receives explicit localized labels. A shared
header view accepts the avatar, name, labels and edit callback.

## Compatibility

`profile.json` remains version 1 with separate UTC name/avatar timestamps. Ties
keep local values; timestamped null removals sync. Unknown fields survive read,
merge and write. Pretty JSON from local writes and merges is identical. Unreadable
profiles may display an empty placeholder, but updates never overwrite their bytes.
Each avatar is a new 512-square JPEG, quality 88, under `images/avatar_<uuid>.jpg`.
Only the replaced avatar is deleted locally; remote garbage collection is unchanged.
Application profiles remain separate: sharing code does not share identities.

## Validation

Package tests cover old JSON, independent field merges, queued updates, corrupt-file
protection, image processing, delayed image arrival and editor cancellation/error.
Application profile, sync, restore and widget suites verify adapters and module order.
