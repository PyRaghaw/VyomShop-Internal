import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vyom_mobile/core/data/mock_data.dart';
import 'package:vyom_mobile/features/customer/presentation/ai_matching_results_screen.dart';

void main() {
  testWidgets('AiMatchingResultsScreen strict footwear logic and UI test', (WidgetTester tester) async {
    MockData.enableMockData = true;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      MockData.enableMockData = false;
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: AiMatchingResultsScreen(
          queryImageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify Top App Bar
    expect(find.text('MATCHING RESULTS'), findsOneWidget);
    expect(find.text('Found based on your photo.'), findsOneWidget);

    // 2. Verify Visual Matches Card
    expect(find.text('Visual Matches'), findsOneWidget);
    expect(find.text('CHANGE'), findsOneWidget);

    // 3. Verify Products found section header and Products tab
    expect(find.text('PRODUCTS FOUND'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Shops'), findsOneWidget);

    // 4. Verify ONLY footwear products are shown
    expect(find.text('Everyday Canvas Shoes'), findsOneWidget);
    expect(find.text('Suede Low-Tops'), findsOneWidget);
    expect(find.text('Retro Street Sneakers'), findsOneWidget);
    expect(find.text('Brown classic sneakers'), findsOneWidget);

    // Verify non-footwear products like t-shirt, jacket are NOT present
    expect(find.text('Classic White Tee'), findsNothing);
    expect(find.text('Denim Trucker Jacket'), findsNothing);

    // 5. Test Search Filtering (Empty state test)
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'nonexistentxyz');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify empty state is displayed
    expect(find.text('NO MATCHING PRODUCTS FOUND'), findsOneWidget);
    expect(find.text('Reset Search'), findsOneWidget);

    // Test Reset Search button
    await tester.tap(find.text('Reset Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify products are restored
    expect(find.text('Everyday Canvas Shoes'), findsOneWidget);

    // 6. Test Switching to Shops Tab
    await tester.tap(find.text('Shops'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('SHOPS FOUND'), findsOneWidget);
    expect(find.text('Sole Zone'), findsOneWidget);
    expect(find.text('Walkabout'), findsOneWidget);
  });
}
