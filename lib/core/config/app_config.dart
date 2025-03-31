class AppConfig {
  static const String _defaultApiHost = 'localhost:9000';

  static String get apiHost => const String.fromEnvironment(
        'API_HOST',
        defaultValue: _defaultApiHost,
      );

  static String get baseUrl => 'http://$apiHost';
  static String get apiUrl => '$baseUrl/api';
}
