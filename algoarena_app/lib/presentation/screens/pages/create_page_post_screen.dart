import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/page_post_service.dart';

/// Create Page Post Screen - For webmasters to create posts on club/district pages
class CreatePagePostScreen extends StatefulWidget {
  final String? clubId;
  final String? districtId;
  final String pageName;

  const CreatePagePostScreen({
    super.key,
    this.clubId,
    this.districtId,
    required this.pageName,
  });

  @override
  State<CreatePagePostScreen> createState() => _CreatePagePostScreenState();
}

class _CreatePagePostScreenState extends State<CreatePagePostScreen> {
  final _contentController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final images = await _imagePicker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      final remainingSlots = 5 - _selectedImages.length;
      final imagesToAdd = images.take(remainingSlots);
      
      setState(() {
        _selectedImages.addAll(imagesToAdd.map((xFile) => File(xFile.path)));
      });
    }
  }

  Future<void> _takePhoto() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _createPost() async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content or images'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic>? result;

      if (widget.clubId != null) {
        result = await PagePostService.createClubPost(
          clubId: widget.clubId!,
          content: content,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
        );
      } else if (widget.districtId != null) {
        result = await PagePostService.createDistrictPost(
          districtId: widget.districtId!,
          content: content,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
        );
      }

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF02091A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Post',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF02091A),
              ),
            ),
            Text(
              widget.pageName,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isLoading ? null : _createPost,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content input
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontFamily: 'Inter',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Image preview
            if (_selectedImages.isNotEmpty) ...[
              const Text(
                'Photos',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImages[index],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Add photo buttons
            Row(
              children: [
                Expanded(
                  child: _MediaButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: _pickImages,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MediaButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: _takePhoto,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Text(
              '${_selectedImages.length}/5 photos added',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
