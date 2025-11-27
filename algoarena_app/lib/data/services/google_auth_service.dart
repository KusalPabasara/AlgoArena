import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  // Server client ID (web client) from Firebase Console
  // This is required to get an ID token for backend verification
  static const String _serverClientId = '978327533730-vua3vomj6l1hdjf006shh7chigj5aceh.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _serverClientId,
  );

  final ApiService _apiService = ApiService();

  /// Sign in with Google
  /// Returns user data if successful, throws exception on failure
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Get Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      // idToken may be null if serverClientId is not properly configured
      // or if the Android OAuth client is not set up in Google Cloud Console
      if (idToken == null) {
        // Fall back to using access token and Google user info for backend verification
        print('Warning: ID token is null, using access token flow');
      }

      // Send to backend to verify and create/login user
      // Backend can verify either the ID token or use the Google user info
      final response = await _apiService.post('/auth/google-signin', {
        'idToken': idToken,
        'accessToken': accessToken,
        'email': googleUser.email,
        'displayName': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
        'googleId': googleUser.id,
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
    } on Exception catch (e) {
      print('Google sign-in error: $e');
      rethrow;
    } catch (e) {
      print('Google sign-in unexpected error: $e');
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _apiService.deleteToken();
  }

  /// Check if user is currently signed in with Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current Google user (if signed in)
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
