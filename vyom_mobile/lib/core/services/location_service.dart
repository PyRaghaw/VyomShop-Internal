import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/shop_model.dart';
import '../models/product_model.dart';

class NeighborhoodInfo {
  final String fullName; // e.g., 'Salt Lake, Kolkata'
  final String shortName; // e.g., 'Salt Lake'
  final String city; // e.g., 'Kolkata'
  final double latitude;
  final double longitude;

  const NeighborhoodInfo({
    required this.fullName,
    required this.shortName,
    required this.city,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static const List<NeighborhoodInfo> supportedNeighborhoods = [
    NeighborhoodInfo(
      fullName: 'Salt Lake, Kolkata',
      shortName: 'Salt Lake',
      city: 'Kolkata',
      latitude: 22.5867,
      longitude: 88.4178,
    ),
    NeighborhoodInfo(
      fullName: 'Park Street, Kolkata',
      shortName: 'Park Street',
      city: 'Kolkata',
      latitude: 22.5512,
      longitude: 88.3524,
    ),
    NeighborhoodInfo(
      fullName: 'New Town, Kolkata',
      shortName: 'New Town',
      city: 'Kolkata',
      latitude: 22.5830,
      longitude: 88.4680,
    ),
    NeighborhoodInfo(
      fullName: 'Ballygunge, Kolkata',
      shortName: 'Ballygunge',
      city: 'Kolkata',
      latitude: 22.5280,
      longitude: 88.3650,
    ),
    NeighborhoodInfo(
      fullName: 'Indiranagar, Bengaluru',
      shortName: 'Indiranagar',
      city: 'Bengaluru',
      latitude: 12.9784,
      longitude: 77.6408,
    ),
    NeighborhoodInfo(
      fullName: 'Koramangala, Bengaluru',
      shortName: 'Koramangala',
      city: 'Bengaluru',
      latitude: 12.9352,
      longitude: 77.6245,
    ),
  ];

  Position? _currentPosition;
  bool _isLiveGpsActive = false;

  Position? get currentPosition => _currentPosition;
  bool get isLiveGpsActive => _isLiveGpsActive;

  /// Check permissions and fetch current device position
  Future<Position?> determinePosition({bool requestIfNeeded = true}) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled on device');
        _isLiveGpsActive = false;
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestIfNeeded) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied ($permission)');
        _isLiveGpsActive = false;
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 6),
        ),
      );

      _currentPosition = position;
      _isLiveGpsActive = true;
      debugPrint('Live GPS detected: lat=${position.latitude}, lng=${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      _isLiveGpsActive = false;
      return null;
    }
  }

  /// Match nearest neighborhood given coordinates
  NeighborhoodInfo findNearestNeighborhood(double lat, double lng) {
    NeighborhoodInfo best = supportedNeighborhoods.first;
    double minDistance = double.infinity;

    for (final n in supportedNeighborhoods) {
      final dist = Geolocator.distanceBetween(lat, lng, n.latitude, n.longitude);
      if (dist < minDistance) {
        minDistance = dist;
        best = n;
      }
    }
    return best;
  }

  /// Calculate distance in km between two coordinate points
  double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    final km = meters / 1000.0;
    return double.parse(km.toStringAsFixed(1));
  }

  /// Get anchor coordinates for a selected neighborhood
  NeighborhoodInfo getNeighborhoodInfo(String neighborhoodName) {
    final clean = neighborhoodName.toLowerCase().trim();
    return supportedNeighborhoods.firstWhere(
      (n) =>
          clean.contains(n.shortName.toLowerCase()) ||
          clean.contains(n.fullName.toLowerCase()),
      orElse: () => supportedNeighborhoods.first,
    );
  }

  /// Filter and rank shops dynamically by location
  List<ShopModel> filterAndRankShops(
    List<ShopModel> allShops,
    String selectedNeighborhood, {
    Position? userPosition,
  }) {
    if (allShops.isEmpty) return const [];

    final targetInfo = getNeighborhoodInfo(selectedNeighborhood);
    final anchorLat = userPosition?.latitude ?? targetInfo.latitude;
    final anchorLng = userPosition?.longitude ?? targetInfo.longitude;

    // Recalculate dynamic distance for each shop
    final shopsWithUpdatedDistance = allShops.map((shop) {
      final dynamicDist = calculateDistanceKm(
        anchorLat,
        anchorLng,
        shop.latitude,
        shop.longitude,
      );
      return shop.copyWith(distanceKm: dynamicDist);
    }).toList();

    // Group shops: primary neighborhood shops first, then nearby surrounding areas
    final targetShortName = targetInfo.shortName.toLowerCase();
    final inArea = <ShopModel>[];
    final outsideArea = <ShopModel>[];

    for (final shop in shopsWithUpdatedDistance) {
      final shopArea = shop.neighborhood.toLowerCase();
      if (shopArea.contains(targetShortName) || targetShortName.contains(shopArea)) {
        inArea.add(shop);
      } else {
        outsideArea.add(shop);
      }
    }

    inArea.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    outsideArea.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return [...inArea, ...outsideArea];
  }

  /// Filter and rank products dynamically based on ranked shops
  List<ProductModel> filterAndRankProducts(
    List<ProductModel> allProducts,
    List<ShopModel> rankedShops,
  ) {
    if (allProducts.isEmpty || rankedShops.isEmpty) return allProducts;

    final shopDistanceMap = <String, double>{};
    final shopOrderMap = <String, int>{};
    for (int i = 0; i < rankedShops.length; i++) {
      final s = rankedShops[i];
      shopDistanceMap[s.id] = s.distanceKm;
      shopDistanceMap[s.name.toLowerCase()] = s.distanceKm;
      shopOrderMap[s.id] = i;
      shopOrderMap[s.name.toLowerCase()] = i;
    }

    final updatedProducts = allProducts.map((p) {
      final dist = shopDistanceMap[p.shopId] ??
          shopDistanceMap[p.shopName.toLowerCase()] ??
          p.distanceKm;
      return p.copyWith(distanceKm: dist);
    }).toList();

    updatedProducts.sort((a, b) {
      final orderA = shopOrderMap[a.shopId] ??
          shopOrderMap[a.shopName.toLowerCase()] ??
          999;
      final orderB = shopOrderMap[b.shopId] ??
          shopOrderMap[b.shopName.toLowerCase()] ??
          999;
      if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }
      return a.distanceKm.compareTo(b.distanceKm);
    });

    return updatedProducts;
  }
}
