import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';

import '../../../models/tipo_aula_model.dart';
import '../../controller/tipo_aula_controller.dart';

class ConfiguracaoHttp {
  final Box<dynamic> _authBox = Hive.box('auth');

  Future<String?> _getToken() async {
    final authData = _authBox.get('auth');

    if (authData is Map && authData.containsKey('token_atual')) {
      return authData['token_atual'] as String?;
    }

    return null;
  }

  Future<http.Response> getTiposAulas({required String token}) async {
    try {
      final tipoAulaController = TipoAulaController();
      debugPrint('[-BAIXA DADOS DO TIPO DE AULA-]');
      const endpoint = 'notifiq-professor/configuracao/tipos-aulas';

      final uri = Uri.parse('${ApiBaseURLService.baseUrl}/$endpoint');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar tipos de aula: ${response.statusCode}');
      }

      final decoded = json.decode(response.body);
      final List<String> tipos = List<String>.from(decoded['tipos']);
      await tipoAulaController.init();
      await tipoAulaController.clear();
      for (String descricao in tipos) {
        final model = TipoAula(
          id: '0',
          descricao: descricao,
        );
        await tipoAulaController.add(model);
      }
      return response;
    } catch (e, stacktrace) {
      debugPrint('Erro ao buscar tipos de aula: $e');
      debugPrint('Stacktrace: $stacktrace');
      rethrow;
    }
  }
}
