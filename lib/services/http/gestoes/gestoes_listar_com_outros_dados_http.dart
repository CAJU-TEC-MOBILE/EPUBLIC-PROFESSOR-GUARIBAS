import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/services/api_base_url_service.dart';
import 'dart:async';
import '../../../models/auth_model.dart';
import '../../../models/instrutor_model.dart';
import '../../controller/Instrutor_controller.dart';
import '../../controller/auth_controller.dart';
import '../../shared_preference_service.dart';

class GestoesListarComOutrosDadosHttp {
  Future<http.Response> todasAsGestoes() async {
    final preference = SharedPreferenceService();
    final instrutorController = InstrutorController();
    final authController = AuthController();

    await preference.init();
    await authController.init();
    await instrutorController.init();

    String? token = preference.getAccessToken();

    List<Instrutor> instrutores = instrutorController.getAllInstrutores();

    if (instrutores.isEmpty) {
      return http.Response('Erro: Nenhum instrutor encontrado.', 404);
    }

    String instrutorId = instrutores.first.id.toString();

    AuthModel auth = await authController.authFirst();
    String anoId = auth.id != ''
        ? auth.anoId.toString()
        : instrutores.first.anoId.toString();

    String prefixUrl =
        'notifiq-professor/aulas/gestoes/instrutores-gestao-ano/$instrutorId/$anoId';
    final url = Uri.parse('${ApiBaseURLService.baseUrl}/$prefixUrl');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }
}
