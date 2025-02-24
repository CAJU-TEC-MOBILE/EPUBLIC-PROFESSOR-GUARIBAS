class ApiBaseURLService {
  //static const String _baseParaDNS = 'apiveramendes.servidorcaju.com.br';
  // API DAS REQUISIÇÕES E VARIÁVEL PARA UMA FUNÇÃO QUE IRÁ VEIRIFCAR CONEXÃO COM INTERNET
  //static const String _baseUrl = 'https://homologacaoapi.veramendes.servidorcaju.com.br';

  static const String _baseUrl = 'https://veramendesapi.servidorcaju.com.br';
  static const String _baseParaDNS = 'veramendesapi.servidorcaju.com.br';

  //static const String _baseUrl = 'https:/'/develop.apirosario.servidorcaju.com.br';
  //static const String _baseParaDNS = 'develop.apirosario.servidorcaju.com.br';

  // static const String _baseUrl = 'https://apirosario.servidorcaju.com.br';
  // static const String _baseParaDNS = 'apirosario.servidorcaju.com.br';

  //php artisan serve --host 0.0.0.0 --port 8000
  // static const String _baseUrl = 'http://192.168.0.143:8000';
  // static const String _baseParaDNS = '192.168.0.143';

  // TEMPO DE REQUISIÇÃO
  static const int _tempoDeDuracaoEmSegundos = 25;

  static String get baseUrl => _baseUrl;

  static String get baseParaDNS => _baseParaDNS;

  static int get tempoDeDuracaoEmSegundos => _tempoDeDuracaoEmSegundos;
}
