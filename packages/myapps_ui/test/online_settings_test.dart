import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapps_ui/myapps_ui.dart';

/// Purpose: Wrap a widget in a minimal Material application.
/// Inputs: `child` and optional text direction.
/// Returns: Test application.
/// Side effects: None.
/// Notes: No application state or providers are involved.
Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(body: ListView(children: [child])),
      ),
    );

/// Purpose: Verify online settings primitives.
/// Inputs: None.
/// Returns: None.
/// Side effects: Registers widget tests.
/// Notes: Tests use caller-owned callbacks only; no network access occurs.
void main() {
  test('endpoint parsing requires an allowed scheme and host', () {
    expect(
      MyAppsEndpointField.parse(' https://api.example.com/v1 '),
      Uri.parse('https://api.example.com/v1'),
    );
    expect(MyAppsEndpointField.parse('HTTP://10.0.0.2:8080'), isNotNull);
    expect(MyAppsEndpointField.parse('api.example.com'), isNull);
    expect(MyAppsEndpointField.parse('ftp://example.com'), isNull);
    expect(MyAppsEndpointField.parse('https://'), isNull);
    expect(MyAppsEndpointField.parse('https://a b.com'), isNull);
    expect(MyAppsEndpointField.parse(''), isNull);
    expect(
      MyAppsEndpointField.parse(
        'http://example.com',
        allowedSchemes: const {'https'},
      ),
      isNull,
    );
  });

  testWidgets('endpoint field validates inline and reports parsed URIs', (
    tester,
  ) async {
    final reported = <Uri?>[];
    await tester.pumpWidget(
      _app(
        MyAppsEndpointField(
          label: 'Endpoint',
          invalidText: 'Invalid URL',
          trailing: const Icon(Icons.check, key: Key('status')),
          onChanged: reported.add,
        ),
      ),
    );
    expect(find.byKey(const Key('status')), findsOneWidget);
    expect(find.text('Invalid URL'), findsNothing);
    await tester.enterText(find.byType(TextField), 'not a url');
    await tester.pump();
    expect(find.text('Invalid URL'), findsOneWidget);
    expect(reported.last, isNull);
    await tester.enterText(find.byType(TextField), 'https://example.com');
    await tester.pump();
    expect(find.text('Invalid URL'), findsNothing);
    expect(reported.last, Uri.parse('https://example.com'));
  });

  testWidgets('endpoint field prefers caller error text', (tester) async {
    await tester.pumpWidget(
      _app(
        const MyAppsEndpointField(
          label: 'Endpoint',
          invalidText: 'Invalid URL',
          initialValue: 'https://example.com',
          errorText: 'Insecure endpoint',
        ),
      ),
    );
    expect(find.text('Insecure endpoint'), findsOneWidget);
    expect(find.text('Invalid URL'), findsNothing);
  });

  testWidgets('secret field obscures by default and toggles visibility', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const MyAppsSecretField(
          label: 'API key',
          showTooltip: 'Show key',
          hideTooltip: 'Hide key',
        ),
      ),
    );
    EditableText editable() =>
        tester.widget<EditableText>(find.byType(EditableText));
    expect(editable().obscureText, isTrue);
    expect(editable().enableSuggestions, isFalse);
    expect(editable().autocorrect, isFalse);
    await tester.enterText(find.byType(TextField), 'sk-test');
    await tester.pump();
    await tester.tap(find.byTooltip('Show key'));
    await tester.pump();
    expect(editable().obscureText, isFalse);
    expect(find.byTooltip('Hide key'), findsOneWidget);
    await tester.tap(find.byTooltip('Hide key'));
    await tester.pump();
    expect(editable().obscureText, isTrue);
  });

  testWidgets('saved secret shows a placeholder without a real value', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const MyAppsSecretField(
          label: 'API key',
          showTooltip: 'Show key',
          hideTooltip: 'Hide key',
          hasSavedValue: true,
          savedPlaceholder: 'Saved key',
        ),
      ),
    );
    expect(find.text('Saved key'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    final toggle = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.visibility_outlined),
    );
    expect(toggle.onPressed, isNull);
  });

  testWidgets('secret clear empties text and notifies the caller', (
    tester,
  ) async {
    var cleared = 0;
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    Widget field(bool saved) => _app(
      MyAppsSecretField(
        label: 'API key',
        showTooltip: 'Show key',
        hideTooltip: 'Hide key',
        controller: controller,
        hasSavedValue: saved,
        clearTooltip: 'Clear key',
        onClear: () => cleared++,
      ),
    );
    await tester.pumpWidget(field(false));
    expect(find.byTooltip('Clear key'), findsNothing);
    await tester.enterText(find.byType(TextField), 'sk-test');
    await tester.pump();
    await tester.tap(find.byTooltip('Clear key'));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(cleared, 1);
    await tester.pumpWidget(field(true));
    await tester.tap(find.byTooltip('Clear key'));
    expect(cleared, 2);
  });

  testWidgets('connection test row reflects every status', (tester) async {
    var tests = 0;
    Widget row(MyAppsConnectionTestStatus status, [String? message]) => _app(
      MyAppsConnectionTestRow(
        title: 'Connection',
        testLabel: 'Test',
        status: status,
        message: message,
        onTest: () => tests++,
      ),
    );
    await tester.pumpWidget(row(MyAppsConnectionTestStatus.idle));
    expect(find.byIcon(Icons.network_check), findsOneWidget);
    await tester.tap(find.text('Test'));
    expect(tests, 1);

    await tester.pumpWidget(row(MyAppsConnectionTestStatus.testing));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Test'));
    expect(tests, 1);

    await tester.pumpWidget(row(MyAppsConnectionTestStatus.success, 'OK'));
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);

    await tester.pumpWidget(
      row(MyAppsConnectionTestStatus.failure, 'Unauthorized'),
    );
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Unauthorized'), findsOneWidget);
    await tester.tap(find.text('Test'));
    expect(tests, 2);
  });

  testWidgets('privacy notice renders severity and forwards its action', (
    tester,
  ) async {
    var actions = 0;
    await tester.pumpWidget(
      _app(
        MyAppsPrivacyNotice(
          title: 'Data leaves this device',
          body: 'Content is sent to the configured service.',
          severity: MyAppsNoticeSeverity.warning,
          actionLabel: 'Review',
          onAction: () => actions++,
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    expect(find.text('Data leaves this device'), findsOneWidget);
    await tester.tap(find.text('Review'));
    expect(actions, 1);

    await tester.pumpWidget(
      _app(const MyAppsPrivacyNotice(title: 'Notice', body: 'Body')),
    );
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('online primitives meet tap target guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            MyAppsSecretField(
              label: 'API key',
              showTooltip: 'Show key',
              hideTooltip: 'Hide key',
              hasSavedValue: true,
              clearTooltip: 'Clear key',
              onClear: () {},
            ),
            MyAppsConnectionTestRow(
              title: 'Connection',
              testLabel: 'Test',
              status: MyAppsConnectionTestStatus.idle,
              onTest: () {},
            ),
            MyAppsPrivacyNotice(
              title: 'Notice',
              body: 'Body',
              actionLabel: 'Review',
              onAction: () {},
            ),
          ],
        ),
      ),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
