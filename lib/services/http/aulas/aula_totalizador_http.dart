import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/models/ano_model.dart';
import '../../api_base_url_service.dart';
import '../../controller/Instrutor_controller.dart';
import '../../controller/ano_selecionado_controller.dart';
import '../../shared_preference_service.dart';

class AulaTotalizadorHttp {
  Future<http.Response> getAulasTotalizadas({required String id}) async {
    final anoSelecionadoController = AnoSelecionadoController();
    final preference = SharedPreferenceService();
    await preference.init();
    await anoSelecionadoController.init();

    String? token = await preference.getToken();
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
      headers: {'Authorization': 'Bearer $token'},
    );

    return response;
  }
}
