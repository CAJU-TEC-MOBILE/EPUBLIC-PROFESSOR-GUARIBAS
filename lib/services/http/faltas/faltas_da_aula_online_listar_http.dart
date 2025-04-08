import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:async';

class FaltasDaAulaOnlineListarHttp {
  Box authBox = Hive.box('auth');

  Future<Map<dynamic, dynamic>?> _getAuthData() async {
    return authBox.get('auth');
  }

  Future<http.Response> executar({required String aula_id}) async {
    Map<dynamic, dynamic>? authData = await _getAuthData();
    String prefix_url = 'notifiq-professor/aulas/todas-as-faltas-online/aula';

    // final tempoDeDuracaoEmSegundos =
    //     Duration(seconds: ApiBaseURLService.tempoDeDuracaoEmSegundos);
    var url = Uri.parse(
      '${ApiBaseURLService.baseUrl}/${prefix_url}/${aula_id}',
    );

    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${authData!['token_atual']}',
        },
      ); //.timeout(tempoDeDuracaoEmSegundos);

      return response;
    } catch (e) {
      print(e);
    }

    return http.Response('', 500);
  }
}
