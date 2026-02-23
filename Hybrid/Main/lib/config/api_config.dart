import 'package:flutter/foundation.dart' show kReleaseMode;

class ApiConfig {
  static const String _envUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    // If defined via --dart-define (build time)
    if (_envUrl.isNotEmpty) return _envUrl;

    // Local debug mode
    if (!kReleaseMode) return 'http://localhost:3000';

    // Default for deployed builds — served behind same domain proxy
    return '/api';
  }
}