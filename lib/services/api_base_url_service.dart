class ApiBaseURLService {
  // static const String _baseUrl = 'https://guaribasapi.servidorcaju.com.br';
  // static const String _baseParaDNS = 'guaribasapi.servidorcaju.com.br';

  //php artisan serve --host 0.0.0.0 --port 8000
  static const String _baseUrl = 'http://10.0.0.220:8000';
  static const String _baseParaDNS = '10.0.0.220';

  // TEMPO DE REQUISIÇÃO
  static const int _tempoDeDuracaoEmSegundos = 1000000000;

  static String get baseUrl => _baseUrl;

  static String get baseParaDNS => _baseParaDNS;

  static int get tempoDeDuracaoEmSegundos => _tempoDeDuracaoEmSegundos;
}
