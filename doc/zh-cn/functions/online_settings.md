# 在线设置接口

## 声明

| Declaration | Responsibility |
|---|---|
| MyAppsEndpointField constructor/parse | 绑定端点文本，验证协议和主机名并得到 `Uri` |
| MyAppsEndpointField state init/update/dispose/build | 维护备用控制器，显示内联错误并转发解析结果 |
| MyAppsSecretField constructor | 绑定标签、已保存标志、清除操作和文本回调 |
| MyAppsSecretField state init/update/dispose/_clear/build | 维护可见性和备用控制器，清除已输入文本并呈现操作 |
| MyAppsConnectionTestStatus | 空闲、测试中、成功和失败状态 |
| MyAppsConnectionTestRow constructor/build | 显示调用方维护的测试状态并转发测试请求 |
| MyAppsNoticeSeverity | 信息和警告级别 |
| MyAppsPrivacyNotice constructor/build | 显示主题化披露并转发其操作 |

构造器无副作用。构建读取主题和控制器值，用户输入触发回调。自有控制器随状态释放；
调用方控制器仍由调用方管理。所有声明都不保存、记录或传输值。
见 [../settings.md](../settings.md)。
