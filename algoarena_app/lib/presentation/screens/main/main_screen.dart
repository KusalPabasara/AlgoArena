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
      
      // Trigger animation when switching to tabs with animations
      WidgetsBinding.instance.addPostFrameCallback((_) {
        switch (index) {
          case 0: // Home tab - refresh feed
            final homeScreenState = HomeScreen.globalKey.currentState;
            if (homeScreenState != null) {
              homeScreenState.refreshFeed();
            }
            break;
          case 1: // Search tab
            final searchScreenState = SearchScreen.globalKey.currentState;
            if (searchScreenState != null) {
              searchScreenState.restartAnimation();
            }
            break;
          case 2: // Events tab
            final eventsScreenState = EventsListScreen.globalKey.currentState;
            if (eventsScreenState != null) {
              eventsScreenState.restartAnimation();
            }
            break;
          case 3: // Pages tab
            final pagesScreenState = PagesScreen.globalKey.currentState;
            if (pagesScreenState != null) {
              pagesScreenState.restartAnimation();
            }
            break;
          case 4: // Profile tab
            final profileScreenState = ProfileScreen.globalKey.currentState;
            if (profileScreenState != null) {
              profileScreenState.restartAnimation();
            }
            break;
        }
      });
    }
  }
  
  // Public method to navigate to a specific tab (used by CustomBackButton)
  void navigateToTab(int index) {
    _onTabTapped(index);
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
        children: [
          HomeScreen(key: HomeScreen.globalKey),
          SearchScreen(key: SearchScreen.globalKey),
          EventsListScreen(key: EventsListScreen.globalKey),
          PagesScreen(key: PagesScreen.globalKey),
          ProfileScreen(key: ProfileScreen.globalKey),
        ],
      ),
      bottomNavigationBar: (widget.hideBottomNav || _isMenuOpen) ? null : AppBottomNav(
        currentIndex: _currentIndex,
        onTabChanged: _onTabTapped,
      ),
    );
  }
}

