# 资料接口

| Source | Public declarations |
|---|---|
| profile_data.dart | ProfileData: fromJson, toJson, name, withName, withAvatar |
| profile_merge.dart | encodeProfile, mergeProfile, mergeProfileJson |
| avatar_image.dart | AvatarSource, prepareAvatarSource, cropAvatarJpeg, squareAvatarJpeg, background helpers |
| profile_repository.dart | ProfileRepository: load, update, setName, resolveImage, readAvatarBytes, setAvatarJpeg, removeAvatar |
| avatar_editor.dart | AvatarEditorLabels, ProfileAvatarEditorPage, showProfileAvatarEditor |
| profile_avatar.dart | MyAppsProfileAvatar |
| profile_header.dart | MyAppsProfileHeader |

构造器绑定配置但不执行 I/O。模型和合并函数无副作用并保留未知字段。
存储方法通过适配器读写，成功且实际变化的保存只通知一次。图片函数分配输出字节，
后台函数启动隔离执行。编辑状态负责取景并返回字节，不保存文件。头像和标题组件
解析图片或调用传入回调。内部函数负责 UTC 解析、未知字段收集、时间比较、图片
解码、串行写入及本机清理。见 [../profile.md](../profile.md)。
