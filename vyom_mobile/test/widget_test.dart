import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vyom_mobile/main.dart';

void main() {
  testWidgets('VyomApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: VyomApp(),
      ),
    );
    expect(find.text('VYOM'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
