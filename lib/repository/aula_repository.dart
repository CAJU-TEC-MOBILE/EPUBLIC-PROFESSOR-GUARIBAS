import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/models/aula_ativa_model.dart';

import '../componentes/dialogs/custom_snackbar.dart';
import '../componentes/global/preloader.dart';
import '../enums/status_console.dart';
import '../helpers/console_log.dart';
import '../models/aula_model.dart';
import '../models/serie_model.dart';
import '../services/controller/aula_ativa_controller.dart';
import '../services/controller/aula_controller.dart';
import '../services/http/aulas/aulas_offline_sincronizar_service.dart';

class AulaRepository {
  Future<void> sincronizar(
      {required BuildContext context,
      required Aula aula,
      required List<String> experiencias,
      required List<Serie> seriesSelecionadas}) async {
    try {
      showLoading(context);
      await AulasOfflineSincronizarService().executar(
        context,
        aula,
        aula.experiencias,
        aula.series ?? [],
      );
      hideLoading(context);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'auth-repository-login',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      CustomSnackBar.showErrorSnackBar(
        context,
        error.toString(),
      );
    }
  }

  Future<bool> selecionar({required Aula model}) async {
    try {
      final aulaController = AulaController();
      final controller = AulaAtivaController();

      await controller.init();
      await aulaController.init();

      await controller.clear();

      Aula? aula = await aulaController.aula(
        criadaPeloCelular: model.criadaPeloCelular,
      );

      if (aula == null) return false;

      await controller.selecionarAula(model: aula);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<AulaAtivaModel> aulaAtiva() async {
    final controller = AulaAtivaController();
    await controller.init();
    return await controller.aulaAtiva();
  }
}
