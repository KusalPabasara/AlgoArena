import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/repositories/leo_id_repository.dart';
import '../../../data/models/leo_id.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/custom_back_button.dart';

/// Create Page Screen - Modern & Beautiful Design
class CreatePageScreen extends StatefulWidget {
  const CreatePageScreen({Key? key}) : super(key: key);

  @override
  State<CreatePageScreen> createState() => _CreatePageScreenState();
}

class _CreatePageScreenState extends State<CreatePageScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pageRepository = PageRepository();
  final _leoIdRepository = LeoIdRepository();
  final _imagePicker = ImagePicker();
  
  String _selectedType = 'club'; // 'club' or 'district'
  List<String> _selectedWebmasterIds = [];
  List<LeoId> _availableLeoIds = [];
  bool _isLoading = false;
  bool _isLoadingLeoIds = true;
  XFile? _selectedLogo;
  XFile? _selectedMapImage; // Map image for district pages

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
    // Initialize animation controller immediately
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
      begin: const Offset(0.5, 0.0),
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
    
    // Content animation - coming from bottom
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _animationsInitialized = true;
    _loadLeoIds();
    // Start animation after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLeoIds() async {
    setState(() => _isLoadingLeoIds = true);
    try {
      final leoIds = await _leoIdRepository.getAllLeoIds();
      // Filter only verified Leo IDs (isUsed = true)
      setState(() {
        _availableLeoIds = leoIds.where((leoId) => leoId.isUsed == true).toList();
        _isLoadingLeoIds = false;
      });
    } catch (e) {
      setState(() => _isLoadingLeoIds = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load Leo IDs: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickMapImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedMapImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick map image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createPage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWebmasterIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one webmaster'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _pageRepository.createPage(
        name: _nameController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        webmasterIds: _selectedWebmasterIds,
        logoFile: _selectedLogo != null ? File(_selectedLogo!.path) : null,
        mapImageFile: _selectedType == 'district' && _selectedMapImage != null 
            ? File(_selectedMapImage!.path) 
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Page created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create page: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showWebmasterSelector() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isSuperAdmin = authProvider.isSuperAdmin;
    final TextEditingController leoIdController = TextEditingController();
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFD700),
                        const Color(0xFFFFA500),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Webmasters',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Choose who can manage this page',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontFamily: 'Arimo',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          leoIdController.dispose();
                          Navigator.pop(context);
                          setState(() {});
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content area
                Flexible(
          child: _isLoadingLeoIds
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        )
              : _availableLeoIds.isEmpty
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isSuperAdmin 
                                        ? 'No verified Leo IDs found'
                                        : 'No Leo IDs available',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isSuperAdmin 
                                        ? 'You can manually enter Leo IDs below'
                                        : 'Please create Leo IDs first',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontFamily: 'Arimo',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (isSuperAdmin) ...[
                                    const SizedBox(height: 24),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: TextField(
                                        controller: leoIdController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter Leo ID (e.g., LEO-12345)',
                                          hintStyle: TextStyle(color: Colors.grey[400]),
                                          prefixIcon: Icon(Icons.badge, color: Colors.grey[600]),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.all(16),
                                        ),
                                        style: const TextStyle(
                                          fontFamily: 'Arimo',
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textCapitalization: TextCapitalization.characters,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          final leoId = leoIdController.text.trim().toUpperCase();
                                          if (leoId.isNotEmpty && !_selectedWebmasterIds.contains(leoId)) {
                                            setDialogState(() {
                                              _selectedWebmasterIds.add(leoId);
                                            });
                                            leoIdController.clear();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Added $leoId'),
                                                backgroundColor: Colors.green,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          } else if (leoId.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('Please enter a Leo ID'),
                                                backgroundColor: Colors.orange,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('$leoId already added'),
                                                backgroundColor: Colors.orange,
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        icon: const Icon(Icons.add_circle_outline),
                                        label: const Text(
                                          'Add Leo ID',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFD700),
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Selected count badge
                                if (_selectedWebmasterIds.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.all(16),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, color: const Color(0xFFFFD700), size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_selectedWebmasterIds.length} selected',
                                          style: const TextStyle(
                                            color: Color(0xFFB8860B),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // List of Leo IDs
                                Flexible(
                                  child: ListView.builder(
                          shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _availableLeoIds.length,
                          itemBuilder: (context, index) {
                            final leoId = _availableLeoIds[index];
                            final isSelected = _selectedWebmasterIds.contains(leoId.leoId);
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? const Color(0xFFFFD700).withOpacity(0.1)
                                              : Colors.grey[50],
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected 
                                                ? const Color(0xFFFFD700)
                                                : Colors.grey[200]!,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: CheckboxListTile(
                                          title: Text(
                                            leoId.leoId,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Arimo',
                                              color: isSelected ? const Color(0xFFB8860B) : Colors.black87,
                                            ),
                                          ),
                                          subtitle: Text(
                                            leoId.email,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontFamily: 'Arimo',
                                            ),
                                          ),
                              value: isSelected,
                                          activeColor: const Color(0xFFFFD700),
                                          checkColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    _selectedWebmasterIds.add(leoId.leoId);
                                  } else {
                                    _selectedWebmasterIds.remove(leoId.leoId);
                                  }
                                });
                              },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Manual entry section for super admin
                                if (isSuperAdmin) ...[
                                  Container(
                                    margin: const EdgeInsets.all(16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.add_circle_outline, size: 20, color: Colors.grey[700]),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Add Manually',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins',
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: leoIdController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Leo ID (e.g., LEO-12345)',
                                            hintStyle: TextStyle(color: Colors.grey[400]),
                                            prefixIcon: Icon(Icons.badge, color: Colors.grey[600]),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: Colors.grey[300]!),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: Colors.grey[300]!),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            isDense: true,
                                          ),
                                          style: const TextStyle(
                                            fontFamily: 'Arimo',
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textCapitalization: TextCapitalization.characters,
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              final leoId = leoIdController.text.trim().toUpperCase();
                                              if (leoId.isNotEmpty && !_selectedWebmasterIds.contains(leoId)) {
                                                setDialogState(() {
                                                  _selectedWebmasterIds.add(leoId);
                                                });
                                                leoIdController.clear();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Added $leoId'),
                                                    backgroundColor: Colors.green,
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                );
                                              } else if (leoId.isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('Please enter a Leo ID'),
                                                    backgroundColor: Colors.orange,
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('$leoId already added'),
                                                    backgroundColor: Colors.orange,
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.add, size: 18),
                                            label: const Text(
                                              'Add',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFFFD700),
                                              foregroundColor: Colors.black,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                ),
                // Modern footer with Done button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            leoIdController.dispose();
                            Navigator.pop(context);
                            setState(() {});
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            leoIdController.dispose();
                            Navigator.pop(context);
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Done',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              if (_selectedWebmasterIds.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_selectedWebmasterIds.length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if user is super admin
    if (!authProvider.isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Page'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Access denied. Super admin only.'),
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

          // "Create Page" title
          Positioned(
            left: MediaQuery.of(context).size.width * 0.1667 + ResponsiveUtils.dp(2),
            top: ResponsiveUtils.bh(48),
            child: Text(
              'Create\nPage',
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
            // Slightly lower the main form container for better spacing
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
      // Extra bottom margin so the form floats a bit above the bottom edge
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacingM,
        vertical: ResponsiveUtils.spacingS,
      ),
      decoration: BoxDecoration(
        // Slight transparency to match modern card style
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

              // Page Type
              _buildSectionLabel('Page Type *'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                children: [
                  Expanded(
                      child: _buildRadioOption('Club', 'club'),
                    ),
                    const SizedBox(width: 12),
                  Expanded(
                      child: _buildRadioOption('District', 'district'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Page Logo/Icon
              _buildSectionLabel('Page Icon (Optional)'),
              const SizedBox(height: 8),
              _buildImagePicker(
                onTap: _pickLogo,
                selectedImage: _selectedLogo,
                icon: Icons.add_photo_alternate,
                label: 'Tap to select icon',
                onRemove: _selectedLogo != null
                    ? () {
                        setState(() {
                          _selectedLogo = null;
                        });
                      }
                    : null,
              ),
              
              // Map Image (only for district pages)
              if (_selectedType == 'district') ...[
                const SizedBox(height: 24),
                _buildSectionLabel('Map Image (Required for District)'),
                const SizedBox(height: 8),
                _buildImagePicker(
                  onTap: _pickMapImage,
                  selectedImage: _selectedMapImage,
                  icon: Icons.map,
                  label: 'Tap to select map image',
                  onRemove: _selectedMapImage != null
                      ? () {
                          setState(() {
                            _selectedMapImage = null;
                          });
                        }
                      : null,
                ),
              ],
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                  hintText: 'Enter page description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Webmasters
              _buildSectionLabel('Webmasters *'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _showWebmasterSelector,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _selectedWebmasterIds.isEmpty
                            ? Text(
                                'Select webmasters',
                                style: TextStyle(color: Colors.grey[600]),
                              )
                            : Text(
                                '${_selectedWebmasterIds.length} webmaster(s) selected',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
              if (_selectedWebmasterIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedWebmasterIds.map((leoId) {
                    return Chip(
                      label: Text(leoId),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedWebmasterIds.remove(leoId);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPage,
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
                          'Create Page',
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

  Widget _buildRadioOption(String title, String value) {
    final isSelected = _selectedType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black,
                fontFamily: 'Nunito Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required VoidCallback onTap,
    XFile? selectedImage,
    required IconData icon,
    required String label,
    VoidCallback? onRemove,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: selectedImage == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.grey[50]!.withOpacity(0.9),
                  ],
                )
              : null,
          color: selectedImage != null ? null : Colors.transparent,
          border: Border.all(
            color: selectedImage == null
                ? AppColors.primary.withOpacity(0.3)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: selectedImage == null
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
        child: selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(selectedImage.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
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

// Bubble 01 - Black bubble (p36b3a180 path)
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

// Bubble 02 - Yellow bubble (p2c5a2d80 path)
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

// Bubble 04 - Yellow bubble at bottom (p2ec28100 path)
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
