import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../core/services/location_service.dart';
import '../../../core/widgets/neo_pressable.dart';

class InteractiveMapPickerSheet extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const InteractiveMapPickerSheet({
    super.key,
    required this.initialLat,
    required this.initialLng,
  });

  static Future<LatLng?> show(BuildContext context, {double? lat, double? lng}) {
    final defaultLat = lat ?? LocationService().currentPosition?.latitude ?? 22.5867;
    final defaultLng = lng ?? LocationService().currentPosition?.longitude ?? 88.4178;

    return showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InteractiveMapPickerSheet(
        initialLat: defaultLat,
        initialLng: defaultLng,
      ),
    );
  }

  @override
  State<InteractiveMapPickerSheet> createState() => _InteractiveMapPickerSheetState();
}

class _InteractiveMapPickerSheetState extends State<InteractiveMapPickerSheet> {
  late LatLng _selectedPoint;
  late final MapController _mapController;
  NeighborhoodInfo? _nearestNeighborhood;

  @override
  void initState() {
    super.initState();
    _selectedPoint = LatLng(widget.initialLat, widget.initialLng);
    _mapController = MapController();
    _updateNearest(_selectedPoint);
  }

  void _updateNearest(LatLng point) {
    _nearestNeighborhood = LocationService().findNearestNeighborhood(
      point.latitude,
      point.longitude,
    );
  }

  Widget _buildNeoMarkerPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD400),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF101010), width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF101010),
                offset: Offset(2.0, 2.5),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.shopping_bag,
              size: 20,
              color: Color(0xFF101010),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _PinTrianglePainter(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final latStr = _selectedPoint.latitude.toStringAsFixed(4);
    final lngStr = _selectedPoint.longitude.toStringAsFixed(4);
    final areaName = _nearestNeighborhood?.fullName ?? 'Selected Location';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F3E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF101010), width: 2.5),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle & Top Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101010),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INTERACTIVE MAP PICKER',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF939393),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pin Your Exact Location',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101010),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF101010), width: 1.5),
                        ),
                        child: const Icon(Icons.close, size: 18, color: Color(0xFF101010)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF101010), width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF101010),
                    offset: Offset(2.5, 3.0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedPoint,
                        initialZoom: 14.5,
                        minZoom: 4,
                        maxZoom: 18,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _selectedPoint = point;
                            _updateNearest(point);
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.vyomshops.vyom_mobile',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPoint,
                              width: 50,
                              height: 52,
                              alignment: Alignment.topCenter,
                              child: _buildNeoMarkerPin(),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Tap Instruction Badge
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF101010), width: 1.4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF101010),
                              offset: Offset(1.5, 1.5),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.touch_app, size: 16, color: Color(0xFF101010)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tap or pan anywhere on the map to place your pin',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101010),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recenter on GPS FAB
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: NeoPressable(
                        onTap: () async {
                          final pos = await LocationService().determinePosition(requestIfNeeded: true);
                          if (pos != null && mounted) {
                            final target = LatLng(pos.latitude, pos.longitude);
                            setState(() {
                              _selectedPoint = target;
                              _updateNearest(target);
                            });
                            _mapController.move(target, 15.5);
                          }
                        },
                        width: 44,
                        height: 44,
                        pressDepth: 1.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD400),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF101010), width: 1.6),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF101010),
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.my_location, size: 20, color: Color(0xFF101010)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Confirmation Card
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF101010), width: 1.6),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD400),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF101010), width: 1.3),
                        ),
                        child: const Icon(Icons.place, size: 20, color: Color(0xFF101010)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              areaName,
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF101010),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'GPS: $latStr° N, $lngStr° E',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6E6E6E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // CONFIRM LOCATION Button
                NeoPressable(
                  onTap: () {
                    Navigator.of(context).pop(_selectedPoint);
                  },
                  height: 52,
                  pressDepth: 2.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD400),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF101010), width: 1.8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(2.5, 3.0),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 20, color: Color(0xFF101010)),
                        SizedBox(width: 8),
                        Text(
                          'CONFIRM THIS LOCATION',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101010),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PinTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF101010)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
