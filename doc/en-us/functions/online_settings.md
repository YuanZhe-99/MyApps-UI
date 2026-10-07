# Online settings API

## Declarations

| Declaration | Responsibility |
|---|---|
| MyAppsEndpointField constructor/parse | Bind endpoint text and validate scheme/host into a `Uri` |
| MyAppsEndpointField state init/update/dispose/build | Own a fallback controller, show inline errors and forward parsed values |
| MyAppsSecretField constructor | Bind labels, saved-value flag, clear action and text callbacks |
| MyAppsSecretField state init/update/dispose/_clear/build | Own visibility and fallback controller, clear typed text and render actions |
| MyAppsConnectionTestStatus | Idle, testing, success and failure states |
| MyAppsConnectionTestRow constructor/build | Render caller-owned test state and forward test requests |
| MyAppsNoticeSeverity | Info and warning emphasis |
| MyAppsPrivacyNotice constructor/build | Render a themed disclosure and forward its action |

Constructors have no side effects. Builds read theme and controller values; user
input invokes callbacks. Owned controllers are disposed with their state; caller
controllers remain caller-owned. No declaration stores, logs or transmits values.
See [../settings.md](../settings.md).
