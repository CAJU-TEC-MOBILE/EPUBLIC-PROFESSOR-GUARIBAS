import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/models/auth_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/auth_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:async';

class AutorizacoesListarHttp {
  Auth authModel = AuthServiceAdapter().exibirAuth();

  Future<http.Response> executar() async {
    String prefix_url =
        'notifiq-professor/autorizacoes/listar_autorizacoes_do_usuario';
    var url = Uri.parse(
      '${ApiBaseURLService.baseUrl}/${prefix_url}',
    );

    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${authModel.tokenAtual}',
        },
      );
      return response;
    } catch (e) {
      return http.Response('', 500);
    }
  }
}
