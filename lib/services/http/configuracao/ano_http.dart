import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart'; 
import 'dart:convert';

class AnoHttp {
  Box authBox = Hive.box('auth');

  Future<Map<dynamic, dynamic>?> _getAuthData() async {
    return authBox.get('auth');
  }

  Future<http.Response> getAll() async {
    try {
      String prefixUrl = 'notifiq-professor/aulas/anos';

      Map<dynamic, dynamic>? authData = await _getAuthData();

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

      var response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
