import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/constants/autorizacoes/autorizacoes_status_const.dart';
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import '../../../models/autorizacao_model.dart';
import '../../shared_preference_service.dart';

class AutorizacaoHttp {
  Future<http.Response> executar({required AutorizacaoModel model}) async {
    final preference = SharedPreferenceService();

    String prefixUrl = 'notifiq-professor/autorizacoes/criar-autorizacao';

    await preference.init();

    final String url = '${ApiBaseURLService.baseUrl}/$prefixUrl';

    String? token = await preference.getToken();

    Map<String, dynamic> data = {
      'pedido_id': model.pedidoId,
      'instrutorDisciplinaTurma_id':
          model.instrutorDisciplinaTurmaId.toString(),
      'etapa_id': model.etapaId,
      'user_solicitante': model.userAprovador,
      'user_aprovador': model.userAprovador,
      'status': AutorizacoesStatusConst.pendente,
      'observacoes': model.observacoes.isEmpty ? null : model.observacoes,
      'data': model.data,
      'mobile': model.mobile,
      'user_id': model.userId
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> autorizacoesUser({required String userId}) async {
    final preference = SharedPreferenceService();

    String prefixUrl = 'notifiq-professor/autorizacoes/user/$userId';

    await preference.init();

    final String url = '${ApiBaseURLService.baseUrl}/$prefixUrl';

    String? token = await preference.getToken();

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }
}
