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
    expect(find.text('NEIGHBOURHOOD BOUTIQUES'), findsOneWidget);
    expect(find.text('Explore shops right around your corner.'), findsOneWidget);

    // 3. Verify Category Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Clothing'), findsOneWidget);
    expect(find.text('Footwear'), findsOneWidget);
    expect(find.text('Accessories'), findsOneWidget);

    // 4. Verify Search Field
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // 5. Test Search Filtering with nonexistent query
    await tester.enterText(searchField, 'NoBoutiqueName12345');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('No Boutiques Found'), findsOneWidget);
    expect(find.text('Reset Filters'), findsOneWidget);

    // 6. Reset Filters tap
    await tester.tap(find.text('Reset Filters'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('No Boutiques Found'), findsNothing);
  });
}
