import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/ano_model.dart';
import '../../../models/instrutor_model.dart';
import '../../api_base_url_service.dart';
import '../../controller/Instrutor_controller.dart';
import '../../controller/ano_selecionado_controller.dart';
import '../../controller/auth_controller.dart';

class AulaTotalizadorHttp {
  final Box authBox = Hive.box('auth');
  final Box gestaoAtivaBox = Hive.box('gestao_ativa');

  Future<Map<dynamic, dynamic>?> _getAuthData() async {
    return await authBox.get('auth');
  }

  Future<Map<dynamic, dynamic>?> _getGestaoAtivaData() async {
    print('Verificando dados de gestão ativa...');
    return await gestaoAtivaBox.get('gestao_ativa');
  }

  Future<http.Response> getAulasTotalizadas({required String id}) async {
    try {
      final authData = await _getAuthData();
      if (authData == null) {
        print('Erro: Dados de autenticação ou gestão ativa ausentes');
        return http.Response('Erro: Dados ausentes', 500);
      }

      final anoSelecionadoController = AnoSelecionadoController();
      await anoSelecionadoController.init();
      Ano? ano = await anoSelecionadoController.getAnoSelecionadoAno();

      if (ano == null) {
        final instrutorController = InstrutorController();
        await instrutorController.init();
        final instrutor = await instrutorController.getFirst();
        ano = Ano(
          id: int.parse(instrutor.anoId),
          descricao: 'Ano padrão',
          situacao: '1',
        );
      }

      final anoId = ano.id.toString();

      final baseUrl = ApiBaseURLService.baseUrl.toString();
      final url = Uri.parse(
          '$baseUrl/notifiq-professor/aulas/totalizador-ano/$id/$anoId');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${authData['token_atual']}'},
      );

      if (response.statusCode == 200) {
        print('Requisição bem-sucedida: ${response.statusCode}');
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }

      return response;
    } on http.ClientException catch (e) {
      print('Erro do cliente HTTP: $e');
      return http.Response('Erro do cliente', 400);
    } on FormatException catch (e) {
      print('Erro de formato na resposta: $e');
      return http.Response('Erro de formato', 500);
    } catch (e) {
      print('Erro inesperado: $e');
      return http.Response('Erro inesperado', 500);
    }
  }
}
