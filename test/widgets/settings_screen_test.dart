import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/providers/settings_provider.dart';
import 'package:sudoku/screens/settings_screen.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('toggling vibration updates settings state', (tester) async {
    final container = await pumpApp(tester, const SettingsScreen());
    expect(container.read(settingsProvider).hapticsOn, isTrue);

    // Music switch is first, vibration second.
    await tester.tap(find.byType(Switch).at(1));
    await tester.pump();
    expect(container.read(settingsProvider).hapticsOn, isFalse);
  });

  testWidgets('choosing Hindi updates the language', (tester) async {
    final container = await pumpApp(tester, const SettingsScreen());
    expect(container.read(settingsProvider).languageCode, 'en');

    await tester.tap(find.text('हिन्दी'));
    await tester.pump();
    expect(container.read(settingsProvider).languageCode, 'hi');
  });
}
