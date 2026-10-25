import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vyom_mobile/core/data/mock_data.dart';
import 'package:vyom_mobile/core/services/location_service.dart';
import 'package:vyom_mobile/features/customer/presentation/ai_search_scan_screen.dart';

void main() {
  group('LocationService Dynamic Neighborhood Tests', () {
    test('Calculates distance and finds nearest neighborhood accurately', () {
      final service = LocationService();

      // Salt Lake coordinates: 22.5867, 88.4178
      final nearSaltLake = service.findNearestNeighborhood(22.5850, 88.4160);
      expect(nearSaltLake.shortName, 'Salt Lake');

      // Park Street coordinates: 22.5512, 88.3524
      final nearParkStreet = service.findNearestNeighborhood(22.5520, 88.3530);
      expect(nearParkStreet.shortName, 'Park Street');

      // Koramangala coordinates: 12.9352, 77.6245
      final nearKoramangala = service.findNearestNeighborhood(12.9340, 77.6250);
      expect(nearKoramangala.shortName, 'Koramangala');

      // Distance calculation
      final dist = service.calculateDistanceKm(22.5867, 88.4178, 22.5726, 88.4312);
      expect(dist, greaterThan(0.0));
      expect(dist, lessThan(10.0));
    });

    test('Filter and rank shops dynamically updates order and distance', () {
      final service = LocationService();
      final allShops = MockData.shops;
      expect(allShops, isNotEmpty);

      // Rank for Salt Lake: Salt Lake boutiques should appear first
      final saltLakeShops = service.filterAndRankShops(allShops, 'Salt Lake, Kolkata');
      expect(saltLakeShops.first.neighborhood, 'Salt Lake');

      // Rank for Park Street: Park Street boutiques should appear first
      final parkStreetShops = service.filterAndRankShops(allShops, 'Park Street, Kolkata');
      expect(parkStreetShops.first.neighborhood, 'Park Street');

      // Rank for Koramangala: Koramangala boutiques should appear first
      final koraShops = service.filterAndRankShops(allShops, 'Koramangala, Bengaluru');
      expect(koraShops.first.neighborhood, 'Koramangala');
    });
  });

  group('AiSearchScanScreen UI & Scanner Test', () {
    testWidgets('Renders camera scanner or fallback viewfinder cleanly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AiSearchScanScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SCAN TO DISCOVER.'), findsOneWidget);
      expect(find.text('Scan a product to find similar styles nearby.'), findsOneWidget);
    });
  });
}
