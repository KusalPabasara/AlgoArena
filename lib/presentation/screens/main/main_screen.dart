import 'package:flutter/material.dart';
import '../../widgets/app_bottom_nav.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../events/events_list_screen.dart';
import '../pages/pages_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final bool hideBottomNav;
  static final GlobalKey<_MainScreenState> globalKey = GlobalKey<_MainScreenState>();
  
  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.hideBottomNav = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  bool _isMenuOpen = false;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }
  
  // Public method to set menu state (called from HomeScreen via dynamic invocation)
  void setMenuOpen(bool isOpen) {
    if (mounted) {
      setState(() {
        _isMenuOpen = isOpen;
      });
    }
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
  
  // Make this method accessible from child widgets
  static void navigateToHome(BuildContext context) {
    final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();
    if (mainScreenState != null) {
      mainScreenState._onTabTapped(0);
    } else {
      // Fallback: navigate to home route
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          SearchScreen(),
          EventsListScreen(),
          PagesScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: (widget.hideBottomNav || _isMenuOpen) ? null : AppBottomNav(
        currentIndex: _currentIndex,
        onTabChanged: _onTabTapped,
      ),
    );
  }
}

