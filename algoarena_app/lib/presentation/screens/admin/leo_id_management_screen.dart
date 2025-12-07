import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../data/repositories/leo_id_repository.dart';
import '../../../data/models/leo_id.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/responsive_utils.dart';
import '../../widgets/custom_back_button.dart';

/// Leo ID Management Screen - Modern & Beautiful Design
class LeoIdManagementScreen extends StatefulWidget {
  const LeoIdManagementScreen({Key? key}) : super(key: key);

  @override
  State<LeoIdManagementScreen> createState() => _LeoIdManagementScreenState();
}

class _LeoIdManagementScreenState extends State<LeoIdManagementScreen> with SingleTickerProviderStateMixin {
  final _leoIdRepository = LeoIdRepository();
  final _leoIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  List<LeoId> _leoIds = [];
  bool _isLoading = true;
  bool _isAdding = false;
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
    _leoIdController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLeoIds() async {
    setState(() => _isLoading = true);
    try {
      final leoIds = await _leoIdRepository.getAllLeoIds();
      setState(() {
        _leoIds = leoIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load Leo IDs: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _addLeoId() async {
    if (_leoIdController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in Leo ID and Email'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      await _leoIdRepository.addLeoId(
        leoId: _leoIdController.text.trim(),
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim().isEmpty 
            ? null 
            : _fullNameController.text.trim(),
      );

      _leoIdController.clear();
      _emailController.clear();
      _fullNameController.clear();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Leo ID added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        _loadLeoIds();
      }
    } catch (e) {
      setState(() => _isAdding = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add Leo ID: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _deleteLeoId(String leoIdId, String leoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Leo ID',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to delete $leoId? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _leoIdRepository.deleteLeoId(leoIdId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Leo ID deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          _loadLeoIds();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  Future<void> _createLeoIdByEmail() async {
    final emailController = TextEditingController();
    final clubNameController = TextEditingController();
    bool isCreating = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.email_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Create Leo ID by Email',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'Enter user email address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: clubNameController,
                  decoration: InputDecoration(
                    labelText: 'Club Name (Optional)',
                    hintText: 'Enter club name',
                    prefixIcon: const Icon(Icons.business_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'A Leo ID will be generated and sent to the user\'s email.',
                          style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isCreating ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isCreating ? null : () async {
                          if (emailController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Please enter an email address'),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isCreating = true);

                          try {
                            final result = await _leoIdRepository.createLeoIdByEmail(
                              emailController.text.trim(),
                            );

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result['message'] ?? 'Leo ID created and sent successfully'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                              _loadLeoIds();
                            }
                          } catch (e) {
                            setDialogState(() => isCreating = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to create Leo ID: ${e.toString().replaceAll('Exception: ', '')}'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isCreating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Create & Send'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDialog() {
    _leoIdController.clear();
    _emailController.clear();
    _fullNameController.clear();
    setState(() => _isAdding = false);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Add Leo ID Manually',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _leoIdController,
                decoration: InputDecoration(
                  labelText: 'Leo ID *',
                  hintText: 'Enter Leo ID',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  hintText: 'Enter email address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name (Optional)',
                  hintText: 'Enter full name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : () async {
                        await _addLeoId();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isAdding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Add'),
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

  String _getInitials(String leoId) {
    if (leoId.length >= 2) {
      return leoId.substring(0, 2).toUpperCase();
    }
    return 'LE';
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if user is super admin
    if (!authProvider.isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Leo ID Management'),
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
                    left: ResponsiveUtils.bw(50),
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
                    left: ResponsiveUtils.bw(-8.17),
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

          // "Leo ID Management" title - positioned after bubbles so it's on top
          Positioned(
            left: MediaQuery.of(context).size.width * 0.1667 + ResponsiveUtils.dp(2),
            top: ResponsiveUtils.bh(48),
            child: Text(
              'Leo ID\nManagement',
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
            top: ResponsiveUtils.bh(155),
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.spacingM,
        vertical: ResponsiveUtils.spacingS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Buttons Section - Fixed, not scrollable
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.email_outlined,
                    label: 'Create by Email',
                    isPrimary: true,
                    onTap: _createLeoIdByEmail,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add,
                    label: 'Add Manually',
                    isPrimary: false,
                    onTap: _showAddDialog,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Leo IDs List - Scrollable only, in black transparent container
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 26),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : _leoIds.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadLeoIds,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _leoIds.length,
                            itemBuilder: (context, index) {
                              final leoId = _leoIds[index];
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 300 + (index * 50)),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildLeoIdCard(leoId),
                              );
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            // Primary button: soft yellow with slight transparency
            // Secondary button: solid white to avoid washed-out look
            color: isPrimary 
                ? AppColors.primary.withOpacity(0.85) 
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? null : Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: (isPrimary ? AppColors.primary : Colors.grey).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Nunito Sans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeoIdCard(LeoId leoId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
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
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(leoId.leoId),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Nunito Sans',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leoId.leoId,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Nunito Sans',
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (leoId.email.isNotEmpty)
                        Text(
                          leoId.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontFamily: 'Nunito Sans',
                          ),
                        ),
                      if (leoId.fullName != null && leoId.fullName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            leoId.fullName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Nunito Sans',
                            ),
                          ),
                        ),
                      ],
                      if (leoId.isUsed) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 12, color: Colors.green[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Nunito Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Delete Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _deleteLeoId(leoId.id, leoId.leoId),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Leo IDs Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Nunito Sans',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by creating your first Leo ID',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Nunito Sans',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                icon: Icons.email_outlined,
                label: 'Create Leo ID by Email',
                isPrimary: true,
                onTap: _createLeoIdByEmail,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                icon: Icons.add,
                label: 'Add Leo ID Manually',
                isPrimary: false,
                onTap: _showAddDialog,
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
