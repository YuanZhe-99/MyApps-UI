# 分区接口

| Declaration | Responsibility |
|---|---|
| MyAppsPaneLayout constructor | 绑定应用控件、条件、宽度和内容矩形 |
| MyAppsPaneBody constructor/build | 将应用页面内容和导航壳原点适配为分区几何 |
| MyAppsPaneLayout.build | 划分分隔特征、验证容量并报告实际模式 |
| MyAppsPaneLayout._pane | 定位稳定栏并提供局部 MediaQuery |
| MyAppsRegionLayout constructor/build/_regions | 自动、按数量或按归一化设计排列任意子项 |

构造无副作用，布局向调用方报告实际分栏模式。
见 [分区约定](../panes.md)。MyAppsShellLayout.contentBounds 提供导航壳扣除导航
后的窗口坐标，updateShouldNotify 包括矩形变动。
