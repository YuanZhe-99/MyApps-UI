import 'package:flutter/material.dart';

/// An endpoint URL text field that validates its scheme and host.
class MyAppsEndpointField extends StatefulWidget {
  final String label;
  final String invalidText;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Set<String> allowedSchemes;
  final Widget? trailing;
  final bool enabled;
  final ValueChanged<Uri?>? onChanged;
  final ValueChanged<Uri?>? onSubmitted;

  /// Purpose: Construct an endpoint field bound to caller-owned configuration.
  /// Inputs: Label, invalid-input text, optional controller or initial text,
  /// hint/helper/error text, accepted schemes, trailing status widget, enabled
  /// flag and parsed-value callbacks.
  /// Returns: Endpoint field.
  /// Side effects: None.
  /// Notes: `errorText` from the caller takes precedence over `invalidText`;
  /// `initialValue` is ignored when a controller is supplied.
  const MyAppsEndpointField({
    super.key,
    required this.label,
    required this.invalidText,
    this.controller,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.errorText,
    this.allowedSchemes = const {'https', 'http'},
    this.trailing,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  /// Purpose: Parse endpoint text into an absolute URI.
  /// Inputs: Raw `text` and lower-case `allowedSchemes`.
  /// Returns: The parsed URI, or null when empty or invalid.
  /// Side effects: None.
  /// Notes: Requires an allowed scheme and a non-empty host; surrounding
  /// whitespace is ignored and inner whitespace is rejected.
  static Uri? parse(
    String text, {
    Set<String> allowedSchemes = const {'https', 'http'},
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.contains(RegExp(r'\s'))) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return allowedSchemes.contains(uri.scheme.toLowerCase()) ? uri : null;
  }

  /// Purpose: Create the mutable field state.
  /// Inputs: None.
  /// Returns: Endpoint field state.
  /// Side effects: None.
  /// Notes: State owns a controller only when the caller supplies none.
  @override
  State<MyAppsEndpointField> createState() => _MyAppsEndpointFieldState();
}

/// Mutable state holding an optional owned endpoint controller.
class _MyAppsEndpointFieldState extends State<MyAppsEndpointField> {
  TextEditingController? _ownedController;

  /// Purpose: Resolve the active text controller.
  /// Inputs: None.
  /// Returns: Caller or state-owned controller.
  /// Side effects: None.
  /// Notes: The owned controller exists whenever no controller is supplied.
  TextEditingController get _controller =>
      widget.controller ?? _ownedController!;

  /// Purpose: Create an owned controller when needed.
  /// Inputs: None.
  /// Returns: None.
  /// Side effects: Allocates a controller seeded with `initialValue`.
  /// Notes: Called once by the framework.
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController(text: widget.initialValue);
    }
  }

  /// Purpose: Follow controller changes between caller and owned instances.
  /// Inputs: Previous widget.
  /// Returns: None.
  /// Side effects: Allocates or disposes the owned controller.
  /// Notes: Owned text is preserved when switching back to an owned controller.
  @override
  void didUpdateWidget(MyAppsEndpointField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && _ownedController == null) {
      _ownedController = TextEditingController(
        text: oldWidget.controller?.text ?? widget.initialValue,
      );
    } else if (widget.controller != null && _ownedController != null) {
      _ownedController!.dispose();
      _ownedController = null;
    }
  }

  /// Purpose: Release the owned controller.
  /// Inputs: None.
  /// Returns: None.
  /// Side effects: Disposes the owned controller.
  /// Notes: Caller controllers remain caller-owned.
  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  /// Purpose: Parse the current text using the widget's accepted schemes.
  /// Inputs: Raw `text`.
  /// Returns: Parsed URI or null.
  /// Side effects: None.
  /// Notes: Scheme matching is case-insensitive.
  Uri? _parse(String text) => MyAppsEndpointField.parse(
    text,
    allowedSchemes: {for (final s in widget.allowedSchemes) s.toLowerCase()},
  );

  /// Purpose: Render the text field with inline validation.
  /// Inputs: `context`.
  /// Returns: Text field.
  /// Side effects: Forwards parsed values to the callbacks.
  /// Notes: Empty text shows no validation error.
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) {
          final invalid =
              value.text.trim().isNotEmpty && _parse(value.text) == null;
          return TextField(
            controller: _controller,
            enabled: widget.enabled,
            keyboardType: TextInputType.url,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText:
                  widget.errorText ?? (invalid ? widget.invalidText : null),
              suffixIcon: widget.trailing == null
                  ? null
                  : Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12),
                      child: widget.trailing,
                    ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
            onChanged: (text) => widget.onChanged?.call(_parse(text)),
            onSubmitted: (text) => widget.onSubmitted?.call(_parse(text)),
          );
        },
      );
}

