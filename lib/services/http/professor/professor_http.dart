import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';

import 'dart:convert';

class ProfessorHttp {
  Box authBox = Hive.box('auth');

  Future<Map<dynamic, dynamic>?> _getAuthData() async {
    return authBox.get('auth');
  }

  Future<http.Response> atualizar(
      {required Map<String, dynamic> data, required String id}) async {
    try {
      String prefixUrl =
          'notifiq-professor/autorizacoes/atualizacao-professor-app/$id';

      Map<dynamic, dynamic>? authData = await _getAuthData();

      print("prefixUrl: $prefixUrl");
      print(authData!['token_atual']);

      if (authData == null || authData['token_atual'] == null) {
        throw Exception('Token not found');
      }

      var url = Uri.parse(
        '${ApiBaseURLService.baseUrl}/$prefixUrl',
      );

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData['token_atual']}',
      };

      var jsonBody = jsonEncode(data);

      var response = await http.put(
        url,
        headers: headers,
        body: jsonBody,
      );
      // print("id: $id");
      // print("data: $data");

      if (response.statusCode != 200) {
        print(response.body.toString());
        throw Exception('Failed to update: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
