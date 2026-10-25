import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vyom_mobile/core/data/mock_data.dart';
import 'package:vyom_mobile/features/customer/presentation/nearby_shops_screen.dart';

void main() {
  testWidgets('NearbyShopsScreen renders neo-brutalist header, search, categories, and shops', (WidgetTester tester) async {
    MockData.enableMockData = true;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      MockData.enableMockData = false;
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: NearbyShopsScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify Top Bar Location & Filter
    expect(find.text('SHOPPING NEAR'), findsOneWidget);
    expect(find.text('Salt Lake, Kolkata'), findsOneWidget);

    // 2. Verify Yellow Hero Banner
    expect(find.text('LOCAL BOUTIQUES'), findsOneWidget);
    expect(find.text('GOOD FINDS.'), findsOneWidget);
    expect(find.text('RIGHT NEAR YOU.'), findsOneWidget);

    // 3. Verify Category Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Clothing'), findsOneWidget);
    expect(find.text('Footwear'), findsOneWidget);
    expect(find.text('Accessories'), findsOneWidget);

    // 4. Verify Search Field
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // 5. Verify Nearby Shops Section
    expect(find.text('NEARBY SHOPS'), findsOneWidget);
  });
}
