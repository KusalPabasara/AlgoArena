import '../services/api_service.dart';

class PasswordRecoveryRepository {
  final ApiService _apiService = ApiService();

  /// Send OTP to email for password reset
  Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      final response = await _apiService.post(
        '/auth/forgot-password',
        {'email': email},
      );
      return {
        'success': true,
        'message': response['message'] ?? 'OTP sent successfully',
        'email': response['email'],
        'otp': response['otp'], // Only in dev mode
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-otp',
        {'email': email, 'otp': otp},
      );
      return {
        'success': true,
        'message': response['message'] ?? 'OTP verified successfully',
        'verified': response['verified'] ?? true,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOTP(String email) async {
    try {
      final response = await _apiService.post(
        '/auth/resend-otp',
        {'email': email},
      );
      return {
        'success': true,
        'message': response['message'] ?? 'OTP resent successfully',
        'otp': response['otp'], // Only in dev mode
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  /// Reset password
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    try {
      final response = await _apiService.post(
        '/auth/reset-password',
        {'email': email, 'newPassword': newPassword},
      );
      return {
        'success': response['success'] ?? true,
        'message': response['message'] ?? 'Password reset successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
