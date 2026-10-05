# 架构

三个包在同一仓库中开发并使用统一版本。`myapps_ui` 只依赖 Flutter；
`myapps_adaptive` 只使用 Dart 核心库。它们不负责持久化、路由、本地化或 Riverpod 状态。
应用保留公开主题包装和布局入口，提供品牌色以及业务页面的尺寸约束。

P2 共享导航绘制和实际内容空间，见 [navigation.md](navigation.md)。
`myapps_profile` 通过适配提供资料和头像组件，见 [profile.md](profile.md)。
MyApps-DATA 继续负责同步、备份和传输引擎。
