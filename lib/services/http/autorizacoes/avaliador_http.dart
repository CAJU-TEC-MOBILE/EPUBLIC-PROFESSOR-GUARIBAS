import 'dart:async';
import 'package:http/http.dart' as http;
import '../../api_base_url_service.dart';
import '../../shared_preference_service.dart';

class AvaliadorHttp {
  Future<http.Response> all() async {
    String prefixUrl =
        '${ApiBaseURLService.baseUrl}/notifiq-professor/configuracao/avaliadores';

    final preference = SharedPreferenceService();

    await preference.init();

    String? token = await preference.getToken();

    final Uri url = Uri.parse(prefixUrl);

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
