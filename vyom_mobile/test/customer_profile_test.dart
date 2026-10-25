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
}
