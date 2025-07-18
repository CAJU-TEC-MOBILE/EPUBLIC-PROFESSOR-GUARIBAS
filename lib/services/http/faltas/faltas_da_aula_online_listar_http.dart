import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:async';

import '../../shared_preference_service.dart';

class FaltasDaAulaOnlineListarHttp {
  final preference = SharedPreferenceService();

  Future<http.Response> executar({required String aula_id}) async {
    await preference.init();
    String? token = await preference.getToken();
    String prefix_url = 'notifiq-professor/aulas/todas-as-faltas-online/aula';
    var url = Uri.parse(
      '${ApiBaseURLService.baseUrl}/$prefix_url/$aula_id',
    );
    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response;
    } catch (e) {
      print(e);
    }
    return http.Response('', 500);
  }
}
