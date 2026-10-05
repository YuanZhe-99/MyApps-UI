# Pane API

| Declaration | Responsibility |
|---|---|
| MyAppsPaneLayout constructor | Bind app widgets, gate, widths and content bounds |
| MyAppsPaneBody constructor/build | Adapt app scaffold body and shell origin to pane geometry |
| MyAppsPaneLayout.build | Partition separators, validate capacities, report effective mode |
| MyAppsPaneLayout._pane | Position a stable pane and provide local MediaQuery |
| MyAppsRegionLayout constructor/build/_regions | Pack arbitrary children automatically, by count or by normalized design |

Construction has no side effects; layout reports effective split mode to the caller.
See [pane contracts](../panes.md). MyAppsShellLayout.contentBounds supplies window
coordinates after shell navigation; updateShouldNotify includes bounds changes.
