import 'dart:async';
import 'package:http/http.dart' as http;
import '../../api_base_url_service.dart';
import '../../shared_preference_service.dart';

class SolicitacaoHttp {
  Future<http.Response> all() async {
    final preference = SharedPreferenceService();

    await preference.init();

    String? token = await preference.getToken();

    String prefixUrl =
        '${ApiBaseURLService.baseUrl}/notifiq-professor/configuracao/solicitacoes';

    final url = Uri.parse(prefixUrl);

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response;
  }
}
