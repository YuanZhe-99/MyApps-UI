# 导航接口

| 声明 | 用途 |
|---|---|
| MyAppsDestination | 应用提供的图标组件和本地化标签 |
| MyAppsNavigationShell | 在固定内容位置周围绘制底部或侧边导航 |
| MyAppsShellLayout | 提供实际内容宽度和侧栏占用 |
| MyAppsShellLayout.maybeOf | 读取布局并订阅变化，导航壳外返回 null |
| MyAppsShellLayout.updateShouldNotify | 宽度或侧栏占用变化时通知 |
| MyAppsNavigationShell.build | 判断位置、绘制导航并测量内容 |
| MyAppsNavigationShell._rail | 字号适配宽度、可滚动的侧栏和分隔线 |
| _ExpressiveNavBar | 原有紧凑悬浮胶囊绘制 |
| _ExpressiveNavItem | 选中标签、语义状态和提示 |

构造器创建组件或描述对象，无副作用。绘制只调用应用提供的选择回调。
内部底栏和条目的 build 方法读取当前主题，保留悬浮导航的键和动画。
约束和状态归属见 [../navigation.md](../navigation.md)。
