class AppConfig {
  static const String _defaultApiHost =
      'payment-cluster-load-balancer-1798404675.eu-west-2.elb.amazonaws.com:9000';

  static String get apiHost => const String.fromEnvironment(
        'API_HOST',
        defaultValue: _defaultApiHost,
      );

  static String get baseUrl => 'http://$apiHost';
  static String get apiUrl => '$baseUrl/api';
}
