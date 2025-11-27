import '../models/user.dart';
import '../services/api_service.dart';
import '../services/google_auth_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  
  // Register new user
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiService.post('/auth/register', {
        'fullName': fullName,
        'email': email,
        'password': password,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      });
      
      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  // Check if user exists and get display info
  Future<Map<String, dynamic>> checkUser(String email) async {
    try {
      final response = await _apiService.post('/auth/check-user', {
        'email': email,
      });
      return response;
    } catch (e) {
      // Return not found for any error
      return {
        'exists': false,
        'message': 'User not found'
      };
    }
  }
  
  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      
      // Save token if login successful
      if (response['token'] != null) {
        await _apiService.saveToken(response['token']);
      }
      
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      await _apiService.deleteToken();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
  
  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiService.post('/auth/forgot-password', {
        'email': email,
      });
      
      return response;
    } catch (e) {
      throw Exception('Failed to send reset link: $e');
    }
  }
  
  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post('/auth/reset-password', {
        'token': token,
        'newPassword': newPassword,
      });
      
      return response;
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }
  
  // Get current user
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me', withAuth: true);
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }
  
  // Verify Leo ID
  Future<User> verifyLeoId(String leoId) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-leo-id',
        {'leoId': leoId},
        withAuth: true,
      );
      
      return User.fromJson(response['user']);
    } catch (e) {
      throw Exception('Failed to verify Leo ID: $e');
    }
  }
  
  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    return token != null;
  }
  
  // Google Sign-In
  Future<Map<String, dynamic>> googleSignIn() async {
    try {
      // GoogleAuthService handles everything: Google sign-in, Firebase auth, backend call, token storage
      final result = await _googleAuthService.signInWithGoogle();
      return result;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }
  
  // Google Sign-Out
  Future<void> googleSignOut() async {
    try {
      await _googleAuthService.signOut();
      await _apiService.deleteToken();
    } catch (e) {
      throw Exception('Google Sign-Out failed: $e');
    }
  }
}
