import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../widgets/custom_icons.dart';

class SideMenu extends StatelessWidget {
  final User? user;
  
  const SideMenu({Key? key, this.user}) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await AuthRepository().logout();
      
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.black,
                    backgroundImage: user?.profilePhoto != null
                        ? CachedNetworkImageProvider(user!.profilePhoto!)
                        : null,
                    child: user?.profilePhoto == null
                        ? Text(
                            user?.fullName[0].toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.blackOpacity60,
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(color: AppColors.black, height: 1),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.home,
                    title: AppStrings.home,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: CustomIcons.profile(size: 24, color: AppColors.black),
                    title: AppStrings.profile,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About District',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.group,
                    title: 'Executive Committee',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/executive');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.assistant,
                    title: 'LeoAssist',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/leo-assist');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.contact_mail,
                    title: 'Contact Us',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/contact');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: CustomIcons.pages(size: 28, color: AppColors.black),
                    title: AppStrings.pages,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/pages');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: CustomIcons.search(size: 24, color: AppColors.black),
                    title: AppStrings.search,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/search');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications,
                    title: AppStrings.notifications,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
                    title: AppStrings.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),
            
            const Divider(color: AppColors.black, height: 1),
            
            // Logout
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: AppStrings.logout,
              onTap: () => _handleLogout(context),
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    dynamic icon, // Can be IconData or Widget
    required String title,
    required VoidCallback onTap,
  }) {
    Widget iconWidget;
    if (icon is IconData) {
      iconWidget = Icon(icon, color: AppColors.black);
    } else if (icon is Widget) {
      iconWidget = icon;
    } else {
      iconWidget = const Icon(Icons.error, color: AppColors.black);
    }
    
    return ListTile(
      leading: iconWidget,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
