import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';

import '../../../models/tipo_aula_model.dart';
import '../../controller/tipo_aula_controller.dart';
import '../../shared_preference_service.dart';

class ConfiguracaoHttp {
  Future<http.Response> getTiposAulas() async {
    try {
      final preference = SharedPreferenceService();
      final tipoAulaController = TipoAulaController();

      await preference.init();

      String? token = await preference.getToken();
      String endpoint = 'notifiq-professor/configuracao/tipos-aulas';

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

  Future<http.Response> horarios() async {
    final preference = SharedPreferenceService();

    await preference.init();

    String? token = await preference.getToken();

    String endpoint = 'notifiq-professor/configuracao/horarios';

    final uri = Uri.parse('${ApiBaseURLService.baseUrl}/$endpoint');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(uri, headers: headers);

    return response;
  }
}
