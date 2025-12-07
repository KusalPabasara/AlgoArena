import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import 'api_service.dart';

class AppleAuthService {
  static final AppleAuthService _instance = AppleAuthService._internal();
  factory AppleAuthService() => _instance;
  AppleAuthService._internal();

  final ApiService _apiService = ApiService();

  /// Sign in with Apple
  /// Returns user data if successful, throws exception on failure
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      // Check if Apple Sign-In is available (iOS 13+ or macOS 10.15+)
      if (!Platform.isIOS && !Platform.isMacOS) {
        throw Exception('Apple Sign-In is only available on iOS and macOS');
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Extract user information
      final String? userIdentifier = appleCredential.userIdentifier;
      final String? email = appleCredential.email;
      final String? givenName = appleCredential.givenName;
      final String? familyName = appleCredential.familyName;
      final String? identityToken = appleCredential.identityToken;
      final String? authorizationCode = appleCredential.authorizationCode;

      if (userIdentifier == null) {
        throw Exception('Apple Sign-In failed: User identifier is missing');
      }

      // Build display name from given and family name
      String? displayName;
      if (givenName != null || familyName != null) {
        displayName = [givenName, familyName].where((n) => n != null).join(' ');
      }

      // Send to backend to verify and create/login user
      final response = await _apiService.post('/auth/apple-signin', {
        'userIdentifier': userIdentifier,
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        'email': email,
        'displayName': displayName,
        'givenName': givenName,
        'familyName': familyName,
      });

      // Save token if login successful
      if (response['token'] != null) {
        await _apiService.saveToken(response['token']);
      }

      return {
        'success': true,
        'user': response['user'],
        'token': response['token'],
        'isNewUser': response['isNewUser'] ?? false,
      };
    } on SignInWithAppleAuthorizationException catch (e) {
      // Handle Apple Sign-In specific exceptions
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw Exception('Apple Sign-In was cancelled');
        case AuthorizationErrorCode.failed:
          throw Exception('Apple Sign-In failed');
        case AuthorizationErrorCode.invalidResponse:
          throw Exception('Invalid response from Apple');
        case AuthorizationErrorCode.notHandled:
          throw Exception('Apple Sign-In not handled');
        case AuthorizationErrorCode.unknown:
          throw Exception('Unknown Apple Sign-In error');
        default:
          throw Exception('Apple Sign-In error: ${e.code}');
      }
    } catch (e) {
      print('Apple sign-in error: $e');
      throw Exception('Apple sign-in failed: $e');
    }
  }

  /// Check if Apple Sign-In is available on this platform
  bool get isAvailable => Platform.isIOS || Platform.isMacOS;
}

