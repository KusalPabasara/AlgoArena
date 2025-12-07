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
import 'presentation/screens/auth/verify_email_otp_screen.dart';
import 'presentation/screens/auth/new_password_screen.dart';
import 'presentation/screens/auth/password_reset_success_screen.dart';
import 'presentation/screens/auth/verify_sms_screen.dart';
import 'presentation/screens/auth/reset_password_screen.dart';
import 'presentation/screens/auth/password_recovery_screen.dart';
import 'presentation/screens/auth/password_entry_screen.dart';
import 'presentation/screens/main/main_screen.dart';
import 'presentation/screens/post/create_post_screen.dart';
import 'presentation/screens/notifications/notifications_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/contact/contact_us_screen.dart';
import 'presentation/screens/about/about_screen.dart';
import 'presentation/screens/executive/executive_committee_screen.dart';
import 'presentation/screens/leo_assist/leo_assist_screen.dart';
import 'presentation/screens/events/event_detail_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/club_provider.dart';
import 'providers/page_follow_provider.dart';

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
  Environment.init(EnvironmentType.production);  // <-- USING VPS BACKEND
  
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
        ChangeNotifierProvider(create: (_) => PageFollowProvider()),
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
                profileImageUrl: args?['profilePhoto'] ?? args?['profileImageUrl'],
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
          if (settings.name == '/verify-email-otp') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => VerifyEmailOTPScreen(
                email: args?['email'] ?? '',
              ),
            );
          }
          if (settings.name == '/new-password') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => NewPasswordScreen(
                email: args?['email'] ?? '',
              ),
            );
          }
          if (settings.name == '/password-reset-success') {
            return MaterialPageRoute(
              builder: (context) => const PasswordResetSuccessScreen(),
            );
          }
          
          // Handle MainScreen routes - prevent duplicate GlobalKey usage
          if (settings.name == '/home' || settings.name == '/search' || 
              settings.name == '/events' || settings.name == '/pages' || 
              settings.name == '/profile') {
            final existingState = MainScreen.globalKey.currentState;
            final tabIndex = settings.name == '/home' ? 0 :
                           settings.name == '/search' ? 1 :
                           settings.name == '/events' ? 2 :
                           settings.name == '/pages' ? 3 : 4;
            
            // If MainScreen with GlobalKey already exists, navigate to tab instead of creating new
            if (existingState != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                existingState.navigateToTab(tabIndex);
              });
              // Return a route that redirects to home (which has the MainScreen)
              return MaterialPageRoute(
                builder: (context) {
                  // Navigate to home route which has MainScreen, then switch tab
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushReplacementNamed('/home');
                    existingState.navigateToTab(tabIndex);
                  });
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                },
              );
            }
            
            // No MainScreen exists - create one
            // CRITICAL: Only use GlobalKey for /home route to prevent duplicates
            final useGlobalKey = settings.name == '/home';
            return MaterialPageRoute(
              builder: (context) => MainScreen(
                key: useGlobalKey ? MainScreen.globalKey : null,
                initialIndex: tabIndex,
              ),
            );
          }
          
          return null;
        },
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/forgot-password': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final email = args is Map<String, dynamic> ? args['email'] as String? : null;
            return ForgotPasswordScreen(email: email);
          },
          '/password-recovery': (context) => const PasswordRecoveryScreen(),
          '/register': (context) => const RegisterScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/create-post': (context) => const CreatePostScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/contact': (context) => const ContactUsScreen(),
          '/about': (context) => const AboutScreen(),
          '/executive': (context) => const ExecutiveCommitteeScreen(),
          '/leo-assist': (context) => const LeoAssistScreen(),
        },
      ),
    );
  }
}
