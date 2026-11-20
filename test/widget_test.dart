import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:universitas_boash_academic/main.dart';

void main() {
  testWidgets('login screen shows university branding and fields', (
    tester,
  ) async {
    await tester.pumpWidget(const BoashApp());
    await tester.pumpAndSettle();

    expect(find.text('UNIVERSITAS BOASH'), findsOneWidget);
    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      isEmpty,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller?.text,
      isEmpty,
    );
    await tester.enterText(find.byType(TextField).first, '24903460047');
    await tester.tap(find.text('Gunakan NPM sebagai password'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller?.text,
      '24903460047',
    );
  });
}
