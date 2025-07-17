import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_base_url_service.dart';
import '../../shared_preference_service.dart';

class ProfessorHttp {
  final preference = SharedPreferenceService();
  Future<http.Response> atualizar(
      {required Map<String, dynamic> data, required String id}) async {
    try {
      String prefixUrl =
          'notifiq-professor/autorizacoes/atualizacao-professor-app/$id';
      await preference.init();
      String? token = await preference.getToken();
      var url = Uri.parse(
        '${ApiBaseURLService.baseUrl}/$prefixUrl',
      );
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var jsonBody = jsonEncode(data);
      var response = await http.put(
        url,
        headers: headers,
        body: jsonBody,
      );
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
