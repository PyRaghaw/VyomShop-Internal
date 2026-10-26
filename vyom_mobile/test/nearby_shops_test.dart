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
    expect(find.text('LOCAL SHOPS'), findsOneWidget);
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

  testWidgets('NearbyShopsScreen opens exact filter modal matching search results screen', (WidgetTester tester) async {
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

    // Tap the distance pill to open filter modal
    final distanceFilterTrigger = find.textContaining('km');
    expect(distanceFilterTrigger, findsWidgets);
    await tester.tap(distanceFilterTrigger.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify exact filter modal header
    expect(find.text('FILTERS'), findsOneWidget);
    expect(find.text('Find your perfect match'), findsOneWidget);

    // Verify Sections: CATEGORY, PRICE RANGE, DISTANCE
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('PRICE RANGE'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);

    // Verify distance options
    expect(find.text('Within 1 km'), findsOneWidget);
    expect(find.text('1 km to 3 km'), findsOneWidget);
    expect(find.text('3 km to 5 km'), findsOneWidget);
    expect(find.text('5 km to 10 km'), findsOneWidget);

    // Verify Action button
    expect(find.text('SHOW RESULT'), findsOneWidget);

    // Tap 'SHOW RESULT' to apply and close
    await tester.tap(find.text('SHOW RESULT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify modal dismissed and Nearby Shops screen visible
    expect(find.text('FILTERS'), findsNothing);
    expect(find.text('NEARBY SHOPS'), findsOneWidget);
  });
}

