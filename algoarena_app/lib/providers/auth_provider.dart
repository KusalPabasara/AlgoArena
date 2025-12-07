import 'package:flutter/foundation.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  // Super Admin pre-set credentials
  static const String _superAdminEmail = 'superadmin@algoarena.com';
  static const String _superAdminPassword = 'AlgoArena@2024!';

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuperAdmin => _user?.isSuperAdmin ?? false;

  // Check if user is authenticated on app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final authenticated = await _authRepository.isAuthenticated();
      _isAuthenticated = authenticated;
      
      if (authenticated) {
        _user = await _authRepository.getCurrentUser();
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login - includes Super Admin handling
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check for Super Admin credentials - try backend first, fallback to local
      if (email.toLowerCase() == _superAdminEmail.toLowerCase() && 
          password == _superAdminPassword) {
        try {
          // Try to login through backend API first to get a token
          final response = await _authRepository.login(email: email, password: password);
          _user = User.fromJson(response['user']);
          _isAuthenticated = true;
          _isLoading = false;
          notifyListeners();
          return true;
        } catch (e) {
          // If backend login fails, show error instead of falling back to local
          // This ensures super admin has backend access for API calls
          String errorMsg = e.toString().replaceAll('Exception: ', '');
          print('⚠️ Backend login failed for super admin: $errorMsg');
          
          // Check if it's a timeout error
          if (errorMsg.contains('timeout') || errorMsg.contains('Timeout')) {
            _error = 'Connection timeout. The backend server may be slow or unreachable. Please check:\n\n1. Your internet connection\n2. Backend server is running\n3. Try again in a moment';
          } else if (errorMsg.contains('Invalid credentials') || 
              errorMsg.contains('User data not found') ||
              errorMsg.contains('EMAIL_NOT_FOUND')) {
            _error = 'Super admin account not found in backend. Please contact system administrator to create the account.';
          } else if (errorMsg.contains('Network error') || errorMsg.contains('Failed host lookup')) {
            _error = 'Cannot connect to backend server. Please check your internet connection and ensure the backend is running.';
          } else {
            _error = 'Backend login failed: $errorMsg\n\nPlease check your internet connection and try again.';
          }
          
          _isAuthenticated = false;
          _user = null;
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Regular login through API
      final response = await _authRepository.login(email: email, password: password);
      _user = User.fromJson(response['user']);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Extract error message properly
      String errorMessage = e.toString();
      errorMessage = errorMessage.replaceAll('Exception: ', '');
      errorMessage = errorMessage.replaceAll('Login failed: ', '');
      errorMessage = errorMessage.replaceAll('INVALID_LOGIN_CREDENTIALS', 'Invalid email or password');
      
      // Ensure we have a valid error message
      if (errorMessage.isEmpty || errorMessage == 'null' || errorMessage.trim().isEmpty) {
        errorMessage = 'Invalid email or password';
      }
      
      // Debug: Print error for troubleshooting
      print('🔴 Login Error in AuthProvider: $errorMessage');
      print('🔴 Setting _error to: $errorMessage');
      
      _error = errorMessage;
      _isAuthenticated = false;
      _user = null;
      _isLoading = false;
      
      print('🔴 About to call notifyListeners()...');
      notifyListeners();
      print('🔴 notifyListeners() completed');
      
      print('🔴 AuthProvider returning false, _error is now: $_error');
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      _user = User.fromJson(response['user']);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
      _user = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      _user = await _authRepository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      // Handle error silently or logout
    }
  }

  // Update user data (e.g., after Leo ID verification)
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
