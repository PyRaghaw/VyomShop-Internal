import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../core/widgets/neo_pill.dart';
import '../../../core/widgets/vyom_arrow.dart';

class PackageOption {
  final String name;
  final int totalListings;
  final int paidCredits;
  final int freeCredits;
  final double price;
  final double perProductPrice;
  final String? badge;

  const PackageOption({
    required this.name,
    required this.totalListings,
    required this.paidCredits,
    required this.freeCredits,
    required this.price,
    required this.perProductPrice,
    this.badge,
  });
}

class CreditsPackagesScreen extends StatefulWidget {
  const CreditsPackagesScreen({super.key});

  @override
  State<CreditsPackagesScreen> createState() => _CreditsPackagesScreenState();
}

class _CreditsPackagesScreenState extends State<CreditsPackagesScreen> {
  final List<PackageOption> _packages = const [
    PackageOption(
      name: 'Starter',
      totalListings: 10,
      paidCredits: 10,
      freeCredits: 0,
      price: 100,
      perProductPrice: 10.0,
    ),
    PackageOption(
      name: 'Growth',
      totalListings: 30,
      paidCredits: 25,
      freeCredits: 5,
      price: 250,
      perProductPrice: 8.3,
      badge: 'POPULAR CHOICE',
    ),
    PackageOption(
      name: 'Pro',
      totalListings: 60,
      paidCredits: 45,
      freeCredits: 15,
      price: 450,
      perProductPrice: 7.5,
    ),
    PackageOption(
      name: 'Business',
      totalListings: 100,
      paidCredits: 65,
      freeCredits: 35,
      price: 650,
      perProductPrice: 6.5,
      badge: 'BEST VALUE',
    ),
  ];

  late PackageOption _selectedPackage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedPackage = _packages[1]; // Default to Growth
  }

  void _triggerPayment() {
    setState(() => _isProcessing = true);

    // Simulate Razorpay payment modal
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            side: const BorderSide(color: AppColors.foreground, width: 2.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 28),
              SizedBox(width: 8),
              Text('Payment Successful!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: Text(
            '${_selectedPackage.totalListings} listing credits have been credited to your shop wallet.\n\nTransaction ID: TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.5),
          ),
          actions: [
            NeoButton(
              text: 'Done →',
              variant: NeoButtonVariant.primary,
              height: 44,
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const VyomArrow.back(size: 20, color: AppColors.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Listing Packages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A LITTLE BOOST • A BIGGER AUDIENCE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              'Listing Packages',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 6),
            const Text(
              'Base rate is ₹10 per active product. Buy a package to unlock free bonus credits for your shop.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            // Packages List
            ..._packages.map((pkg) {
              final isSelected = pkg.name == _selectedPackage.name;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: NeoCard(
                  backgroundColor: isSelected ? AppColors.primaryLight : Colors.white,
                  onTap: () => setState(() => _selectedPackage = pkg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pkg.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          if (pkg.badge != null)
                            NeoPill(label: pkg.badge!, tone: NeoPillTone.orange),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${pkg.price.toInt()}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.foreground),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'for ${pkg.totalListings} listings (₹${pkg.perProductPrice}/item)',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mutedText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: pkg.freeCredits > 0 ? AppColors.tintGreen : AppColors.muted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.foreground, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              pkg.freeCredits > 0 ? Icons.stars : Icons.check,
                              size: 16,
                              color: pkg.freeCredits > 0 ? const Color(0xFF16A34A) : AppColors.foreground,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pkg.freeCredits > 0
                                  ? '${pkg.paidCredits} Paid Credits + ${pkg.freeCredits} FREE Bonus Credits'
                                  : '${pkg.paidCredits} Listing Credits included',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: pkg.freeCredits > 0 ? const Color(0xFF16A34A) : AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            // Checkout CTA
            NeoButton(
              text: 'Pay ₹${_selectedPackage.price.toInt()} with Razorpay →',
              variant: NeoButtonVariant.primary,
              width: double.infinity,
              height: 54,
              isLoading: _isProcessing,
              onPressed: _triggerPayment,
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'Secured via Razorpay • 100% money back guarantee on unverified listings',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedText),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
