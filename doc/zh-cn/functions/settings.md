# 设置接口

## 声明

| Declaration | Responsibility |
|---|---|
| MyAppsSettingsSection constructor/build | 绑定标题间距，显示应用提供的行 |
| MyAppsSettingsSegments constructor/build | 显示并转发单选，不保存设置 |
| MyAppsSettingsChoice constructor/build | 绑定值、标签、帮助和应用宽度/数量策略 |
| MyAppsSettingsChoice._segmented/_dropdown | 显示选定模式并转发启用的选择 |
| tool/common_l10n.py synchronize/main | 验证或应用公共 ARB 值，提供 CLI 检查与写入模式 |

构造器无副作用。构建读取主题和尺寸约束，用户选择触发回调。目录同步读取应用支持
的全部语言文件，报告缺失或不同的值，只有明确的写入模式才修改文件。其他条目及
元数据仍由应用维护。见 [../settings.md](../settings.md)。