/// An obscured secret or API key input with reveal and clear actions.
class MyAppsSecretField extends StatefulWidget {
  final String label;
  final String showTooltip;
  final String hideTooltip;
  final TextEditingController? controller;
  final bool hasSavedValue;
  final String savedPlaceholder;
  final String? clearTooltip;
  final VoidCallback? onClear;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Purpose: Construct a secret field without receiving any stored secret.
  /// Inputs: Label, reveal/hide tooltips, optional controller, saved-value flag
  /// and masked placeholder, clear tooltip and callback, helper/error text,
  /// enabled flag and text callbacks.
  /// Returns: Secret field.
  /// Side effects: None.
  /// Notes: A saved secret is represented only by `hasSavedValue`; the clear
  /// button appears when `onClear` and `clearTooltip` are supplied and there is
  /// typed text or a saved value.
  const MyAppsSecretField({
    super.key,
    required this.label,
    required this.showTooltip,
    required this.hideTooltip,
    this.controller,
    this.hasSavedValue = false,
    this.savedPlaceholder = '••••••••',
    this.clearTooltip,
    this.onClear,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  /// Purpose: Create the mutable field state.
  /// Inputs: None.
  /// Returns: Secret field state.
  /// Side effects: None.
  /// Notes: State holds visibility and an optional owned controller.
  @override
  State<MyAppsSecretField> createState() => _MyAppsSecretFieldState();
}

/// Mutable state holding visibility and an optional owned secret controller.
class _MyAppsSecretFieldState extends State<MyAppsSecretField> {
  TextEditingController? _ownedController;
  bool _obscured = true;

  /// Purpose: Resolve the active text controller.
  /// Inputs: None.
  /// Returns: Caller or state-owned controller.
  /// Side effects: None.
  /// Notes: The owned controller exists whenever no controller is supplied.
  TextEditingController get _controller =>
      widget.controller ?? _ownedController!;

  /// Purpose: Create an owned controller when needed.
  /// Inputs: None.
  /// Returns: None.
  /// Side effects: Allocates an empty controller.
  /// Notes: Called once by the framework.
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _ownedController = TextEditingController();
  }

  /// Purpose: Follow controller changes between caller and owned instances.
  /// Inputs: Previous widget.
  /// Returns: None.
  /// Side effects: Allocates or disposes the owned controller.
  /// Notes: A newly owned controller starts empty so secrets are not copied.
  @override
  void didUpdateWidget(MyAppsSecretField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && _ownedController == null) {
      _ownedController = TextEditingController();
    } else if (widget.controller != null && _ownedController != null) {
      _ownedController!.dispose();
      _ownedController = null;
    }
  }

  /// Purpose: Release the owned controller.
  /// Inputs: None.
  /// Returns: None.
  /// Side effects: Disposes the owned controller.
  /// Notes: Caller controllers remain caller-owned.
  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  /// Purpose: Clear typed text and notify the caller.
  /// Inputs: None.
  /// Returns: None.
  /// Side effects: Empties the controller, re-obscures and invokes `onClear`.
  /// Notes: Removing the stored secret is the caller's responsibility.
  void _clear() {
    _controller.clear();
    setState(() => _obscured = true);
    widget.onClear?.call();
  }

  /// Purpose: Render the obscured field and its actions.
  /// Inputs: `context`.
  /// Returns: Text field.
  /// Side effects: Forwards text and actions to callbacks.
  /// Notes: Disables suggestions, autocorrect and IME learning; never logs text.
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) {
          final empty = value.text.isEmpty;
          final canClear =
              widget.onClear != null &&
              widget.clearTooltip != null &&
              (!empty || widget.hasSavedValue);
          return TextField(
            controller: _controller,
            enabled: widget.enabled,
            obscureText: _obscured,
            autocorrect: false,
            enableSuggestions: false,
            enableIMEPersonalizedLearning: false,
            keyboardType: TextInputType.visiblePassword,
            smartDashesType: SmartDashesType.disabled,
            smartQuotesType: SmartQuotesType.disabled,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hasSavedValue && empty
                  ? widget.savedPlaceholder
                  : null,
              floatingLabelBehavior: widget.hasSavedValue
                  ? FloatingLabelBehavior.always
                  : null,
              helperText: widget.helperText,
              errorText: widget.errorText,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: _obscured
                        ? widget.showTooltip
                        : widget.hideTooltip,
                    isSelected: !_obscured,
                    icon: const Icon(Icons.visibility_outlined),
                    selectedIcon: const Icon(Icons.visibility_off_outlined),
                    onPressed: widget.enabled && !empty
                        ? () => setState(() => _obscured = !_obscured)
                        : null,
                  ),
                  if (canClear)
                    IconButton(
                      tooltip: widget.clearTooltip,
                      icon: const Icon(Icons.clear),
                      onPressed: widget.enabled ? _clear : null,
                    ),
                ],
              ),
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          );
        },
      );
}

