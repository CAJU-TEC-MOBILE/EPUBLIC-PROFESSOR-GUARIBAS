import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import '../../shared_preference_service.dart';

class AutorizacoesListarHttp {
  Future<http.Response> executar() async {
    final preference = SharedPreferenceService();
    await preference.init();
    String? token = await preference.getToken();
    String prefix_url =
        'notifiq-professor/autorizacoes/listar_autorizacoes_do_usuario';
    final url = Uri.parse(
      '${ApiBaseURLService.baseUrl}/$prefix_url',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}
