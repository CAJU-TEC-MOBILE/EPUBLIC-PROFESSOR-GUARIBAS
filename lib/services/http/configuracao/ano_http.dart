import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';

import '../../shared_preference_service.dart';

class AnoHttp {
  Future<http.Response> getAll() async {
    final preference = SharedPreferenceService();
    String prefixUrl = 'notifiq-professor/aulas/anos';

    await preference.init();

    String? token = await preference.getToken();

    final url = Uri.parse(
      '${ApiBaseURLService.baseUrl}/$prefixUrl',
    );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(
      url,
      headers: headers,
    );

    return response;
  }
}
