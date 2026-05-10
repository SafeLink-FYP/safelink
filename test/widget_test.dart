// Smoke test — renders an isolated MaterialApp with a placeholder child
// so the test boots without invoking main.dart's Supabase / Hive init.
// Real screens that depend on those services are exercised by the rest
// of the test suite (e.g. severity_mapping_test.dart) which avoids
// pulling them in.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp boots without crashing', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Text('SafeLink')),
    ));
    expect(find.text('SafeLink'), findsOneWidget);
  });
}
