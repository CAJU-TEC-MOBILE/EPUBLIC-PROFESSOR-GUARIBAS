import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:async';

import '../../../models/auth_model.dart';
import '../../controller/auth_controller.dart';

class AulasListarTodasHttp {
  Box authBox = Hive.box('auth');
  Box gestaoAtivaBox = Hive.box('gestao_ativa');

  Future<Map<dynamic, dynamic>?> _getAuthData() async {
    return authBox.get('auth');
  }

  Future<Map<dynamic, dynamic>?> _getGestaoAtivaData() async {
    return gestaoAtivaBox.get('gestao_ativa');
  }

  Future<http.Response> executar() async {
    Map<dynamic, dynamic>? authData = await _getAuthData();
    Map<dynamic, dynamic>? gestaoAtivaData = await _getGestaoAtivaData();
    final authController = AuthController();
    await authController.init();

    if (authData != null && gestaoAtivaData != null) {
      AuthModel? auth = await authController.authFirst();

      String prefixUrl = 'notifiq-professor/aulas/todas-as-aulas/gestao-ano';

      var url = Uri.parse(
        '${ApiBaseURLService.baseUrl}/$prefixUrl/${gestaoAtivaData['idt_id']}/${auth!.anoId.toString()}',
      );

      try {
        var response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer ${authData['token_atual']}',
          },
        );
        if (response.statusCode == 200) {
          print(
              'aulas-listar-todas-http-executar: ${response.statusCode.toString()}');
        }
        return response;
      } catch (e) {
        print(e);
      }
    }

    return http.Response('', 500);
  }
}
