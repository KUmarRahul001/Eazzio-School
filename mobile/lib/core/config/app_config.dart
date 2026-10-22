
class AppConfig {
  // Configurable base URL
  // Reads from compile-time / runtime environment (--dart-define=API_BASE_URL=...)
  // Falls back to platform-appropriate defaults if not provided in env.
  static String get defaultBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    return 'https://eazzio-school.onrender.com/api';
  }

  static String baseUrl = defaultBaseUrl;

  static void setBaseUrl(String url) {
    if (url.endsWith('/')) {
      baseUrl = url.substring(0, url.length - 1);
    } else {
      baseUrl = url;
    }
  }

  static String get uploadsBaseUrl {
    // If baseUrl is http://10.0.2.2:5000/api, uploadsBaseUrl is http://10.0.2.2:5000
    final uri = Uri.tryParse(baseUrl);
    if (uri != null && uri.hasPort) {
      return '${uri.scheme}://${uri.host}:${uri.port}';
    } else if (uri != null) {
      return '${uri.scheme}://${uri.host}';
    }
    return 'http://10.0.2.2:5000';
  }

  static const String appName = 'Eazzio-School';
  static const String appVersion = '1.0.0';
}
