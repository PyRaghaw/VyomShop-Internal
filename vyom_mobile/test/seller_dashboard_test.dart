import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vyom_mobile/features/seller/presentation/seller_dashboard_screen.dart';

void main() {
  testWidgets('SellerDashboardScreen renders full neo-brutalist blocks and metrics', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: SellerDashboardScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verify Studio Branding & Status
    expect(find.text('SELLER STUDIO'), findsOneWidget);
    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.text('BUYER'), findsOneWidget);

    // 2. Verify Hero Broadcast Banner
    expect(find.text('LOCAL BUYERS ARE BROWSING'), findsOneWidget);
    expect(find.text('PREVIEW AS BUYER'), findsOneWidget);
    expect(find.text('STORE QR & LINK'), findsOneWidget);

    // 3. Verify 4 Core Metric Blocks
    expect(find.text('STORE FOOTFALL & METRICS'), findsOneWidget);
    expect(find.text('CATALOG VIEWS'), findsOneWidget);
    expect(find.text('STORE VISITS'), findsOneWidget);
    expect(find.text('AI SCAN MATCHES'), findsOneWidget);
    expect(find.text('TRIAL HOLDS'), findsOneWidget);

    // 4. Verify Listing Credits & Wallet Card
    expect(find.textContaining('CREDITS REMAINING'), findsOneWidget);
    expect(find.text('TOP UP'), findsOneWidget);

    // 5. Verify Primary Action: Add Product with AI
    expect(find.text('+ ADD NEW PRODUCT WITH AI'), findsOneWidget);

    // 6. Verify Local Area Trends
    expect(find.text('TRENDING SEARCHES NEAR YOU'), findsOneWidget);
    expect(find.text('SALT LAKE DEMAND'), findsOneWidget);

    // 7. Verify Inventory Section & Filter Tabs
    expect(find.text('IN-STORE PRODUCTS'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('In Stock'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);
    expect(find.text('Drafts'), findsOneWidget);
  });
}
