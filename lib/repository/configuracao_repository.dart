import 'dart:convert';
import 'package:professor_acesso_notifiq/models/config_horario_model.dart';

import '../enums/status_console.dart';
import '../helpers/console_log.dart';
import '../models/etapa_model.dart';
import '../services/controller/config_horario_configuracao.dart';
import '../services/controller/etapa_controller.dart';
import '../services/http/configuracao/configuracao_http.dart';

class ConfiguracaoRepository {
  final configuracaoHttp = ConfiguracaoHttp();
  final configHorarioConfiguracao = ConfigHorarioConfiguracao();
  final etapaController = EtapaController();

  Future<void> baixar() async {
    await configHorario();
  }

  Future<void> configHorario() async {
    try {
      final response = await configuracaoHttp.horarios();

      if (response.statusCode != 200) {
        ConsoleLog.mensagem(
          titulo: 'config-horario',
          mensagem: 'Falha ao buscar horários. Código: ${response.statusCode}',
          tipo: StatusConsole.error,
        );
        if (response.statusCode == 401) return;
        return;
      }

      await configHorarioConfiguracao.init();
      await configHorarioConfiguracao.clear();

      final data = json.decode(response.body);
      final dynamic horariosData = data['horarios'];

      if (horariosData is List) {
        final List<dynamic> horarios = horariosData;
        for (var item in horarios) {
          final model = ConfigHorarioModel.fromJson(item);
          await configHorarioConfiguracao.add(model);
        }
      }
    } catch (error, stackTrace) {
      ConsoleLog.mensagem(
        titulo: 'config-horario',
        mensagem: 'Erro: $error\nStackTrace: $stackTrace',
        tipo: StatusConsole.error,
      );
    }
  }

  Future<void> configEtapa() async {
    try {
      final response = await configuracaoHttp.etapas();

      if (response.statusCode != 200) {
        ConsoleLog.mensagem(
          titulo: 'config-etapa',
          mensagem: 'Falha ao buscar etapas. código: ${response.statusCode}',
          tipo: StatusConsole.error,
        );
        if (response.statusCode == 401) return;
        return;
      }

      await etapaController.init();
      await etapaController.clear();

      final data = json.decode(response.body);

      if (data['etapas'] is List) {
        for (var item in data['etapas']) {
          final model = Etapa.fromJson(item);
          await etapaController.add(model);
        }
      }
    } catch (error, stackTrace) {
      ConsoleLog.mensagem(
        titulo: 'config-horario',
        mensagem: 'Erro: $error\nStackTrace: $stackTrace',
        tipo: StatusConsole.error,
      );
    }
  }
}
