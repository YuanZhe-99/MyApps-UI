# 接入

先将共享库提交和标签发布到两个远程。应用通过相对地址 `../MyApps-UI.git`
把子模块放在 `packages/myapps_ui`。
依赖路径分别为 `packages/myapps_ui/packages/myapps_ui` 和
`packages/myapps_ui/packages/myapps_adaptive`。克隆后初始化子模块。
应用原有文件重新导出公共枚举和布局函数；AppTheme 使用原品牌色调用 MyAppsTheme。
更新子模块指针前验证各应用；应用可分别升级。

发布前可使用被忽略的 `pubspec_overrides.yaml` 指向同级工作副本验证。
这些本机开发覆盖配置不得提交。
