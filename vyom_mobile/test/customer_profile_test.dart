import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vyom_mobile/core/data/mock_data.dart';
import 'package:vyom_mobile/core/services/customer_service.dart';
import 'package:vyom_mobile/features/customer/presentation/customer_profile_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('CustomerProfileScreen shows Guest Shopper card with REGISTER & LOGIN when uncompleted', (tester) async {
    MockData.enableMockData = true;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    final customer = CustomerService();
    customer.isRegistered = false;
    customer.name = '';
    customer.phone = '';

    addTearDown(() {
      MockData.enableMockData = false;
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CustomerProfileScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Guest State
    expect(find.text('PROFILE & SETTINGS'), findsOneWidget);
    expect(find.text('GUEST SHOPPER'), findsOneWidget);
    expect(find.text('GUEST'), findsOneWidget);
    expect(find.text('REGISTER'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('SWITCH ROLE / CHOOSE ACCOUNT'), findsOneWidget);

    // Verify Alex Kumar is NOT shown
    expect(find.text('Alex Kumar'), findsNothing);
  });

  testWidgets('CustomerProfileScreen shows Registered User card when registered', (tester) async {
    MockData.enableMockData = true;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    final customer = CustomerService();
    await customer.saveProfile(
      name: 'Priya Sharma',
      phone: '+91 91234 56789',
      neighborhood: 'Salt Lake, Kolkata',
    );

    addTearDown(() {
      MockData.enableMockData = false;
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CustomerProfileScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Registered State
    expect(find.text('PROFILE & SETTINGS'), findsOneWidget);
    expect(find.text('Priya Sharma'), findsOneWidget);
    expect(find.text('+91 91234 56789'), findsOneWidget);
    expect(find.text('PS'), findsOneWidget);
    expect(find.text('LOGOUT / SWITCH ROLE'), findsOneWidget);

    // Guest card elements should not be present
    expect(find.text('GUEST SHOPPER'), findsNothing);
    expect(find.text('Alex Kumar'), findsNothing);
  });

  testWidgets('Preferences and Support bottom sheets open properly and alerts can toggle', (tester) async {
    MockData.enableMockData = true;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      MockData.enableMockData = false;
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: CustomerProfileScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Toggle alerts
    final switches = find.byType(Switch);
    expect(switches, findsOneWidget);
    await tester.tap(switches.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 2. Open Search History Modal
    await tester.tap(find.text('Search History'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SEARCH HISTORY'), findsOneWidget);
    expect(find.text('CLEAR ALL HISTORY'), findsOneWidget);

    // Close modal
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 3. Open Privacy & Permissions Modal
    await tester.tap(find.text('Privacy & Permissions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('PRIVACY & PERMISSIONS'), findsOneWidget);
    expect(find.text('Camera Access'), findsOneWidget);
    expect(find.text('SAVE SETTINGS'), findsOneWidget);

    // Close modal
    await tester.tap(find.text('SAVE SETTINGS'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 4. Open How Visual Search Works Modal
    await tester.tap(find.text('How Visual Search Works'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('HOW VISUAL SEARCH WORKS'), findsOneWidget);
    expect(find.text('Camera Kholo'), findsOneWidget);
    expect(find.text('Picture Click Karo'), findsOneWidget);
    expect(find.text('Item Select Karo'), findsOneWidget);
    expect(find.text('Press Search & Discover'), findsOneWidget);
    expect(find.text('GOT IT, LET’S SHOP'), findsOneWidget);

    await tester.tap(find.text('GOT IT, LET’S SHOP'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });
}
