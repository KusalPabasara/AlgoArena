import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/utils/responsive.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authRepository = AuthRepository();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  File? _profileImage;
  final _picker = ImagePicker();
  bool _showSuccess = false; // Track if showing success view
  
  // Country selection
  String _selectedCountryCode = '+94';
  String _selectedCountryFlag = '🇱🇰';
  String _countrySearchQuery = '';
  
  final List<Map<String, String>> _countries = [
    {'name': 'Afghanistan', 'code': '+93', 'flag': '🇦🇫'},
    {'name': 'Albania', 'code': '+355', 'flag': '🇦🇱'},
    {'name': 'Algeria', 'code': '+213', 'flag': '🇩🇿'},
    {'name': 'Andorra', 'code': '+376', 'flag': '🇦🇩'},
    {'name': 'Angola', 'code': '+244', 'flag': '🇦🇴'},
    {'name': 'Argentina', 'code': '+54', 'flag': '🇦🇷'},
    {'name': 'Armenia', 'code': '+374', 'flag': '🇦🇲'},
    {'name': 'Australia', 'code': '+61', 'flag': '🇦🇺'},
    {'name': 'Austria', 'code': '+43', 'flag': '🇦🇹'},
    {'name': 'Azerbaijan', 'code': '+994', 'flag': '🇦🇿'},
    {'name': 'Bahrain', 'code': '+973', 'flag': '🇧🇭'},
    {'name': 'Bangladesh', 'code': '+880', 'flag': '🇧🇩'},
    {'name': 'Belarus', 'code': '+375', 'flag': '🇧🇾'},
    {'name': 'Belgium', 'code': '+32', 'flag': '🇧🇪'},
    {'name': 'Bhutan', 'code': '+975', 'flag': '🇧🇹'},
    {'name': 'Bolivia', 'code': '+591', 'flag': '🇧🇴'},
    {'name': 'Brazil', 'code': '+55', 'flag': '🇧🇷'},
    {'name': 'Brunei', 'code': '+673', 'flag': '🇧🇳'},
    {'name': 'Bulgaria', 'code': '+359', 'flag': '🇧🇬'},
    {'name': 'Cambodia', 'code': '+855', 'flag': '🇰🇭'},
    {'name': 'Canada', 'code': '+1', 'flag': '🇨🇦'},
    {'name': 'Chile', 'code': '+56', 'flag': '🇨🇱'},
    {'name': 'China', 'code': '+86', 'flag': '🇨🇳'},
    {'name': 'Colombia', 'code': '+57', 'flag': '🇨🇴'},
    {'name': 'Croatia', 'code': '+385', 'flag': '🇭🇷'},
    {'name': 'Cuba', 'code': '+53', 'flag': '🇨🇺'},
    {'name': 'Cyprus', 'code': '+357', 'flag': '🇨🇾'},
    {'name': 'Czech Republic', 'code': '+420', 'flag': '🇨🇿'},
    {'name': 'Denmark', 'code': '+45', 'flag': '🇩🇰'},
    {'name': 'Egypt', 'code': '+20', 'flag': '🇪🇬'},
    {'name': 'Estonia', 'code': '+372', 'flag': '🇪🇪'},
    {'name': 'Ethiopia', 'code': '+251', 'flag': '🇪🇹'},
    {'name': 'Finland', 'code': '+358', 'flag': '🇫🇮'},
    {'name': 'France', 'code': '+33', 'flag': '🇫🇷'},
    {'name': 'Georgia', 'code': '+995', 'flag': '🇬🇪'},
    {'name': 'Germany', 'code': '+49', 'flag': '🇩🇪'},
    {'name': 'Ghana', 'code': '+233', 'flag': '🇬🇭'},
    {'name': 'Greece', 'code': '+30', 'flag': '🇬🇷'},
    {'name': 'Hong Kong', 'code': '+852', 'flag': '🇭🇰'},
    {'name': 'Hungary', 'code': '+36', 'flag': '🇭🇺'},
    {'name': 'Iceland', 'code': '+354', 'flag': '🇮🇸'},
    {'name': 'India', 'code': '+91', 'flag': '🇮🇳'},
    {'name': 'Indonesia', 'code': '+62', 'flag': '🇮🇩'},
    {'name': 'Iran', 'code': '+98', 'flag': '🇮🇷'},
    {'name': 'Iraq', 'code': '+964', 'flag': '🇮🇶'},
    {'name': 'Ireland', 'code': '+353', 'flag': '🇮🇪'},
    {'name': 'Israel', 'code': '+972', 'flag': '🇮🇱'},
    {'name': 'Italy', 'code': '+39', 'flag': '🇮🇹'},
    {'name': 'Japan', 'code': '+81', 'flag': '🇯🇵'},
    {'name': 'Jordan', 'code': '+962', 'flag': '🇯🇴'},
    {'name': 'Kazakhstan', 'code': '+7', 'flag': '🇰🇿'},
    {'name': 'Kenya', 'code': '+254', 'flag': '🇰🇪'},
    {'name': 'Kuwait', 'code': '+965', 'flag': '🇰🇼'},
    {'name': 'Laos', 'code': '+856', 'flag': '🇱🇦'},
    {'name': 'Latvia', 'code': '+371', 'flag': '🇱🇻'},
    {'name': 'Lebanon', 'code': '+961', 'flag': '🇱🇧'},
    {'name': 'Libya', 'code': '+218', 'flag': '🇱🇾'},
    {'name': 'Lithuania', 'code': '+370', 'flag': '🇱🇹'},
    {'name': 'Luxembourg', 'code': '+352', 'flag': '🇱🇺'},
    {'name': 'Malaysia', 'code': '+60', 'flag': '🇲🇾'},
    {'name': 'Maldives', 'code': '+960', 'flag': '🇲🇻'},
    {'name': 'Mexico', 'code': '+52', 'flag': '🇲🇽'},
    {'name': 'Morocco', 'code': '+212', 'flag': '🇲🇦'},
    {'name': 'Myanmar', 'code': '+95', 'flag': '🇲🇲'},
    {'name': 'Nepal', 'code': '+977', 'flag': '🇳🇵'},
    {'name': 'Netherlands', 'code': '+31', 'flag': '🇳🇱'},
    {'name': 'New Zealand', 'code': '+64', 'flag': '🇳🇿'},
    {'name': 'Nigeria', 'code': '+234', 'flag': '🇳🇬'},
    {'name': 'Norway', 'code': '+47', 'flag': '🇳🇴'},
    {'name': 'Oman', 'code': '+968', 'flag': '🇴🇲'},
    {'name': 'Pakistan', 'code': '+92', 'flag': '🇵🇰'},
    {'name': 'Palestine', 'code': '+970', 'flag': '🇵🇸'},
    {'name': 'Peru', 'code': '+51', 'flag': '🇵🇪'},
    {'name': 'Philippines', 'code': '+63', 'flag': '🇵🇭'},
    {'name': 'Poland', 'code': '+48', 'flag': '🇵🇱'},
    {'name': 'Portugal', 'code': '+351', 'flag': '🇵🇹'},
    {'name': 'Qatar', 'code': '+974', 'flag': '🇶🇦'},
    {'name': 'Romania', 'code': '+40', 'flag': '🇷🇴'},
    {'name': 'Russia', 'code': '+7', 'flag': '🇷🇺'},
    {'name': 'Saudi Arabia', 'code': '+966', 'flag': '🇸🇦'},
    {'name': 'Serbia', 'code': '+381', 'flag': '🇷🇸'},
    {'name': 'Singapore', 'code': '+65', 'flag': '🇸🇬'},
    {'name': 'Slovakia', 'code': '+421', 'flag': '🇸🇰'},
    {'name': 'Slovenia', 'code': '+386', 'flag': '🇸🇮'},
    {'name': 'South Africa', 'code': '+27', 'flag': '🇿🇦'},
    {'name': 'South Korea', 'code': '+82', 'flag': '🇰🇷'},
    {'name': 'Spain', 'code': '+34', 'flag': '🇪🇸'},
    {'name': 'Sri Lanka', 'code': '+94', 'flag': '🇱🇰'},
    {'name': 'Sweden', 'code': '+46', 'flag': '🇸🇪'},
    {'name': 'Switzerland', 'code': '+41', 'flag': '🇨🇭'},
    {'name': 'Syria', 'code': '+963', 'flag': '🇸🇾'},
    {'name': 'Taiwan', 'code': '+886', 'flag': '🇹🇼'},
    {'name': 'Thailand', 'code': '+66', 'flag': '🇹🇭'},
    {'name': 'Turkey', 'code': '+90', 'flag': '🇹🇷'},
    {'name': 'Ukraine', 'code': '+380', 'flag': '🇺🇦'},
    {'name': 'United Arab Emirates', 'code': '+971', 'flag': '🇦🇪'},
    {'name': 'United Kingdom', 'code': '+44', 'flag': '🇬🇧'},
    {'name': 'United States', 'code': '+1', 'flag': '🇺🇸'},
    {'name': 'Uruguay', 'code': '+598', 'flag': '🇺🇾'},
    {'name': 'Uzbekistan', 'code': '+998', 'flag': '🇺🇿'},
    {'name': 'Venezuela', 'code': '+58', 'flag': '🇻🇪'},
    {'name': 'Vietnam', 'code': '+84', 'flag': '🇻🇳'},
    {'name': 'Yemen', 'code': '+967', 'flag': '🇾🇪'},
    {'name': 'Zimbabwe', 'code': '+263', 'flag': '🇿🇼'},
  ];
  
  // Animation controllers
  late AnimationController _contentController;
  late AnimationController _photoController;
  late AnimationController _buttonController;
  late AnimationController _bubbleRotationController;
  late AnimationController _contentSlideController;
  late AnimationController _contentFadeController;
  late AnimationController _successIconController;
  late AnimationController _successTextController;
  late AnimationController _successCheckController;
  late AnimationController _successBubbleRotationController;
  late AnimationController _successTitleController;
  late AnimationController _successGlowController;
  
  late Animation<double> _bubble1RotationAnimation;
  late Animation<double> _bubble2RotationAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _photoScaleAnimation;
  late Animation<double> _photoFadeAnimation;
  late Animation<double> _field0FadeAnimation; // Name field
  late Animation<double> _field1FadeAnimation;
  late Animation<double> _field2FadeAnimation;
  late Animation<double> _field3FadeAnimation;
  late Animation<double> _field4FadeAnimation;
  late Animation<double> _checkboxFadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _successIconSlideAnimation;
  late Animation<double> _successTextFadeAnimation;
  late Animation<double> _successCheckScaleAnimation;
  late Animation<double> _successCheckFadeAnimation;
  late Animation<double> _successCheckRotationAnimation;
  late Animation<Offset> _successCardSlideAnimation;
  late Animation<double> _successCardScaleAnimation;
  late Animation<double> _successTitleFadeAnimation;
  late Animation<Offset> _successTitleSlideAnimation;
  late Animation<double> _successSubtitleFadeAnimation;
  late Animation<double> _successGlowAnimation;
  late Animation<double> _successBubble1RotationAnimation;
  late Animation<double> _successBubble2RotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }
  
  void _setupAnimations() {
    // Content animations
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Title animations
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    
    // Photo upload animations
    _photoController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _photoScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _photoController, curve: Curves.easeInOut),
    );
    
    _photoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 0.4, curve: Curves.easeIn),
      ),
    );
    
    // Staggered field animations
    _field0FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _field1FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _field2FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.5, 0.7, curve: Curves.easeIn),
      ),
    );
    
    _field3FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );
    
    _field4FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.7, 0.9, curve: Curves.easeIn),
      ),
    );
    
    // Checkbox animation
    _checkboxFadeAnimation = Tween<double>(begin: 0.0, end: 3.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.7, 0.9, curve: Curves.easeIn),
      ),
    );
    
    // Button press animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    
    // Bubble rotation animation (for page entry and success transition)
    _bubbleRotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _bubble1RotationAnimation = Tween<double>(begin: -15, end: 45).animate(
      CurvedAnimation(parent: _bubbleRotationController, curve: Curves.easeInOutCubic),
    );
    
    _bubble2RotationAnimation = Tween<double>(begin: 15, end: -30).animate(
      CurvedAnimation(parent: _bubbleRotationController, curve: Curves.easeInOutCubic),
    );
    
    // Content slide up animation (entire content as one unit)
    _contentSlideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0), // Start from bottom
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentSlideController, curve: Curves.easeOutCubic),
    );
    
    // Content fade out animation
    _contentFadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _contentFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _contentFadeController, curve: Curves.easeOut),
    );
    
    // Success content staggered slide up animations
    _successIconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _successIconSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5), // Slide up from bottom
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _successIconController, curve: Curves.easeOutCubic),
    );
    
    _successTextController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _successTextFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successTextController, curve: Curves.easeIn),
    );
    
    // Success check mark animation (modern with bounce)
    _successCheckController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _successCheckScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_successCheckController);
    
    _successCheckFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successCheckController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _successCheckRotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _successCheckController,
        curve: Curves.easeOut,
      ),
    );
    
    // Success glow animation
    _successGlowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _successGlowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _successGlowController, curve: Curves.easeInOut),
    );
    
    // Success title animation
    _successTitleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    
    _successTitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successTitleController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _successTitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _successTitleController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _successSubtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successTitleController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    
    // Success bubble rotation animation (continues from register bubbles)
    _successBubbleRotationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Success bubbles start at current position (45° and -30°) and rotate just a little bit
    _successBubble1RotationAnimation = Tween<double>(begin: 45, end: 55).animate(
      CurvedAnimation(parent: _successBubbleRotationController, curve: Curves.easeInOutCubic),
    );
    
    _successBubble2RotationAnimation = Tween<double>(begin: -30, end: -40).animate(
      CurvedAnimation(parent: _successBubbleRotationController, curve: Curves.easeInOutCubic),
    );
    
    // Success card slide animation with scale
    _successCardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _successTextController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _successCardScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.02)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.02, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_successTextController);
  }
  
  void _startAnimations() {
    // Start bubble rotation to resting position (value 0.25) and content slide simultaneously on page entry
    _bubbleRotationController.animateTo(0.25);
    _contentSlideController.forward();
    _contentController.forward();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _contentController.dispose();
    _photoController.dispose();
    _buttonController.dispose();
    _bubbleRotationController.dispose();
    _contentSlideController.dispose();
    _contentFadeController.dispose();
    _successIconController.dispose();
    _successTextController.dispose();
    _successCheckController.dispose();
    _successBubbleRotationController.dispose();
    _successTitleController.dispose();
    _successGlowController.dispose();
    super.dispose();
  }

  Future<void> _handleBack() async {
    // Animate content sliding down and bubbles rotating back to initial position
    await Future.wait([
      _contentSlideController.reverse(),
      _bubbleRotationController.animateTo(0.0),
    ]);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    // Animate photo container
    _photoController.forward().then((_) => _photoController.reverse());
    
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Button press animation
    await _buttonController.forward();
    await _buttonController.reverse();

    setState(() => _isLoading = true);

    try {
      // Debug: Print registration data
      print('🔵 Registering user:');
      print('   Name: ${_nameController.text.trim()}');
      print('   Email: ${_emailController.text.trim()}');
      print('   Password: ${_passwordController.text.length} chars');
      
      final response = await _authRepository.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
      );

      // Debug: Print response
      print('✅ Registration successful:');
      print('   Token: ${response['token'] != null ? 'Received' : 'Missing'}');
      print('   User ID: ${response['user']?['id'] ?? 'N/A'}');

      if (mounted) {
        // Fade out current content
        await _contentFadeController.forward();
        
        // Continue bubble rotation to success position (from 0.25 to 1.0)
        // Wait for this animation to complete before showing success
        await _bubbleRotationController.animateTo(1.0);
        
        // Show success view (this will hide register bubbles and show success bubbles)
        setState(() {
          _showSuccess = true;
        });
        
        // Start success bubble rotation from current position (45° and -30°)
        // with a small additional rotation
        _successBubbleRotationController.forward();
        
        // Modern staggered animations
        _successIconController.forward();
        _successCheckController.forward();
        _successTextController.forward();
        _successTitleController.forward();
        _successGlowController.repeat();
        await Future.delayed(const Duration(milliseconds: 200));
        _successTextController.forward();
        
        // Wait 2 seconds before navigating to login
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      // Debug: Print error
      print('❌ Registration error: $e');
      
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Filter countries based on search query
            final filteredCountries = _countries.where((country) {
              final searchLower = _countrySearchQuery.toLowerCase();
              return country['name']!.toLowerCase().contains(searchLower) ||
                     country['code']!.contains(searchLower);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      // Header
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          'Select Country',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF202020),
                          ),
                        ),
                      ),
                      
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: TextField(
                          onChanged: (value) {
                            setModalState(() {
                              _countrySearchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search country...',
                            hintStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Color(0xFF999999),
                            ),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF999999)),
                            suffixIcon: _countrySearchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      setModalState(() {
                                        _countrySearchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      
                      const Divider(),
                      
                      // Country List
                      Expanded(
                        child: filteredCountries.isEmpty
                            ? const Center(
                                child: Text(
                                  'No countries found',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: filteredCountries.length,
                                itemBuilder: (context, index) {
                                  final country = filteredCountries[index];
                                  final isSelected = _selectedCountryCode == country['code'];
                                  
                                  return ListTile(
                                    leading: Text(
                                      country['flag']!,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                    title: Text(
                                      country['name']!,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: isSelected ? const Color(0xFFFFD700) : Colors.black87,
                                      ),
                                    ),
                                    trailing: Text(
                                      country['code']!,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? const Color(0xFFFFD700) : Colors.grey[600],
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedTileColor: const Color(0xFFFFD700).withOpacity(0.1),
                                    onTap: () {
                                      setState(() {
                                        _selectedCountryCode = country['code']!;
                                        _selectedCountryFlag = country['flag']!;
                                        _countrySearchQuery = ''; // Reset search
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms and Conditions'),
        content: const SingleChildScrollView(
          child: Text(
            'By registering, you agree to our terms of service and privacy policy...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Calculate responsive scale factor - uses new responsive helper
  double _getScaleFactor(BuildContext context) {
    return ResponsiveHelper.getScaleFactor(context);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _getScaleFactor(context);
    // Only apply scaling if screen is smaller (scale < 1.0)
    final shouldScale = scale < 1.0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Register screen bubbles - only show when not showing success
          if (!_showSuccess) ...[
            // Static Yellow Bubble (Top-Left) - Bit larger
            AnimatedBuilder(
              animation: _bubble1RotationAnimation,
              builder: (context, child) {
                return Positioned(
                  left: -100,
                  top: -60,
                  child: Transform.rotate(
                    angle: _bubble1RotationAnimation.value * (3.14159 / 180),
                    child: ClipPath(
                      clipper: _RegisterBubble02Clipper(),
                      child: Container(
                        width: 320,
                        height: 380,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Static Black Bubble (Top-Right) - Moved more to the right
            AnimatedBuilder(
              animation: _bubble2RotationAnimation,
              builder: (context, child) {
                return Positioned(
                  right: -150,
                  top: 0,
                  child: Transform.rotate(
                    angle: _bubble2RotationAnimation.value * (3.14159 / 180),
                    child: ClipPath(
                      clipper: _RegisterBubble01Clipper(),
                      child: Container(
                        width: 320,
                        height: 380,
                        decoration: const BoxDecoration(
                          color: Color(0xFF02091A),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          
          // Main Content Layer - with fade out animation
          if (!_showSuccess)
            FadeTransition(
              opacity: _contentFadeAnimation,
              child: SafeArea(
                child: Column(
                  children: [
                // Back Button - Black circular border with black arrow
                Padding(
                  padding: EdgeInsets.all(shouldScale ? 16.0 * scale : 16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: shouldScale ? 2 * scale : 2),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black, size: shouldScale ? 24 * scale : 24),
                        onPressed: _handleBack,
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: shouldScale ? 35 * scale : 35,
                      right: shouldScale ? 35 * scale : 35,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 40, // Extra padding for keyboard
                    ),
                    child: Form(
                      key: _formKey,
                      child: SlideTransition(
                        position: _contentSlideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 0),
                        
                        // Animated "Create Account" Title
                        FadeTransition(
                        opacity: _titleFadeAnimation,
                        child: Text(
                            'Create\nAccount',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                                fontSize: shouldScale ? 52 * scale : 52,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF202020),
                                letterSpacing: shouldScale ? -0.52 * scale : -0.52,
                                height: 1.17,
                            ),
                          ),
                      ),
                      
                      SizedBox(height: shouldScale ? 30 * scale : 30),
                      
                      // Animated Face Icon
                      FadeTransition(
                        opacity: _photoFadeAnimation,
                        child: ScaleTransition(
                          scale: _photoScaleAnimation,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: SizedBox(
                              width: shouldScale ? 100 * scale : 100,
                              height: shouldScale ? 100 * scale : 100,
                              child: _profileImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _profileImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/download-removebg-preview 1.png',
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Animated Name Input Field - Material Design
                      FadeTransition(
                        opacity: _field0FadeAnimation,
                        child: TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name is required';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: shouldScale ? 19 * scale : 19,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              hintStyle: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: shouldScale ? 19 * scale : 19,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.4),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: shouldScale ? 24 * scale : 24,
                                vertical: shouldScale ? 14 * scale : 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                      ),
                      
                      SizedBox(height: shouldScale ? 12 * scale : 12),
                      
                      // Animated Email Input Field - Material Design
                      FadeTransition(
                        opacity: _field1FadeAnimation,
                        child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            validator: Validators.validateEmail,
                            style: TextStyle(
                               fontFamily: 'Nunito Sans',
                                    fontSize: shouldScale ? 19 * scale : 19,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white, // W
                            ),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                 fontFamily: 'Nunito Sans',
                                    fontSize: shouldScale ? 19 * scale : 19,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white, // W
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.4),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: shouldScale ? 24 * scale : 24,
                                vertical: shouldScale ? 14 * scale : 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                      ),
                      
                      SizedBox(height: shouldScale ? 12 * scale : 12),
                      
                      // Animated Password Input - Material Design
                      FadeTransition(
                        opacity: _field2FadeAnimation,
                        child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            style: TextStyle(
                               fontFamily: 'Nunito Sans',
                                    fontSize: shouldScale ? 19 * scale : 19,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white, // W
                            ),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                 fontFamily: 'Nunito Sans',
                                    fontSize: shouldScale ? 19 * scale : 19,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white, // W
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.4),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: shouldScale ? 24 * scale : 24,
                                vertical: shouldScale ? 12 * scale : 12,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.white70,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                      ),
                      
                      SizedBox(height: shouldScale ? 12 * scale : 12),
                      
                      // Animated Confirm Password Input - Material Design
                      FadeTransition(
                        opacity: _field3FadeAnimation,
                        child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            autofocus: false,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              // Submit form when done
                              if (_formKey.currentState!.validate()) {
                                _handleRegister();
                              }
                            },
                            style: TextStyle(
                               fontFamily: 'Nunito Sans',
                                    fontSize: shouldScale ? 19 * scale : 19,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white, // W
                            ),
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              hintStyle: TextStyle(
                                 fontFamily: 'Nunito Sans',
                                    fontSize: shouldScale ? 19 * scale : 19,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white, // W
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.4),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: shouldScale ? 24 * scale : 24,
                                vertical: shouldScale ? 12 * scale : 12,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.white70,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                      ),
                      
                      SizedBox(height: shouldScale ? 12 * scale : 12),
                      
                      // Animated Phone Number Input - Material Design
                      FadeTransition(
                        opacity: _field4FadeAnimation,
                        child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            style: TextStyle(
                               fontFamily: 'Nunito Sans',
                                    fontSize: shouldScale ? 19 * scale : 19,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white, // W
                            ),
                            decoration: InputDecoration(
                              hintText: 'Your number',
                              hintStyle: TextStyle(
                                fontFamily: 'Nunito Sans',
                                    fontSize: shouldScale ? 19 * scale : 19,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white, // W
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.4),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: shouldScale ? 24 * scale : 24,
                                vertical: shouldScale ? 12 * scale : 12,
                              ),
                              prefixIcon: InkWell(
                                onTap: _showCountryPicker,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 16),
                                    Text(_selectedCountryFlag, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down, color: Colors.white70),
                                    Container(
                                      margin: const EdgeInsets.only(left: 8, right: 12),
                                      width: 1,
                                      height: 28,
                                      color: Colors.white38,
                                    ),
                                    Text(
                                      _selectedCountryCode,
                                      style: const TextStyle(
                                         fontFamily: 'Nunito Sans',
                                          fontSize: 19,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white, // W
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                      ),
                      
                      SizedBox(height: shouldScale ? 10 * scale : 10),
                      
                      // Animated Checkbox
                      FadeTransition(
                        opacity: _checkboxFadeAnimation,
                        child: Row(
                          children: [
                            SizedBox(
                              width: shouldScale ? 24 * scale : 24,
                              height: shouldScale ? 24 * scale : 24,
                              child: Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToTerms = value ?? false;
                                  });
                                },
                                activeColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(shouldScale ? 4 * scale : 4),
                                ),
                              ),
                            ),
                            SizedBox(width: shouldScale ? 8 * scale : 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: _showTermsAndConditions,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'I agree All ',
                                    style: TextStyle(
                                       fontFamily: 'Nunito Sans',
                                    fontSize: shouldScale ? 16 * scale : 16,
                                    fontWeight: FontWeight.w300,
                                    color: Color.fromARGB(255, 0, 0, 0), // W,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms and Conditions',
                                        style: TextStyle(
                                          color: Color(0xFF0088FF),
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w500,
                                          fontSize: shouldScale ? 16 * scale : 16,
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
                      
                      SizedBox(height: shouldScale ? 10 * scale : 10),
                      
                      // Animated Register Button - Material Design
                      FadeTransition(
                        opacity: _checkboxFadeAnimation,
                        child: ScaleTransition(
                          scale: _buttonScaleAnimation,
                          child: SizedBox(
                            width: double.infinity,
                            height: shouldScale ? 56 * scale : 56,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.3),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                    : Text(
                                      'Register',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: shouldScale ? 18 * scale : 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: shouldScale ? 5 * scale : 5),
                      
                      // Animated Cancel Button
                      FadeTransition(
                        opacity: _checkboxFadeAnimation,
                        child: Center(
                          child: TextButton(
                            onPressed: _handleCancel,
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: shouldScale ? 16 * scale : 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      
                    
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Success View - Beautiful Material Design Animation
          if (_showSuccess)
            Positioned.fill(
              child: Stack(
                children: [
                  // Blurred background with dark overlay
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFF5F5F5),
                            const Color(0xFFFFFFFF),
                            const Color(0xFFF0F9FF),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Dark overlay for darker blur effect
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  // Content
                  SafeArea(
                    bottom: false,
                    top: false,
                    child: Stack(
                      children: [
                      
                      // Success Screen Bubbles with rotation animation
                      AnimatedBuilder(
                        animation: _successBubble1RotationAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: -100,
                            top: -60,
                            child: Transform.rotate(
                              angle: _successBubble1RotationAnimation.value * (3.14159 / 180),
                              child: ClipPath(
                                clipper: _RegisterBubble02Clipper(),
                                child: Container(
                                  width: 320,
                                  height: 380,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFD700),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      AnimatedBuilder(
                        animation: _successBubble2RotationAnimation,
                        builder: (context, child) {
                          return Positioned(
                            right: -150,
                            top: 0,
                            child: Transform.rotate(
                              angle: _successBubble2RotationAnimation.value * (3.14159 / 180),
                              child: ClipPath(
                                clipper: _RegisterBubble01Clipper(),
                                child: Container(
                                  width: 320,
                                  height: 380,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF02091A),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Main content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Modern check icon with glow animation
                          SlideTransition(
                            position: _successIconSlideAnimation,
                            child: FadeTransition(
                              opacity: _successCheckFadeAnimation,
                              child: AnimatedBuilder(
                                animation: _successGlowController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _successCheckRotationAnimation.value,
                                    child: Transform.scale(
                                      scale: _successCheckScaleAnimation.value,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Subtle ripple effect
                                          ...List.generate(2, (index) {
                                            final delay = index * 0.5;
                                            final rippleValue = ((_successGlowAnimation.value + delay) % 1.0);
                                            final scale = 1.0 + (rippleValue * 0.3);
                                            final opacity = (1.0 - rippleValue).clamp(0.0, 0.3);
                                            
                                            return Transform.scale(
                                              scale: scale,
                                              child: Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(0xFF4CAF50).withOpacity(opacity),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                          // Pulsing glow effect
                                          Container(
                                            width: 140 + (_successGlowAnimation.value * 20),
                                            height: 140 + (_successGlowAnimation.value * 20),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  const Color(0xFF4CAF50).withOpacity(_successGlowAnimation.value * 0.2),
                                                  const Color(0xFF4CAF50).withOpacity(0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Main checkmark circle
                                          Container(
                                            width: 120,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF66BB6A),
                                                  Color(0xFF4CAF50),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF4CAF50).withOpacity(0.3 + _successGlowAnimation.value * 0.2),
                                                  blurRadius: 25 + (_successGlowAnimation.value * 10),
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              size: 70,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // Modern success card with enhanced design
                          SlideTransition(
                            position: _successCardSlideAnimation,
                            child: ScaleTransition(
                              scale: _successCardScaleAnimation,
                              child: FadeTransition(
                                opacity: _successTextFadeAnimation,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,
                                          const Color(0xFFFAFAFA),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 30,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 10),
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                                          blurRadius: 20,
                                          spreadRadius: -5,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                        child: Container(
                                          padding: const EdgeInsets.all(36),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(28),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Animated title
                                              SlideTransition(
                                                position: _successTitleSlideAnimation,
                                                child: FadeTransition(
                                                  opacity: _successTitleFadeAnimation,
                                                  child: const Text(
                                                    'Account Created!',
                                                    style: TextStyle(
                                                      fontFamily: 'Raleway',
                                                      fontSize: 42,
                                                      fontWeight: FontWeight.w800,
                                                      color: Color(0xFF1A1A1A),
                                                      letterSpacing: -1,
                                                      height: 1.2,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              
                                              const SizedBox(height: 16),
                                              
                                              // Animated gradient line
                                              AnimatedBuilder(
                                                animation: _successTitleController,
                                                builder: (context, child) {
                                                  final width = 80 * _successTitleFadeAnimation.value;
                                                  return Container(
                                                    height: 5,
                                                    width: width,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      gradient: const LinearGradient(
                                                        colors: [
                                                          Color(0xFF4CAF50),
                                                          Color(0xFF66BB6A),
                                                          Color(0xFF81C784),
                                                        ],
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color(0xFF4CAF50).withOpacity(0.4),
                                                          blurRadius: 8,
                                                          spreadRadius: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              
                                              const SizedBox(height: 24),
                                              
                                              // Animated welcome message
                                              FadeTransition(
                                                opacity: _successSubtitleFadeAnimation,
                                                child: Column(
                                                  children: [
                                                    const Text(
                                                      'Welcome to',
                                                      style: TextStyle(
                                                        fontFamily: 'Nunito Sans',
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color(0xFF666666),
                                                        letterSpacing: 0.5,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    ShaderMask(
                                                      shaderCallback: (bounds) => const LinearGradient(
                                                        colors: [
                                                          Color(0xFF4CAF50),
                                                          Color(0xFF66BB6A),
                                                        ],
                                                      ).createShader(bounds),
                                                      child: const Text(
                                                        'Leo Connect',
                                                        style: TextStyle(
                                                          fontFamily: 'Nunito Sans',
                                                          fontSize: 28,
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.white,
                                                          letterSpacing: 0.5,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              const SizedBox(height: 16),
                                              
                                              // Animated description
                                              FadeTransition(
                                                opacity: _successSubtitleFadeAnimation,
                                                child: const Text(
                                                  'Your account has been created\nsuccessfully.',
                                                  style: TextStyle(
                                                    fontFamily: 'Nunito Sans',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF666666),
                                                    height: 1.6,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              
                                              const SizedBox(height: 32),
                                              
                                              // Modern loading indicator
                                              FadeTransition(
                                                opacity: _successSubtitleFadeAnimation,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      SizedBox(
                                                        width: 18,
                                                        height: 18,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2.5,
                                                          valueColor: AlwaysStoppedAnimation<Color>(
                                                            const Color(0xFF4CAF50),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Text(
                                                        'Redirecting to login...',
                                                        style: TextStyle(
                                                          fontFamily: 'Nunito Sans',
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w500,
                                                          color: Color(0xFF4CAF50),
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Success Dialog Widget
class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog({Key? key}) : super(key: key);

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Full screen background with organic shapes
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF5A5A5A),
            child: Stack(
              children: [
                // Olive/Yellow organic shape top-left
                Positioned(
                  top: -150,
                  left: -100,
                  child: ClipPath(
                    clipper: _SuccessDialogOliveShapeClipper(),
                    child: Container(
                      width: 400,
                      height: 350,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF8B7D2B),
                            Color(0xFF6B5D1B),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),

                // Black organic shape top-right
                Positioned(
                  top: -50,
                  right: -150,
                  child: ClipPath(
                    clipper: _SuccessDialogBlackShapeClipper(),
                    child: Container(
                      width: 450,
                      height: 400,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dialog card
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated checkmark with double circle
                    ScaleTransition(
                      scale: _checkmarkAnimation,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer green circle
                          Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4ADE80),
                                  Color(0xFF22C55E),
                                ],
                              ),
                            ),
                          ),
                          // Inner white circle with checkmark
                          Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF22C55E),
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Successfully\nRegistered!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 24,
                          ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Please Login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).popUntil((route) => route.isFirst); // Go to login
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper for olive/yellow organic shape in success dialog
class _SuccessDialogOliveShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.cubicTo(
      size.width * 0.3, size.height * 0.2,
      size.width * 0.6, size.height * 0.3,
      size.width, 0,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Clipper for black organic shape in success dialog
class _SuccessDialogBlackShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.3, 0);
    path.cubicTo(
      size.width * 0.6, size.height * 0.2,
      size.width * 0.4, size.height * 0.5,
      size.width, size.height * 0.7,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom Clipper for Register Bubble 01 (Black bubble - from SVG)
class _RegisterBubble01Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final scaleX = size.width / 244;
    final scaleY = size.height / 267;
    
    // SVG path: M122.23 23.973C179.747 -54.2618 243.628 78.3248 243.628 145.371C243.628 212.418 189.276 266.77 122.23 266.77C55.1834 266.77 -8.01705 215.723 0.831575 145.371C9.6802 75.0195 64.7126 102.208 122.23 23.973Z
    path.moveTo(122.23 * scaleX, 23.973 * scaleY);
    path.cubicTo(
      179.747 * scaleX, -54.2618 * scaleY,
      243.628 * scaleX, 78.3248 * scaleY,
      243.628 * scaleX, 145.371 * scaleY,
    );
    path.cubicTo(
      243.628 * scaleX, 212.418 * scaleY,
      189.276 * scaleX, 266.77 * scaleY,
      122.23 * scaleX, 266.77 * scaleY,
    );
    path.cubicTo(
      55.1834 * scaleX, 266.77 * scaleY,
      -8.01705 * scaleX, 215.723 * scaleY,
      0.831575 * scaleX, 145.371 * scaleY,
    );
    path.cubicTo(
      9.6802 * scaleX, 75.0195 * scaleY,
      64.7126 * scaleX, 102.208 * scaleY,
      122.23 * scaleX, 23.973 * scaleY,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Custom Clipper for Register Bubble 02 (Yellow bubble - from SVG)
class _RegisterBubble02Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final scaleX = size.width / 303;
    final scaleY = size.height / 376;
    
    // SVG path: M224.374 319.747C191.353 449.079 29.2324 323.656 7.13194 227.533C-14.9685 131.41 13.8919 44.8161 99.3459 10.2904C184.8 -24.2353 254.604 33.0762 292.299 108.465C329.993 183.854 257.396 190.414 224.374 319.747Z
    path.moveTo(224.374 * scaleX, 319.747 * scaleY);
    path.cubicTo(
      191.353 * scaleX, 449.079 * scaleY,
      29.2324 * scaleX, 323.656 * scaleY,
      7.13194 * scaleX, 227.533 * scaleY,
    );
    path.cubicTo(
      -14.9685 * scaleX, 131.41 * scaleY,
      13.8919 * scaleX, 44.8161 * scaleY,
      99.3459 * scaleX, 10.2904 * scaleY,
    );
    path.cubicTo(
      184.8 * scaleX, -24.2353 * scaleY,
      254.604 * scaleX, 33.0762 * scaleY,
      292.299 * scaleX, 108.465 * scaleY,
    );
    path.cubicTo(
      329.993 * scaleX, 183.854 * scaleY,
      257.396 * scaleX, 190.414 * scaleY,
      224.374 * scaleX, 319.747 * scaleY,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

