import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:async';

import '../../../models/ano_model.dart';
import '../../../models/gestao_disciplina_model.dart';
import '../../../models/instrutor_model.dart';
import '../../controller/Instrutor_controller.dart';
import '../../controller/ano_selecionado_controller.dart';
import '../../controller/gestao_disciplina_controller.dart';
import '../../shared_preference_service.dart';

class GestaoDisciplinaHttp {
  final preference = SharedPreferenceService();

  Future<http.Response> getGestaoDisciplinas() async {
    final instrutorController = InstrutorController();
    final gestaoDisciplinaController = GestaoDisciplinaController();
    final anoSelecionadoController = AnoSelecionadoController();

    await Future.wait([
      instrutorController.init(),
      gestaoDisciplinaController.init(),
      anoSelecionadoController.init(),
      preference.init()
    ]);
    String? token = await preference.getToken();
    List<Instrutor> instrutores = instrutorController.getAllInstrutores();

    if (instrutores.isEmpty) {
      return http.Response('Erro: Nenhum instrutor encontrado.', 404);
    }

    final instrutor = instrutores[0];
    final instrutorId = instrutor.id.toString();
    final instrutorToken = instrutor.token.toString();
    final anoId = int.parse(instrutor.anoId);
    final tokenAutorizacao = token ?? instrutorToken;

    Ano? ano = await anoSelecionadoController.getAnoSelecionadoAno();
    ano ??= Ano(id: anoId, descricao: 'Ano selecionado', situacao: '1');

    final url = Uri.parse(
        '${ApiBaseURLService.baseUrl}/notifiq-professor/aulas/gestoes/instrutores-disciplinas-gestao-ano/$instrutorId/${ano.id}');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $tokenAutorizacao'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> data = jsonResponse['data'];

        if (data.isEmpty) {
          return http.Response('Nenhuma gestão encontrada.', 204);
        }

        await gestaoDisciplinaController.clear();

        for (var item in data) {
          final gestao = GestaoDisciplina(
            id: item['gestao_id'].toString(),
            descricao: item['configuracao_descricao'].toString(),
            disciplinas: item['disciplinas'],
          );
          gestaoDisciplinaController.addGetaoDisciplina(gestao);
        }
        return response;
      } else {
        return http.Response(
            'Erro: Não foi possível buscar as gestões.', response.statusCode);
      }
    } catch (e) {
      print('Erro ao buscar gestões: $e');
      return http.Response('Erro ao buscar gestões: $e', 500);
    }
  }
}
