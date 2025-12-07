import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/models/page.dart' as models;
import '../../../providers/auth_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/custom_back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Edit Page Screen - Modern design matching Create Page
class EditPageScreen extends StatefulWidget {
  final models.Page page;

  const EditPageScreen({Key? key, required this.page}) : super(key: key);

  @override
  State<EditPageScreen> createState() => _EditPageScreenState();
}

class _EditPageScreenState extends State<EditPageScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pageRepository = PageRepository();
  final _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  XFile? _selectedLogo;
  bool _logoChanged = false;

  late AnimationController _animationController;
  late Animation<Offset> _bubblesSlideAnimation;
  late Animation<Offset> _bottomYellowBubbleSlideAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _bubblesFadeAnimation;
  late Animation<double> _contentFadeAnimation;
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.page.name;
    _descriptionController.text = widget.page.description ?? '';
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Bubbles animation - coming from outside (top-left)
    _bubblesSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Bottom yellow bubble animation - coming from right outside
    _bottomYellowBubbleSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Content animation - coming from bottom
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _bubblesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    // Start animations
    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _animationsInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedLogo = image;
          _logoChanged = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _updatePage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _pageRepository.updatePage(
        pageId: widget.page.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        logoFile: _logoChanged && _selectedLogo != null 
            ? File(_selectedLogo!.path) 
            : null,
        logoUrl: !_logoChanged ? widget.page.logo : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Page updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update page: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userLeoId = authProvider.user?.leoId;
    final isWebmaster = userLeoId != null && widget.page.webmasterIds.contains(userLeoId);
    final isSuperAdmin = authProvider.isSuperAdmin;
    
    // Check if user is webmaster or super admin
    if (!isWebmaster && !isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Page'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Access denied. Only webmasters can edit this page.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top bubbles - animated to slide in from top-left
          if (_animationsInitialized)
            FadeTransition(
              opacity: _bubblesFadeAnimation,
              child: SlideTransition(
                position: _bubblesSlideAnimation,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Bubble 02 - Yellow bubble at top left, rotated 235.784deg
                    Positioned(
                      left: ResponsiveUtils.bw(-100),
                      top: ResponsiveUtils.bh(-184),
                      child: Transform.rotate(
                        angle: 225.784 * math.pi / 180,
                        child: SizedBox(
                          width: ResponsiveUtils.bs(373.531),
                          height: ResponsiveUtils.bs(442.65),
                          child: CustomPaint(
                            size: Size(
                              ResponsiveUtils.bs(373.531),
                              ResponsiveUtils.bs(442.65),
                            ),
                            painter: _Bubble02Painter(),
                          ),
                        ),
                      ),
                    ),
                    // Bubble 01 - Black bubble at top left, rotated 240deg
                    Positioned(
                      left: ResponsiveUtils.bw(-148.17),
                      top: ResponsiveUtils.bh(-200.48),
                      child: Transform.rotate(
                        angle: 220 * math.pi / 180,
                        child: SizedBox(
                          width: ResponsiveUtils.bs(402.871),
                          height: ResponsiveUtils.bs(442.65),
                          child: CustomPaint(
                            size: Size(
                              ResponsiveUtils.bs(402.871),
                              ResponsiveUtils.bs(442.65),
                            ),
                            painter: _Bubble01Painter(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Bubble 04 - Yellow bubble at bottom right, rotated 110deg
          if (_animationsInitialized)
            Positioned(
              left: ResponsiveUtils.bw(MediaQuery.of(context).size.width * 0.4167 - 7.92),
              top: ResponsiveUtils.bh(495.4),
              child: FadeTransition(
                opacity: _bubblesFadeAnimation,
                child: SlideTransition(
                  position: _bottomYellowBubbleSlideAnimation,
                  child: Transform.rotate(
                    angle: 110 * math.pi / 180,
                    child: SizedBox(
                      width: ResponsiveUtils.bs(353.53),
                      height: ResponsiveUtils.bs(442.65),
                      child: CustomPaint(
                        size: Size(
                          ResponsiveUtils.bs(353.53),
                          ResponsiveUtils.bs(442.65),
                        ),
                        painter: _Bubble04Painter(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Back button - top left
          CustomBackButton(
            backgroundColor: Colors.black,
            iconSize: ResponsiveUtils.iconSize,
          ),

          // "Edit Page" title
          Positioned(
            left: MediaQuery.of(context).size.width * 0.1667 + ResponsiveUtils.dp(2),
            top: ResponsiveUtils.bh(48),
            child: Text(
              'Edit\nPage',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: ResponsiveUtils.sp(50),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -ResponsiveUtils.dp(0.52),
                height: 1.1,
              ),
            ),
          ),

          // Scrollable content - animated to slide up from bottom
          Positioned(
            left: 0,
            right: 0,
            top: ResponsiveUtils.bh(175),
            bottom: 0,
            child: _animationsInitialized
                ? FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: SlideTransition(
                      position: _contentSlideAnimation,
                      child: _buildBody(),
                    ),
                  )
                : _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacingM,
        vertical: ResponsiveUtils.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUtils.r(30)),
          topRight: Radius.circular(ResponsiveUtils.r(30)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Logo/Icon
              _buildSectionLabel('Page Icon (Optional)'),
              const SizedBox(height: 8),
              _buildImagePicker(
                onTap: _pickLogo,
                selectedImage: _selectedLogo,
                existingImageUrl: _selectedLogo == null ? widget.page.logo : null,
                icon: Icons.add_photo_alternate,
                label: 'Tap to select icon',
                onRemove: (_selectedLogo != null || widget.page.logo != null)
                    ? () {
                        setState(() {
                          _selectedLogo = null;
                          _logoChanged = true;
                        });
                      }
                    : null,
              ),
              const SizedBox(height: 16),

              // Page Name
              _buildTextField(
                controller: _nameController,
                label: 'Page Name *',
                hintText: 'Enter page name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a page name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hintText: 'Enter page description',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Update Page',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito Sans',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: ResponsiveUtils.bodyLarge,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'Nunito Sans',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildImagePicker({
    required VoidCallback onTap,
    XFile? selectedImage,
    String? existingImageUrl,
    required IconData icon,
    required String label,
    VoidCallback? onRemove,
  }) {
    final hasImage = selectedImage != null || existingImageUrl != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: !hasImage
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.grey[50]!.withOpacity(0.9),
                  ],
                )
              : null,
          color: hasImage ? null : Colors.transparent,
          border: Border.all(
            color: !hasImage
                ? AppColors.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: !hasImage
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: hasImage
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: selectedImage != null
                        ? Image.file(
                            File(selectedImage.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : existingImageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: existingImageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error, size: 48),
                                ),
                              )
                            : const SizedBox(),
                  ),
                  // Gradient overlay for better button visibility
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  if (onRemove != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
                          padding: const EdgeInsets.all(8),
                          onPressed: onRemove,
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontFamily: 'Nunito Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recommended: Square image',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontFamily: 'Nunito Sans',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Bubble 01 - Black bubble (p36b3a180 path) - Exact from create page
class _Bubble01Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 403;
    final scaleY = size.height / 443;

    final path = Path();
    path.moveTo(201.436 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      296.874 * scaleX, -90.0363 * scaleY,
      402.871 * scaleX, 129.964 * scaleY,
      402.871 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      402.871 * scaleX, 352.464 * scaleY,
      312.686 * scaleX, 442.65 * scaleY,
      201.436 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      90.1858 * scaleX, 442.65 * scaleY,
      0, 352.464 * scaleY,
      0, 241.214 * scaleY,
    );
    path.cubicTo(
      0, 129.964 * scaleY,
      105.998 * scaleX, 169.593 * scaleY,
      201.436 * scaleX, 39.7783 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bubble 02 - Yellow bubble (p2c5a2d80 path) - Exact from create page
class _Bubble02Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 374;
    final scaleY = size.height / 443;

    final path = Path();
    path.moveTo(172.096 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      267.534 * scaleX, -90.0363 * scaleY,
      373.531 * scaleX, 129.964 * scaleY,
      373.531 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      373.531 * scaleX, 352.464 * scaleY,
      283.346 * scaleX, 442.65 * scaleY,
      172.096 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      60.8459 * scaleX, 442.65 * scaleY,
      8.63746 * scaleX, 346.944 * scaleY,
      0.53979 * scaleX, 245.526 * scaleY,
    );
    path.cubicTo(
      -7.55788 * scaleX, 144.107 * scaleY,
      76.6577 * scaleX, 169.593 * scaleY,
      172.096 * scaleX, 39.7783 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bubble 04 - Yellow bubble at bottom (p2ec28100 path) - Exact from create page
class _Bubble04Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final scaleX = size.width / 354;
    final scaleY = size.height / 443;

    final path = Path();
    path.moveTo(162.881 * scaleX, 39.7783 * scaleY);
    path.cubicTo(
      253.208 * scaleX, -90.0363 * scaleY,
      353.53 * scaleX, 129.964 * scaleY,
      353.53 * scaleX, 241.214 * scaleY,
    );
    path.cubicTo(
      353.53 * scaleX, 352.464 * scaleY,
      268.173 * scaleX, 442.65 * scaleY,
      162.881 * scaleX, 442.65 * scaleY,
    );
    path.cubicTo(
      57.5878 * scaleX, 442.65 * scaleY,
      8.17495 * scaleX, 346.944 * scaleY,
      0.510886 * scaleX, 245.526 * scaleY,
    );
    path.cubicTo(
      -7.15317 * scaleX, 144.107 * scaleY,
      72.5529 * scaleX, 169.593 * scaleY,
      162.881 * scaleX, 39.7783 * scaleY,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
