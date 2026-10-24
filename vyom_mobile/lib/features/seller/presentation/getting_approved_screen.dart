import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/widgets/neo_pressable.dart';
import '../../../core/widgets/vyom_arrow.dart';
import 'seller_navigation_shell.dart';

class GettingApprovedScreen extends StatelessWidget {
  final String verificationId;
  final String? shopName;
  final String? category;
  final String? ownerName;
  final String? email;
  final String? phone;
  final String? streetAddress;
  final String? city;
  final String? pinCode;
  final String? openTime;
  final String? closeTime;
  final String? description;
  final String? photoPath;

  const GettingApprovedScreen({
    super.key,
    required this.verificationId,
    this.shopName,
    this.category,
    this.ownerName,
    this.email,
    this.phone,
    this.streetAddress,
    this.city,
    this.pinCode,
    this.openTime,
    this.closeTime,
    this.description,
    this.photoPath,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveShopName = (shopName != null && shopName!.trim().isNotEmpty)
        ? shopName!.trim()
        : 'My Store';
    final hasPhoto = photoPath != null &&
        photoPath!.trim().isNotEmpty &&
        File(photoPath!).existsSync();

    final fullAddress = [
      if (streetAddress != null && streetAddress!.trim().isNotEmpty)
        streetAddress!.trim(),
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
      if (pinCode != null && pinCode!.trim().isNotEmpty) pinCode!.trim(),
    ].join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Back Button on the Right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeoPressable(
                    onTap: () => Navigator.of(context).pop(),
                    width: 44,
                    height: 44,
                    pressDepth: 2.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF101010), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(2.0, 2.5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: VyomArrow.back(
                        size: 20,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title: GETTING
              const Text(
                'GETTING',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 0.95,
                  letterSpacing: -0.5,
                  color: Color(0xFF101010),
                ),
              ),

              // Title: APPROVED
              const Text(
                'APPROVED',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w700,
                  fontSize: 48,
                  height: 0.95,
                  letterSpacing: -0.5,
                  color: Color(0xFF101010),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Your shop details are under review',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 24),

              // Card 1: Review Status Card (Rectangle 103)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF101010), width: 1.4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(3.0, 3.5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge row: PENDING REVIEW + Category pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD400),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF101010), width: 1.12),
                          ),
                          child: const Text(
                            'PENDING REVIEW',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 0.25,
                              height: 1.0,
                              color: Color(0xFF101010),
                            ),
                          ),
                        ),
                        if (category != null && category!.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F3E8),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF101010), width: 1.0),
                            ),
                            child: Text(
                              category!.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                letterSpacing: 0.5,
                                color: Color(0xFF101010),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Shop Name Display
                    Text(
                      effectiveShopName.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: 0.5,
                        color: Color(0xFF101010),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // VERIFICATION ID:
                    const Text(
                      'VERIFICATION ID:',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: -0.25,
                        color: Color(0xFF939393),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Dynamic ID Value
                    Text(
                      verificationId,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        letterSpacing: -0.25,
                        color: Color(0xFF101010),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Divider
                    Container(
                      height: 1.2,
                      width: double.infinity,
                      color: const Color(0xFFEBE6DC),
                    ),
                    const SizedBox(height: 18),

                    // Checklist Item 1: Business details submitted
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1.0),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Business details submitted',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF323232),
                                ),
                              ),
                              if ((ownerName != null && ownerName!.isNotEmpty) ||
                                  (phone != null && phone!.isNotEmpty)) ...[
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    if (ownerName != null && ownerName!.isNotEmpty)
                                      ownerName!,
                                    if (phone != null && phone!.isNotEmpty) phone!,
                                  ].join(' • '),
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                    color: Color(0xFF777777),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Checklist Item 2: Shop profile completed
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1.0),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Shop profile completed',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF323232),
                                ),
                              ),
                              if (fullAddress.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  fullAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                    color: Color(0xFF777777),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Checklist Item 3: Awaiting verification + Usually takes 24 to 48 hours
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1.0),
                          child: Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Awaiting verification',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF323232),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Usually takes 24 to 48 hours',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  color: Color(0xFF939393),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card 2: Submitted Details Summary (Dynamic data from Pages 1 & 2)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF101010), width: 1.4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(3.0, 3.5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.assignment_turned_in_outlined,
                              size: 18,
                              color: Color(0xFF101010),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'SUBMITTED DETAILS',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.5,
                                color: Color(0xFF101010),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF2E7D32), width: 1.0),
                          ),
                          child: const Text(
                            'CONFIRMED',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Uploaded Storefront Photo Preview (if present)
                    if (hasPhoto) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF101010), width: 1.2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(photoPath!),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: const Color(0xFF101010), width: 1.0),
                                ),
                                child: const Text(
                                  'STOREFRONT PHOTO',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 8,
                                    letterSpacing: 0.5,
                                    color: Color(0xFF101010),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Section: Owner Info
                    const Text(
                      'SELLER PROFILE',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.5,
                        color: Color(0xFF939393),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Owner', ownerName),
                    _buildDetailRow('Contact', phone),
                    _buildDetailRow('Email', email),

                    const SizedBox(height: 12),
                    Container(height: 1.0, color: const Color(0xFFF0ECE1)),
                    const SizedBox(height: 12),

                    // Section: Shop Info
                    const Text(
                      'SHOP PROFILE',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.5,
                        color: Color(0xFF939393),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Shop Name', effectiveShopName),
                    _buildDetailRow('Category', category),
                    _buildDetailRow('Address', fullAddress.isEmpty ? null : fullAddress),
                    _buildDetailRow(
                      'Hours',
                      (openTime != null && closeTime != null)
                          ? '$openTime – $closeTime'
                          : null,
                    ),
                    if (description != null && description!.trim().isNotEmpty)
                      _buildDetailRow('About', description!.trim()),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Button: GO TO DASHBOARD →
              NeoPressable(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SellerNavigationShell(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                    (route) => false,
                  );
                },
                height: 46,
                width: double.infinity,
                pressDepth: 2.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD400),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF101010), width: 1.4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF101010),
                      offset: Offset(2.0, 2.5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'GO TO DASHBOARD',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.0,
                        color: Color(0xFF101010),
                      ),
                    ),
                    SizedBox(width: 8),
                    VyomArrow.forward(
                      size: 16,
                      color: Color(0xFF101010),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Footer: Need help?  Contact support@vyomshop.com
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Need help?',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF939393),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Contact ',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF939393),
                      ),
                      children: const [
                        TextSpan(
                          text: 'support@vyomshop.com',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF101010),
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF101010),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    final displayVal = (value != null && value.trim().isNotEmpty) ? value.trim() : '—';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF777777),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayVal,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF101010),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
