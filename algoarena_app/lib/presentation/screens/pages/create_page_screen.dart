import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';

class CreatePageScreen extends StatefulWidget {
  const CreatePageScreen({super.key});

  @override
  State<CreatePageScreen> createState() => _CreatePageScreenState();
}

class _CreatePageScreenState extends State<CreatePageScreen>
    with TickerProviderStateMixin {
  final _pageNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  XFile? _selectedImage;
  bool _isLoading = false;
  String _selectedPageType = 'club'; // 'club' or 'district'
  
  late AnimationController _bubbleController;
  late AnimationController _fabController;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Background bubble animation
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _bubbleAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOut),
    );
    
    // FAB pulse animation
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _pageNameController.dispose();
    _descriptionController.dispose();
    _bubbleController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    _fabController.forward().then((_) => _fabController.reverse());
    
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _createPage() async {
    if (_pageNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a page name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate API call - In production, connect to backend
      await Future.delayed(const Duration(seconds: 1));
      
      // Create page data
      final newPage = {
        'name': _pageNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedPageType,
        'image': _selectedImage?.path,
        'followers': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedPageType == 'club' ? 'Club' : 'District'} page "${newPage['name']}" created successfully!'),
            backgroundColor: const Color(0xFF8F7902),
          ),
        );
        Navigator.pop(context, newPage); // Return the new page data
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Animated Background Bubbles
          AnimatedBuilder(
            animation: _bubbleAnimation,
            builder: (context, child) {
              return Positioned(
                right: -120,
                top: 100 + _bubbleAnimation.value,
                child: Opacity(
                  opacity: 0.08,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _bubbleAnimation,
            builder: (context, child) {
              return Positioned(
                left: -100,
                bottom: 150 - _bubbleAnimation.value * 0.7,
                child: Opacity(
                  opacity: 0.06,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Create Page',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isLoading ? null : _createPage,
                        child: Text(
                          'Create',
                          style: TextStyle(
                            color: _isLoading ? AppColors.disabled : const Color(0xFF8F7902),
                            fontFamily: 'Nunito Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page Type Selection
                          const Text(
                            'Page Type',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildPageTypeButton('club', 'Club Page'),
                              const SizedBox(width: 12),
                              _buildPageTypeButton('district', 'District Page'),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Page Logo/Image
                          const Text(
                            'Page Logo',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          if (_selectedImage != null) ...[
                            Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF8F7902),
                                      width: 3,
                                    ),
                                    image: DecorationImage(
                                      image: FileImage(File(_selectedImage!.path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: _removeImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          
                          ScaleTransition(
                            scale: _fabScaleAnimation,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: Text(
                                _selectedImage == null
                                    ? 'Add Logo'
                                    : 'Change Logo',
                                style: const TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF8F7902),
                                side: const BorderSide(color: Color(0xFF8F7902), width: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Page name field
                          const Text(
                            'Page Name *',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _pageNameController,
                            decoration: InputDecoration(
                              hintText: _selectedPageType == 'club'
                                  ? 'e.g., Leo Club of Colombo'
                                  : 'e.g., Leo District 306 D2',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF8F7902), width: 2),
                              ),
                              hintStyle: const TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                color: AppColors.textHint,
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Description field
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Tell people about this page...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF8F7902), width: 2),
                              ),
                              hintStyle: const TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 14,
                                color: AppColors.textHint,
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Create Page Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8F7902),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Create Page',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 80),
                        ],
                      ),
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

  Widget _buildPageTypeButton(String type, String label) {
    final isSelected = _selectedPageType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPageType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8F7902) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF8F7902) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
