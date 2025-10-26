// lib/core/config/api_config.dart

class ApiConfig {
  static String get baseUrl {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    
    switch (env) {
      case 'prod':
        return 'https://api.ouestmonfric.com/api';
      case 'staging':
        return 'https://api-staging.ouestmonfric.com/api';
      default:
        // Pour Chrome/Web, on utilise directement localhost
        return 'http://localhost:3000/api';
    }
  }
  
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}