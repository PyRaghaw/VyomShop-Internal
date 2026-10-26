import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shop_model.dart';
import 'neo_pressable.dart';

void showShopCallModal(BuildContext context, ShopModel shop) {
  final phoneNumber = '+91 98302 44192';
  final ownerName = '${shop.name} Desk / Owner';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F3E8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFF101010), width: 2.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
            const SizedBox(height: 16),

            // Header Row: Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SHOP CONTACT & INQUIRY',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF939393),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
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
            const SizedBox(height: 16),

            // Store Representative Neo Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF101010), width: 1.8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF101010),
                    offset: Offset(2.5, 2.5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD400),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF101010), width: 1.5),
                    ),
                    child: const Icon(Icons.storefront, color: Color(0xFF101010), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                ownerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF101010),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Color(0xFF00875A), size: 16),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          phoneNumber,
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Operating Hours & Availability Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF4E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF376035), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_filled, color: Color(0xFF376035), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Store is OPEN NOW • ${shop.openTime ?? "10:00 AM"} – ${shop.closingTime ?? "9:30 PM"} • Direct staff response',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF376035),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Primary Action: CALL NOW
            NeoPressable(
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Calling $ownerName at $phoneNumber...',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFF101010),
                    duration: const Duration(seconds: 2),
                  ),
                );
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
                    Icon(Icons.phone, size: 18, color: Color(0xFF101010)),
                    SizedBox(width: 8),
                    Text(
                      'CALL SHOP NOW',
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
            const SizedBox(height: 12),

            // Secondary Actions: COPY NUMBER & MESSAGE
            Row(
              children: [
                Expanded(
                  child: NeoPressable(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: phoneNumber));
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Phone number copied to clipboard!',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Color(0xFF101010),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    height: 46,
                    pressDepth: 1.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy, size: 16, color: Color(0xFF101010)),
                          SizedBox(width: 6),
                          Text(
                            'COPY NUMBER',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeoPressable(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Connecting with ${shop.name} on WhatsApp...',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: const Color(0xFF101010),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    height: 46,
                    pressDepth: 1.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF101010)),
                          SizedBox(width: 6),
                          Text(
                            'MESSAGE',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void showShopDirectionsModal(BuildContext context, ShopModel shop) {
  int walkMinutes = (shop.distanceKm * 12.5).round();
  if (walkMinutes < 3) walkMinutes = 3;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F3E8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFF101010), width: 2.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STORE LOCATION & DIRECTIONS',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF939393),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
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
            const SizedBox(height: 16),

            // Address & Navigation Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF101010), width: 1.8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF101010),
                    offset: Offset(2.5, 2.5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD400),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF101010), width: 1.4),
                        ),
                        child: const Icon(Icons.location_on, size: 20, color: Color(0xFF101010)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop.address,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101010),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${shop.neighborhood} • Near Central Square',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6E6E6E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 1.2,
                    color: const Color(0xFFE2E2E2),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'DISTANCE',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF939393),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${shop.distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E2E2)),
                      Column(
                        children: [
                          const Text(
                            'WALKING TIME',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF939393),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$walkMinutes mins',
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E2E2)),
                      Column(
                        children: [
                          const Text(
                            'DRIVE TIME',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF939393),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(walkMinutes / 3).ceil()} mins',
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // OPEN IN MAPS Button
            NeoPressable(
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Opening navigation to ${shop.name} (${shop.address})...',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFF101010),
                    duration: const Duration(seconds: 2),
                  ),
                );
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
                    Icon(Icons.directions, size: 20, color: Color(0xFF101010)),
                    SizedBox(width: 8),
                    Text(
                      'START NAVIGATION IN MAPS',
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
      );
    },
  );
}
