import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:async';

import '../../../models/auth_model.dart';
import '../../controller/auth_controller.dart';
import '../../shared_preference_service.dart';

class AulasListarTodasHttp {
  final Box gestaoAtivaBox = Hive.box('gestao_ativa');

  Future<http.Response> executar() async {
    try {
      final gestaoAtivaData = await _getGestaoAtivaData();
      if (gestaoAtivaData == null) {
        return http.Response('Gestão ativa não encontrada.', 500);
      }

      final authController = AuthController();
      final preference = SharedPreferenceService();

      await authController.init();
      await preference.init();

      final String? token = await preference.getToken();
      AuthModel auth = await authController.authFirst();

      if (token == null || auth.id == '') {
        return http.Response('Token ou autenticação ausente.', 401);
      }

      final String prefixUrl =
          'notifiq-professor/aulas/todas-as-aulas/gestao-ano';
      final String route =
          '${ApiBaseURLService.baseUrl}/$prefixUrl/${gestaoAtivaData['idt_id']}/${auth.anoId}';

      final Uri url = Uri.parse(route);

      final http.Response response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response;
    } catch (e) {
      return http.Response('Erro ao carregar aulas: $e', 500);
    }
  }

  Future<Map<dynamic, dynamic>?> _getGestaoAtivaData() async {
    return gestaoAtivaBox.get('gestao_ativa');
  }
}
