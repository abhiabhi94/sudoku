import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/screens/home_screen.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('renders title, tiers and the games-completed stat', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpApp(tester, const HomeScreen());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sudoku'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
    expect(find.text('Expert'), findsOneWidget);
    expect(find.text('Games completed'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
