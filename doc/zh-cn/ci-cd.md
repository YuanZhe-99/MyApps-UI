# 验证与发布

CI 使用 Flutter 3.47.6 验证三个包：解析依赖、检查格式、静态分析，
UI 和资料包运行 Flutter 测试，布局包运行 Dart 测试。
发布前在本地运行相同检查。抽取代码使用 GPL-3.0。
同时运行 `python3 tool/check_docs.py` 和 `python3 tool/test_common_l10n.py`。
使用方在现有 Flutter 测试流程中检查公共 ARB 值。
公共包使用统一标签版本，先发布到两个远程再更新应用；
抽取里程碑完成后，应用补丁版本增加 0.0.1。
只有实际检查过远程运行结果后，才能宣称 CI 通过。
