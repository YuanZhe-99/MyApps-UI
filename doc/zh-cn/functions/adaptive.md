# 布局接口

`resolveLayoutColumns` 根据分栏条件、实际宽度、最小条目宽度、间距和上限决定
自动或用户选择的列数。零表示自动，其他值只在显示时限制，不修改应用存储。

`canSplitLayout(width, height)`, `useNavigationRail(screenWidth)`,
`columnCapacity(contentWidth, minItemWidth: ..., gap: ..., maxColumns: ...)`,
`listRowCount(itemCount, columns)`.

导出分屏、导航和列表常量。非正内容宽度返回一列；非正最小宽度返回列数上限。
空列表需要零行。函数无副作用；调用方提供逻辑像素尺寸和业务约束。
