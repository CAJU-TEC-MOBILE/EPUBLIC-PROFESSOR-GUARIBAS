import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:async';

import '../../../models/auth_model.dart';
import '../../../models/instrutor_model.dart';
import '../../controller/Instrutor_controller.dart';
import '../../controller/auth_controller.dart';
import '../../controller/gestoes_controller.dart';

class GestoesListarComOutrosDadosHttp {
  Box authBox = Hive.box('auth');

  Future<Map<dynamic, dynamic>?> _getAuthData() async {
    return authBox.get('auth');
  }

  Future<http.Response> todasAsGestoes() async {
    print('===== Todas as gestoes ====');

    final InstrutorController instrutorController = InstrutorController();
    final authController = AuthController();

    await instrutorController.init();

    Map<dynamic, dynamic>? authData = await _getAuthData();

    List<Instrutor> instrutores = instrutorController.getAllInstrutores();

    if (instrutores.isEmpty) {
      print('Erro: Nenhum instrutor encontrado.');
      return http.Response('Erro: Nenhum instrutor encontrado.', 404);
    }

    String instrutorId = instrutores[0].id.toString();
    String instrutorToken = instrutores[0].token.toString();

    String tokenAutorizacao = authData?['token_atual'] ?? instrutorToken;

    await authController.init();
    Auth? auth = await authController.getAuth();
    String anoId =
        auth != null ? auth.anoId.toString() : instrutores[0].anoId.toString();

    //String prefixUrl = 'notifiq-professor/aulas/gestoes/instrutores-gestao/$instrutorId';
    String prefixUrl =
        'notifiq-professor/aulas/gestoes/instrutores-gestao-ano/$instrutorId/$anoId';
    var url = Uri.parse('${ApiBaseURLService.baseUrl}/$prefixUrl');

    print('url $url');
    //final tempoDeDuracaoEmSegundos =  Duration(seconds: ApiBaseURLService.tempoDeDuracaoEmSegundos);

    try {
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $tokenAutorizacao',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final gestaoCotnroller = GestaoCotnroller();
        await gestaoCotnroller.init();
        await gestaoCotnroller.clear();
        //print('todasAsGestoes: ${response.body}');
        var jsonResponse = json.decode(utf8.decode(response.bodyBytes));

        List<dynamic> gestoes = jsonResponse['gestoes'];

        if (gestoes.isEmpty) {
          print('Nenhuma gestão encontrada para o instrutor.');
          return http.Response('Nenhuma gestão encontrada.', 204);
        }
        for (var gestaoGroup in gestoes) {
          for (var gestao in gestaoGroup) {
            print('ID da Gestão: ${gestao['idt_id']}');
            print('is_infantil: ${gestao['is_infantil']}');
            print('ID do Instrutor: ${gestao['idt_instrutor_id']}');
            print('Nome do Instrutor: ${gestao['instrutor_nome']}');
            print('POLIVALÊNCIA: ${gestao['is_polivalencia']}');
            print('Descrição da Disciplina: ${gestao['disciplina_descricao']}');
            print('Descrição da Turma: ${gestao['turma_descricao']}');
            print('Turno: ${gestao['turno_descricao']}');
            print('Curso: ${gestao['curso_descricao']}');
            print('Horários:');

            for (var relacao in gestao['relacoesDiasHorarios']) {
              print('  - Dia: ${relacao['dia']['descricao']}');
              print('  - Horário: ${relacao['horario']['descricao']} '
                  '(${relacao['horario']['inicio']} - ${relacao['horario']['final']})');
            }
            print('---');
          }
        }

        return response;
      } else {
        print(
            'Erro: Falha na requisição. Código de status: ${response.statusCode}');
        return http.Response(
            'Erro: Não foi possível buscar as gestões.', response.statusCode);
      }
    } catch (e) {
      print('Erro ao buscar gestões: $e');
      return http.Response('Erro ao buscar gestões: $e', 500);
    } finally {
      print('===== FIM ====');
    }
  }
}
