import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vyom_mobile/core/data/mock_data.dart';
import 'package:vyom_mobile/features/customer/presentation/customer_registration_screen.dart';

void main() {
  testWidgets('CustomerRegistrationScreen renders all form fields and neo-brutalist CTA', (WidgetTester tester) async {
    MockData.enableMockData = true;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      MockData.enableMockData = false;
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CustomerRegistrationScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify Headlines & Subtitle
    expect(find.text('CUSTOMER ONBOARDING'), findsOneWidget);
    expect(find.text('EXPLORE LOCAL'), findsOneWidget);
    expect(find.text('SHOPS'), findsOneWidget);
    expect(find.text('Tell us a bit about you to discover nearby gems'), findsOneWidget);

    // 2. Verify Form Labels
    expect(find.text('Your full name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Email address (optional)'), findsOneWidget);
    expect(find.text('Primary shopping area'), findsOneWidget);
    expect(find.text('Favorite categories to explore'), findsOneWidget);

    // 3. Verify Categories
    expect(find.text('Clothing'), findsOneWidget);
    expect(find.text('Footwear'), findsOneWidget);
    expect(find.text('Accessories'), findsOneWidget);
    expect(find.text('Jewellery'), findsOneWidget);

    // 4. Verify Start Shopping Button
    expect(find.text('START SHOPPING'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);

    // 5. Test entering customer data and tapping Start Shopping
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(3));

    await tester.enterText(textFields.at(0), 'Raghaw Shukla');
    await tester.enterText(textFields.at(1), '9876543210');
    await tester.enterText(textFields.at(2), 'raghaw@example.com');
    await tester.pump();

    await tester.tap(find.text('START SHOPPING'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  });
}
