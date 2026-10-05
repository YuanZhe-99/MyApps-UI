# 接入

先将共享库提交和标签发布到两个远程。应用通过相对地址 `../MyApps-UI.git`
把子模块放在 `packages/myapps_ui`。
依赖路径分别为 `packages/myapps_ui/packages/myapps_ui` 和
`packages/myapps_ui/packages/myapps_adaptive`。克隆后初始化子模块。
应用原有文件重新导出公共枚举和布局函数；AppTheme 使用原品牌色调用 MyAppsTheme。
更新子模块指针前验证各应用；应用可分别升级。

发布前可使用被忽略的 `pubspec_overrides.yaml` 指向同级工作副本验证。
这些本机开发覆盖配置不得提交。

资料使用方添加 `packages/myapps_ui/packages/myapps_profile` 路径依赖。
原资料导入作为重新导出包装，存储和 UI 入口作为适配保留。
不需要资料组件的应用可以省略此依赖。

设置使用方按需接入 `myapps_ui` 的独立控件，应用状态和路由保持不变。
采用 ARB 的应用运行 `python3 packages/myapps_ui/tool/common_l10n.py --check .`
检查公共值。使用其他本地化系统的应用可以只接入控件，不使用 ARB 工具。

选用的包、适配器和应用专用策略记录在应用自身文档中。共享文档描述可复用契约。
