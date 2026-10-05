# 主题接口

`MyAppsTheme(seedColor: ...)`: `scheme`, `build`, `light`, `dark`。
`MyAppsTheme.applyStyle(base, style)` 在自定义基础主题上应用公共风格，
保留卡片颜色、高度和输入框密度。

`AppUiStyle`: `material3`, `expressive`. `NavPlacement`: `bottom`, `sideOnWide`, `side`.

内部函数负责按钮形状变化、字体强调和 Expressive 组件覆盖。
所有方法只构造主题对象；持久化和导航由调用方负责。
