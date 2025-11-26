import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/environment.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/password_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/auth/verify_sms_screen.dart';
import 'presentation/screens/auth/reset_password_screen.dart';
import 'presentation/screens/auth/password_recovery_screen.dart';
import 'presentation/screens/auth/password_entry_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/pages/pages_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/post/create_post_screen.dart';
import 'presentation/screens/notifications/notifications_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/contact/contact_us_screen.dart';
import 'presentation/screens/about/about_screen.dart';
import 'presentation/screens/executive/executive_committee_screen.dart';
import 'presentation/screens/leo_assist/leo_assist_screen.dart';
import 'presentation/screens/events/events_list_screen.dart';
import 'presentation/screens/events/event_detail_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/club_provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized for async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // ========================================
  // 🔧 ENVIRONMENT CONFIGURATION
  // ========================================
  // For DEVELOPMENT (local backend): Use EnvironmentType.development
  // For PRODUCTION (deployed backend): Use EnvironmentType.production
  // 
  // Before building production APK:
  // 1. Deploy your backend to Railway/Render/etc
  // 2. Update the URL in lib/config/environment.dart
  // 3. Change this to EnvironmentType.production
  // ========================================
  Environment.init(EnvironmentType.production);  // <-- CHANGED TO PRODUCTION
  
  // Log environment for debugging
  debugPrint('🌍 Environment: ${Environment.name}');
  debugPrint('🔗 API URL: ${Environment.apiBaseUrl}');
  
  // Optimize system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  // Lock to portrait mode for consistent UI
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const AlgoArenaApp());
}

class AlgoArenaApp extends StatelessWidget {
  const AlgoArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ClubProvider()),
      ],
      child: MaterialApp(
        title: 'AlgoArena',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Handle routes with parameters
          if (settings.name == '/password') {
            final args = settings.arguments as Map<String, dynamic>?;
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => PasswordScreen(
                email: args?['email'] ?? '',
                userName: args?['userName'],
                profileImageUrl: args?['profileImageUrl'],
              ),
              transitionDuration: const Duration(milliseconds: 900),
              reverseTransitionDuration: const Duration(milliseconds: 900),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Simple fade transition - no slide
                // (Password screen handles its own content animations)
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              opaque: false, // Allow Login bubbles to show through
              barrierColor: Colors.transparent,
              barrierDismissible: false,
            );
          }
          if (settings.name == '/password-entry') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => PasswordEntryScreen(
                username: args?['username'] ?? 'User',
              ),
            );
          }
          if (settings.name == '/verify-sms') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => VerifySmsScreen(
                phoneNumber: args?['phoneNumber'],
                email: args?['email'],
              ),
            );
          }
          if (settings.name == '/event-detail') {
            final eventId = settings.arguments as String?;
            if (eventId == null) return null;
            return MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: eventId),
            );
          }
          return null;
        },
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/password-recovery': (context) => const PasswordRecoveryScreen(),
          '/register': (context) => const RegisterScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/search': (context) => const SearchScreen(),
          '/pages': (context) => const PagesScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/create-post': (context) => const CreatePostScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/contact': (context) => const ContactUsScreen(),
          '/about': (context) => const AboutScreen(),
          '/executive': (context) => const ExecutiveCommitteeScreen(),
          '/leo-assist': (context) => const LeoAssistScreen(),
          '/events': (context) => const EventsListScreen(),
        },
      ),
    );
  }
}
