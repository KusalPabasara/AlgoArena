import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../data/repositories/post_repository.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with TickerProviderStateMixin {
  final _contentController = TextEditingController();
  final _postRepository = PostRepository();
  final _imagePicker = ImagePicker();
  
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  
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
    _contentController.dispose();
    _bubbleController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    _fabController.forward().then((_) => _fabController.reverse());
    
    try {
      final images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          if (_selectedImages.length > 5) {
            _selectedImages = _selectedImages.sublist(0, 5);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick images'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content or images'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Convert XFiles to File paths for upload
      final imagePaths = _selectedImages.map((xFile) => xFile.path).toList();
      
      await _postRepository.createPost(
        content: _contentController.text.trim(),
        imagePaths: imagePaths,
      );

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
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
                      color: AppColors.primary.withOpacity(0.25),
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
                      color: Colors.black.withOpacity(0.12),
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
                        AppStrings.createPost,
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isLoading ? null : _createPost,
                        child: Text(
                          AppStrings.post,
                          style: TextStyle(
                            color: _isLoading ? AppColors.disabled : AppColors.primary,
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
                          // Content text field
                          TextField(
                            controller: _contentController,
                            maxLines: 8,
                            decoration: const InputDecoration(
                              hintText: "What's on your mind?",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 16,
                                color: AppColors.textHint,
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Animated Selected images
                          if (_selectedImages.isNotEmpty) ...[
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  return _AnimatedImagePreview(
                                    imagePath: _selectedImages[index].path,
                                    index: index,
                                    onRemove: () => _removeImage(index),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Add images button with animation
                          if (_selectedImages.length < 5)
                            ScaleTransition(
                              scale: _fabScaleAnimation,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _pickImages,
                                icon: const Icon(Icons.photo_library),
                                label: Text(
                                  _selectedImages.isEmpty
                                      ? 'Add Photos'
                                      : 'Add More Photos (${_selectedImages.length}/5)',
                                  style: const TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary, width: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Loading indicator
                          if (_isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
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
}

/// Animated Image Preview Widget
class _AnimatedImagePreview extends StatefulWidget {
  final String imagePath;
  final int index;
  final VoidCallback onRemove;

  const _AnimatedImagePreview({
    required this.imagePath,
    required this.index,
    required this.onRemove,
  });

  @override
  State<_AnimatedImagePreview> createState() => _AnimatedImagePreviewState();
}

class _AnimatedImagePreviewState extends State<_AnimatedImagePreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Staggered animation
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleRemove() {
    _controller.reverse().then((_) {
      widget.onRemove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: 120,
          margin: const EdgeInsets.only(right: 8),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.file(
                    File(widget.imagePath),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Remove button with animation
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _handleRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.black.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
