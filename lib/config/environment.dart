/// Environment configuration for AlgoArena
/// 
/// This file controls which backend the app connects to.
/// 
/// For DEVELOPMENT: Use `Environment.development`
/// For PRODUCTION: Use `Environment.production` and set your deployed URL
/// 
/// HOW TO SWITCH:
/// In main.dart, change: `Environment.init(EnvironmentType.development)`
/// to: `Environment.init(EnvironmentType.production)`

enum EnvironmentType {
  development,
  production,
}

class Environment {
  static late EnvironmentType _currentEnvironment;
  static bool _initialized = false;

  /// Initialize the environment (call this in main.dart before runApp)
  static void init(EnvironmentType env) {
    _currentEnvironment = env;
    _initialized = true;
  }

  /// Get current environment type
  static EnvironmentType get current {
    if (!_initialized) {
      // Default to development if not initialized
      _currentEnvironment = EnvironmentType.development;
      _initialized = true;
    }
    return _currentEnvironment;
  }

  /// Check if running in production
  static bool get isProduction => current == EnvironmentType.production;

  /// Check if running in development
  static bool get isDevelopment => current == EnvironmentType.development;

  /// Get the base API URL based on environment
  static String get apiBaseUrl {
    switch (current) {
      case EnvironmentType.development:
        // For Android Emulator use: http://10.0.2.2:5000/api
        // For iOS Simulator use: http://localhost:5000/api
        // For physical device on same network: http://YOUR_COMPUTER_IP:5000/api
        return 'http://10.0.2.2:5000/api';
      
      case EnvironmentType.production:
        // ========================================
        // 🚀 PRODUCTION BACKEND URL - DigitalOcean VPS
        // ========================================
        // VPS IP: 152.42.240.220
        // Works from ANY device, anywhere in the world!
        return 'http://152.42.240.220:5000/api';
    }
  }

  /// Get environment name for logging
  static String get name {
    switch (current) {
      case EnvironmentType.development:
        return 'Development';
      case EnvironmentType.production:
        return 'Production';
    }
  }
}
