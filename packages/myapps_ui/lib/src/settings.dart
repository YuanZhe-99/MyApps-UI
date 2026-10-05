import 'package:flutter/material.dart';

/// A heading followed by application-owned settings rows.
class MyAppsSettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry headingPadding;

  /// Purpose: Construct a settings group without owning its state.
  /// Inputs: Title, children and optional heading spacing.
  /// Returns: Settings section.
  /// Side effects: None.
  /// Notes: Applications may preserve their original spacing.
  const MyAppsSettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.headingPadding = const EdgeInsets.fromLTRB(16, 16, 16, 4),
  });

  /// Purpose: Render the themed heading and supplied rows.
  /// Inputs: `context`.
  /// Returns: A column.
  /// Side effects: None.
  /// Notes: The caller supplies scrolling.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: headingPadding,
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// A single-choice settings control with application-defined values and labels.
class MyAppsSettingsSegments<T> extends StatelessWidget {
  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool showSelectedIcon;

  /// Purpose: Bind a Material segmented control to caller-owned state.
  /// Inputs: Options, current selection, callback and selection-icon visibility.
  /// Returns: A settings control.
  /// Side effects: None.
  /// Notes: Null callbacks disable selection; exactly one option is selected.
  const MyAppsSettingsSegments({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.showSelectedIcon = true,
  });

  /// Purpose: Render a single-choice Material control.
  /// Inputs: `context`.
  /// Returns: A segmented button.
  /// Side effects: Forwards user selections to the supplied callback.
  /// Notes: Enum values and localization remain caller-owned.
  @override
  Widget build(BuildContext context) => SegmentedButton<T>(
    segments: segments,
    selected: selected,
    showSelectedIcon: showSelectedIcon,
    onSelectionChanged: onSelectionChanged,
  );
}

/// A labelled choice that uses a dropdown when the caller's segment policy fails.
class MyAppsSettingsChoice<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final String Function(T value)? helpFor;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final double segmentMinWidth;
  final int maxSegments;

  /// Purpose: Construct a labelled choice with optional contextual help.
  /// Inputs: Labels, values, callback, enabled flag and segment policy.
  /// Returns: A settings choice.
  /// Side effects: None.
  /// Notes: The application chooses width and option-count limits.
  const MyAppsSettingsChoice({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
    required this.segmentMinWidth,
    required this.maxSegments,
    this.helpFor,
    this.enabled = true,
  });

  /// Purpose: Render the label, responsive choice and selection help.
  /// Inputs: `context`.
  /// Returns: Padded choice column.
  /// Side effects: None until selected.
  /// Notes: Reads actual parent constraints.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final help = helpFor?.call(value) ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) =>
                values.length <= maxSegments &&
                    constraints.maxWidth >= segmentMinWidth
                ? _segmented()
                : _dropdown(),
          ),
          if (help.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              help,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Purpose: Build the choice as segments.
  /// Inputs: None.
  /// Returns: Segmented control.
  /// Side effects: Invokes onChanged on selection.
  /// Notes: Disabled controls have no callback.
  Widget _segmented() => MyAppsSettingsSegments<T>(
    segments: [
      for (final option in values)
        ButtonSegment<T>(value: option, label: Text(labelFor(option))),
    ],
    selected: {value},
    showSelectedIcon: false,
    onSelectionChanged: enabled
        ? (selection) => onChanged(selection.first)
        : null,
  );

  /// Purpose: Build the choice as a full-width dropdown.
  /// Inputs: None.
  /// Returns: Dropdown form field.
  /// Side effects: Invokes onChanged on non-null selection.
  /// Notes: Retains Material form-field initial-value behavior.
  Widget _dropdown() => DropdownButtonFormField<T>(
    initialValue: value,
    isExpanded: true,
    decoration: const InputDecoration(border: OutlineInputBorder()),
    items: [
      for (final option in values)
        DropdownMenuItem<T>(
          value: option,
          child: Text(labelFor(option), overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: enabled
        ? (selected) {
            if (selected != null) onChanged(selected);
          }
        : null,
  );
}