/// The state shown by [MyAppsConnectionTestRow].
enum MyAppsConnectionTestStatus {
  /// No test has run or the result was reset.
  idle,

  /// A caller-owned test is in progress.
  testing,

  /// The last test succeeded.
  success,

  /// The last test failed; the caller supplies the message.
  failure,
}

/// A settings row that starts a caller-owned connection test and shows its state.
class MyAppsConnectionTestRow extends StatelessWidget {
  final String title;
  final String testLabel;
  final MyAppsConnectionTestStatus status;
  final String? message;
  final VoidCallback? onTest;

  /// Purpose: Construct a connection-test row for caller-owned test state.
  /// Inputs: Title, test button label, status, optional status message and
  /// test callback.
  /// Returns: Connection test row.
  /// Side effects: None.
  /// Notes: The caller performs the test and supplies localized messages;
  /// a null `onTest` disables the button.
  const MyAppsConnectionTestRow({
    super.key,
    required this.title,
    required this.testLabel,
    required this.status,
    this.message,
    this.onTest,
  });

  /// Purpose: Render the status indicator, text and test button.
  /// Inputs: `context`.
  /// Returns: List tile.
  /// Side effects: Invokes `onTest` when the button is pressed.
  /// Notes: The button is disabled while testing; the message is a live region.
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final indicator = switch (status) {
      MyAppsConnectionTestStatus.idle => Icon(
        Icons.network_check,
        color: scheme.onSurfaceVariant,
      ),
      MyAppsConnectionTestStatus.testing => const SizedBox.square(
        dimension: 24,
        child: Padding(
          padding: EdgeInsets.all(2),
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
      MyAppsConnectionTestStatus.success => Icon(
        Icons.check_circle_outline,
        color: scheme.primary,
      ),
      MyAppsConnectionTestStatus.failure => Icon(
        Icons.error_outline,
        color: scheme.error,
      ),
    };
    return ListTile(
      leading: ExcludeSemantics(child: indicator),
      title: Text(title),
      subtitle: message == null
          ? null
          : Semantics(
              liveRegion: true,
              child: Text(
                message!,
                style: status == MyAppsConnectionTestStatus.failure
                    ? TextStyle(color: scheme.error)
                    : null,
              ),
            ),
      trailing: OutlinedButton(
        onPressed: status == MyAppsConnectionTestStatus.testing ? null : onTest,
        child: Text(testLabel),
      ),
    );
  }
}

/// The emphasis of a [MyAppsPrivacyNotice].
enum MyAppsNoticeSeverity {
  /// Neutral disclosure using secondary-container colors.
  info,

  /// Elevated risk using error-container colors.
  warning,
}

/// A disclosure banner with icon, title, body and an optional action.
class MyAppsPrivacyNotice extends StatelessWidget {
  final String title;
  final String body;
  final MyAppsNoticeSeverity severity;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Purpose: Construct a disclosure banner with caller-supplied wording.
  /// Inputs: Title, body, severity, optional icon and action label/callback.
  /// Returns: Notice banner.
  /// Side effects: None.
  /// Notes: The action appears only when both label and callback are supplied;
  /// the default icon follows the severity.
  const MyAppsPrivacyNotice({
    super.key,
    required this.title,
    required this.body,
    this.severity = MyAppsNoticeSeverity.info,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  /// Purpose: Render the themed notice.
  /// Inputs: `context`.
  /// Returns: Padded card.
  /// Side effects: Invokes `onAction` when the action is pressed.
  /// Notes: Warning uses error-container colors; info uses secondary-container.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final warning = severity == MyAppsNoticeSeverity.warning;
    final background = warning
        ? scheme.errorContainer
        : scheme.secondaryContainer;
    final foreground = warning
        ? scheme.onErrorContainer
        : scheme.onSecondaryContainer;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card.filled(
        margin: EdgeInsets.zero,
        color: background,
        child: Semantics(
          container: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: IconTheme.merge(
                        data: IconThemeData(color: foreground),
                        child:
                            icon ??
                            Icon(
                              warning
                                  ? Icons.warning_amber_outlined
                                  : Icons.info_outline,
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: foreground,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (actionLabel != null && onAction != null)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      style: TextButton.styleFrom(foregroundColor: foreground),
                      onPressed: onAction,
                      child: Text(actionLabel!),
                    ),
                  ),
                if (actionLabel == null || onAction == null)
                  const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
