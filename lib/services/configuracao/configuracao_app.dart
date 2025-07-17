import 'dart:convert';
import 'package:professor_acesso_notifiq/help/console_log.dart';

import '../controller/ano_controller.dart';
import '../http/configuracao/ano_http.dart';
import '../../models/ano_model.dart';

class ConfiguracaoApp {
  Future<void> anos() async {
    try {
      AnoHttp anoHttp = AnoHttp();
      final response = await anoHttp.getAll();

      if (response.statusCode != 200) {
        return;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> anosData = data['anos'];

      List<Ano> anosList = anosData.map((item) => Ano.fromJson(item)).toList();

      AnoController anoController = AnoController();

      await anoController.init();

      await anoController.clear();

      for (var model in anosList) {
        await anoController.create(model);
      }
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'configuracao-app-anos',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
  }

  Future<void> horarios() async {
    try {
      AnoHttp anoHttp = AnoHttp();
      final response = await anoHttp.getAll();

      if (response.statusCode != 200) {
        return;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> anosData = data['anos'];

      List<Ano> anosList = anosData.map((item) => Ano.fromJson(item)).toList();

      AnoController anoController = AnoController();

      await anoController.init();

      await anoController.clear();

      for (var model in anosList) {
        await anoController.create(model);
      }
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'configuracao-app-anos',
        mensagem: e.toString(),
        tipo: 'erro',
      );
    }
  }
}
