import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/customer_service.dart';
import '../../../core/widgets/neo_pressable.dart';
import 'ai_matching_results_screen.dart';
import 'customer_navigation_shell.dart';

class AiSearchScanScreen extends StatefulWidget {
  const AiSearchScanScreen({super.key});

  @override
  State<AiSearchScanScreen> createState() => _AiSearchScanScreenState();
}

class _AiSearchScanScreenState extends State<AiSearchScanScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCameraPermissionDenied = false;
  bool _isSimulatedCameraActive = false;
  bool _isProcessing = false;

  // Captured or selected image for "IMAGE PREVIEW" mode
  String? _capturedImagePath;
  bool _isCropping = false;

  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      // 1. Explicitly check and request camera permission using permission_handler
      final camStatus = await Permission.camera.status;
      if (!camStatus.isGranted) {
        final reqResult = await Permission.camera.request();
        if (!reqResult.isGranted) {
          if (mounted) {
            setState(() {
              _isCameraInitialized = false;
              _isCameraPermissionDenied = true;
            });
          }
          return;
        }
      }

      await _cameraController?.dispose();
      _cameraController = null;

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
            _isCameraPermissionDenied = false;
            _isSimulatedCameraActive = true;
          });
        }
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _cameraController = controller;
      await controller.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isCameraPermissionDenied = false;
          _isSimulatedCameraActive = false;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isCameraPermissionDenied = true;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      controller.dispose();
      if (mounted) {
        setState(() => _isCameraInitialized = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanAnimationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final offset = details.localPosition;
    final relativeX = (offset.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final relativeY = (offset.dy / constraints.maxHeight).clamp(0.0, 1.0);

    setState(() {
      _focusPoint = offset;
      _showFocusIndicator = true;
    });

    try {
      _cameraController!.setFocusPoint(Offset(relativeX, relativeY));
      _cameraController!.setFocusMode(FocusMode.auto);
    } catch (_) {}

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _showFocusIndicator = false);
      }
    });
  }

  Future<void> _capturePhoto() async {
    if (_isProcessing) return;

    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final XFile photo = await _cameraController!.takePicture();
        if (mounted) {
          setState(() {
            _capturedImagePath = photo.path;
            _isCropping = false;
          });
        }
      } else {
        // Fallback to sample query photo (High-top sneakers) if camera isn't ready
        if (mounted) {
          setState(() {
            _capturedImagePath =
                'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800';
            _isCropping = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        setState(() {
          _capturedImagePath =
              'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800';
          _isCropping = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _capturedImagePath = image.path;
          _isCropping = false;
        });
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
    }
  }

  void _handleRetake() {
    setState(() {
      _capturedImagePath = null;
      _isCropping = false;
    });
  }

  void _toggleCrop() {
    setState(() {
      _isCropping = !_isCropping;
    });
  }

  void _searchProduct() {
    if (_capturedImagePath == null || _isProcessing) return;

    CustomerService().incrementVisualScans();
    setState(() => _isProcessing = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AiMatchingResultsScreen(
            queryImageUrl: _capturedImagePath!,
          ),
        ),
      );
    });
  }

  void _handleBack() {
    if (_capturedImagePath != null) {
      _handleRetake();
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      final shell = context.findAncestorStateOfType<CustomerNavigationShellState>();
      shell?.switchTab(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPreviewMode = _capturedImagePath != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3E8),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Neo Back Button + Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NeoPressable(
                    onTap: _handleBack,
                    width: 44,
                    height: 44,
                    pressDepth: 1.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF101010), width: 1.4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF101010),
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Color(0xFF101010),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPreviewMode ? 'IMAGE PREVIEW' : 'SCAN TO DISCOVER.',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.2,
                            color: Color(0xFF101010),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isPreviewMode
                              ? 'Review your photo, then find similar styles nearby.'
                              : 'Scan a product to find similar styles nearby.',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Card (Viewfinder in scan mode, Image Preview in preview mode)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF101010), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(3.0, 3.0),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF181818),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD400), width: 1.6),
                    ),
                    child: Stack(
                      children: [
                        if (isPreviewMode)
                          // IMAGE PREVIEW CONTENT
                          _buildPreviewContent()
                        else if (_isCameraInitialized &&
                            _cameraController != null &&
                            _cameraController!.value.isInitialized)
                          // LIVE CAMERA CONTENT
                          _buildLiveCameraContent()
                        else if (_isSimulatedCameraActive)
                          // SIMULATED LIVE CAMERA
                          _buildSimulatedLiveCameraContent()
                        else
                          // FALLBACK WHEN CAMERA IS UNAVAILABLE
                          _buildCameraFallbackContent(),

                        // Processing Overlay
                        if (_isProcessing) _buildProcessingOverlay(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Controls (Different for Scan Mode vs Image Preview Mode)
            if (isPreviewMode)
              _buildPreviewControls()
            else
              _buildScanControls(),
          ],
        ),
      ),
    );
  }

  // --- Content Builders ---

  Widget _buildPreviewContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.5),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image Display
          if (_isCropping)
            InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.5,
              child: _buildCapturedImageWidget(),
            )
          else
            _buildCapturedImageWidget(),

          // Crop Grid Overlay when cropping
          if (_isCropping) ...[
            _buildRuleOfThirdsGrid(),
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFD400), width: 1),
                  ),
                  child: const Text(
                    'Pinch & pan to focus on product',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFD400),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCapturedImageWidget() {
    final path = _capturedImagePath!;
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD400), strokeWidth: 2.5),
        ),
        errorWidget: (context, url, error) => _buildPlaceholderPreview(),
      );
    } else if (File(path).existsSync()) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderPreview(),
      );
    } else {
      return _buildPlaceholderPreview();
    }
  }

  Widget _buildPlaceholderPreview() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: Color(0xFFFFD400),
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'IMAGE PREVIEW',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCameraContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final previewSize = _cameraController?.value.previewSize;
          final previewWidth = previewSize?.height ?? constraints.maxWidth;
          final previewHeight = previewSize?.width ?? constraints.maxHeight;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _onViewFinderTap(details, constraints),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Real Live Camera Feed scaled cleanly with zero distortion
                SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: previewWidth,
                      height: previewHeight,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),

                // Subtle Scanning Laser Line
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanAnimation.value * (constraints.maxHeight - 60) + 20,
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFD400).withValues(alpha: 0.0),
                              const Color(0xFFFFD400).withValues(alpha: 0.95),
                              const Color(0xFFFFD400).withValues(alpha: 0.0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD400).withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Corner Targeting Brackets
                _buildCornerBrackets(),

                // Live Camera Indicator Badge
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFFD400), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE FEED',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tap Focus Indicator
                if (_showFocusIndicator && _focusPoint != null)
                  Positioned(
                    left: _focusPoint!.dx - 28,
                    top: _focusPoint!.dy - 28,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.3, end: 1.0),
                      duration: const Duration(milliseconds: 250),
                      builder: (context, val, child) {
                        return Transform.scale(
                          scale: val,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFFFD400),
                                width: 1.8,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add,
                                color: Color(0xFFFFD400),
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Bottom Instruction Label
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'KEEP THE PRODUCT INSIDE THE FRAME',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFD400),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimulatedLiveCameraContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              setState(() {
                _focusPoint = details.localPosition;
                _showFocusIndicator = true;
              });
              Future.delayed(const Duration(milliseconds: 1200), () {
                if (mounted) setState(() => _showFocusIndicator = false);
              });
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // High-resolution Streetwear Query Feed
                Image.network(
                  'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&auto=format&fit=crop&q=80',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFD400), strokeWidth: 2.5),
                    );
                  },
                ),

                // Subtle dark vignette overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),

                // Subtle Scanning Laser Line
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanAnimation.value * (constraints.maxHeight - 60) + 20,
                      left: 16,
                      right: 16,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFD400).withValues(alpha: 0.0),
                              const Color(0xFFFFD400).withValues(alpha: 0.95),
                              const Color(0xFFFFD400).withValues(alpha: 0.0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD400).withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Corner Targeting Brackets
                _buildCornerBrackets(),

                // Top Badge: Viewfinder mode & Retry Hardware Button
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFFD400), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD400),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LIVE VIEWFINDER',
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _initCamera,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF101010), width: 1.2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, size: 12, color: Color(0xFF101010)),
                              SizedBox(width: 4),
                              Text(
                                'CONNECT HARDWARE',
                                style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF101010),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Focus indicator
                if (_showFocusIndicator && _focusPoint != null)
                  Positioned(
                    left: _focusPoint!.dx - 28,
                    top: _focusPoint!.dy - 28,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFFD400), width: 1.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.add, color: Color(0xFFFFD400), size: 16),
                      ),
                    ),
                  ),

                // Bottom Instruction Label
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'TAP SHUTTER TO CAPTURE PRODUCT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFFD400),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraFallbackContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD400), width: 1.5),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFFFFD400),
                size: 40,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'LIVE CAMERA SCANNER',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isCameraPermissionDenied
                  ? 'Camera permission is required to stream live feed.\nGrant access or start the simulated scanner below.'
                  : 'Initializing camera feed...\nEnsure camera permissions are enabled.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Action Buttons
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                NeoPressable(
                  onTap: () async {
                    final status = await Permission.camera.request();
                    if (status.isPermanentlyDenied) {
                      await openAppSettings();
                    } else {
                      _initCamera();
                    }
                  },
                  height: 42,
                  pressDepth: 1.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD400),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF101010), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(1.5, 2.0),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Center(
                      child: Text(
                        'ENABLE CAMERA',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: Color(0xFF101010),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                NeoPressable(
                  onTap: () {
                    setState(() {
                      _isSimulatedCameraActive = true;
                    });
                  },
                  height: 42,
                  pressDepth: 1.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF101010), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(1.5, 2.0),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Center(
                      child: Text(
                        'START VIEWFINDER',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: Color(0xFF101010),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12.5),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFD400),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF101010),
                offset: Offset(3.0, 3.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: Color(0xFFFFD400),
                  strokeWidth: 3.5,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'MATCHING PRODUCT...',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Searching local shop inventory',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFD400).withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Bottom Controls ---

  // Page 12: Image Preview Controls (Retake + Crop Image + SEARCH PRODUCT)
  Widget _buildPreviewControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row: Retake and Crop Image buttons
          Row(
            children: [
              // Retake Button
              Expanded(
                child: NeoPressable(
                  onTap: _handleRetake,
                  height: 64,
                  pressDepth: 1.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF101010), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(2.0, 2.5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.replay_rounded,
                          size: 22,
                          color: Color(0xFF101010),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Retake',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101010),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Crop Image Button
              Expanded(
                child: NeoPressable(
                  onTap: _toggleCrop,
                  height: 64,
                  pressDepth: 1.5,
                  decoration: BoxDecoration(
                    color: _isCropping ? const Color(0xFFFFD400) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF101010), width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF101010),
                        offset: Offset(2.0, 2.5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isCropping ? Icons.check_rounded : Icons.crop_rounded,
                          size: 22,
                          color: const Color(0xFF101010),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isCropping ? 'Done' : 'Crop Image',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12.5,
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
          const SizedBox(height: 12),
          // Full-width SEARCH PRODUCT -> Button
          NeoPressable(
            onTap: _searchProduct,
            height: 52,
            pressDepth: 2.0,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD400),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF101010), width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF101010),
                  offset: Offset(2.5, 3.0),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SEARCH PRODUCT',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: Color(0xFF101010),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Color(0xFF101010),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Scan Mode Controls: Gallery button + Shutter button
  Widget _buildScanControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gallery Pick Button
          NeoPressable(
            onTap: _pickFromGallery,
            width: 52,
            height: 52,
            pressDepth: 1.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF101010), width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF101010),
                  offset: Offset(2.5, 2.5),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.photo_library_outlined,
                size: 24,
                color: Color(0xFF101010),
              ),
            ),
          ),

          // Shutter / Capture Button
          NeoPressable(
            onTap: _capturePhoto,
            width: 76,
            height: 76,
            pressDepth: 2.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF101010),
                  offset: Offset(3.0, 3.0),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF101010), width: 1.5),
              ),
              child: Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD400),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF101010), width: 1.4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 26,
                      color: Color(0xFF101010),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Symmetrical spacer for exact center alignment
          const SizedBox(width: 52),
        ],
      ),
    );
  }

  // Corner brackets for the camera viewfinder
  Widget _buildCornerBrackets() {
    return const Stack(
      children: [
        Positioned(
          top: 14,
          left: 14,
          child: SizedBox(
            width: 20,
            height: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFFFD400), width: 2.5),
                  left: BorderSide(color: Color(0xFFFFD400), width: 2.5),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: SizedBox(
            width: 20,
            height: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFFFD400), width: 2.5),
                  right: BorderSide(color: Color(0xFFFFD400), width: 2.5),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 34,
          left: 14,
          child: SizedBox(
            width: 20,
            height: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFFD400), width: 2.5),
                  left: BorderSide(color: Color(0xFFFFD400), width: 2.5),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 34,
          right: 14,
          child: SizedBox(
            width: 20,
            height: 20,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFFD400), width: 2.5),
                  right: BorderSide(color: Color(0xFFFFD400), width: 2.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 3x3 rule-of-thirds grid for crop mode
  Widget _buildRuleOfThirdsGrid() {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            children: [
              // Vertical lines
              Positioned(
                left: w / 3,
                top: 0,
                bottom: 0,
                child: Container(width: 1, color: Colors.white.withValues(alpha: 0.35)),
              ),
              Positioned(
                left: (w / 3) * 2,
                top: 0,
                bottom: 0,
                child: Container(width: 1, color: Colors.white.withValues(alpha: 0.35)),
              ),
              // Horizontal lines
              Positioned(
                top: h / 3,
                left: 0,
                right: 0,
                child: Container(height: 1, color: Colors.white.withValues(alpha: 0.35)),
              ),
              Positioned(
                top: (h / 3) * 2,
                left: 0,
                right: 0,
                child: Container(height: 1, color: Colors.white.withValues(alpha: 0.35)),
              ),
            ],
          );
        },
      ),
    );
  }
}
