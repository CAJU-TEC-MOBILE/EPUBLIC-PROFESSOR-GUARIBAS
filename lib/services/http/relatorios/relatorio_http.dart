import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../api_base_url_service.dart';

class RelatoriosHttp {
  final _authBox = Hive.box('auth');

  Future<Map?> _getAuthData() async {
    return _authBox.get('auth');
  }

  Future<http.Response> baixaAnexoFalta(
      {required String aulaId, required String matriculaId}) async {
    try {
      String prefixUrl =
          'relatorios/falta/baixar-documento/$aulaId/$matriculaId';

      var authData = await _getAuthData();

      if (authData == null || authData['token_atual'] == null) {
        throw Exception('Token not found');
      }

      var url = Uri.parse(
        '${ApiBaseURLService.baseUrl}/$prefixUrl',
      );

      var headers = {
        'Authorization': 'Bearer ${authData['token_atual']}',
      };

      var response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode != 200) {
        return response;
      }

      return response;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
