import 'package:hive_flutter/hive_flutter.dart';
import '../../help/console_log.dart';
import '../../models/horario_aula_model.dart';

class HorarioConfiguracaoController {
  late Box<HorarioConfiguracao> _horarioConfiguracaoBox;
  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(HorarioConfiguracaoAdapter().typeId)) {
      Hive.registerAdapter(HorarioConfiguracaoAdapter());
    }
    _horarioConfiguracaoBox =
        await Hive.openBox<HorarioConfiguracao>('horario_configuracao');
  }

  Future<List<HorarioConfiguracao>> getAll() async {
    return _horarioConfiguracaoBox.values.toList();
  }

  Future<List<HorarioConfiguracao>> getPeloTurnoId(
      {required String turnoID}) async {
    try {
      return _horarioConfiguracaoBox.values
          .where((item) => item.turnoID == turnoID)
          .toList();
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'get-tipo',
        mensagem: e.toString(),
        tipo: 'erro',
      );
      return [];
    }
  }

  Future<List<HorarioConfiguracao>> getTipo(
      {required String tipoHorario}) async {
    try {
      return _horarioConfiguracaoBox.values
          .where(
              (item) => item.tipo_horario!.toString() == tipoHorario.toString())
          .toList();
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'get-tipo',
        mensagem: e.toString(),
        tipo: 'erro',
      );
      return [];
    }
  }

  Future<void> addHorarioConfiguracoes(List<dynamic> horarios) async {
    try {
      if (horarios.isEmpty) {
        print('Sem horários de configuração');
        return;
      }
      for (var horario in horarios) {
        var dado = HorarioConfiguracao(
          id: horario['id'].toString(),
          descricao: horario['descricao'].toString(),
          turnoID: horario['turno_id'].toString(),
          fim: horario['final'].toString(),
          inicio: horario['inicio'].toString(),
          tipo_horario: horario['tipo_horario'].toString(),
        );
        await _horarioConfiguracaoBox.add(dado);
      }
    } catch (e, stackTrace) {
      ConsoleLog.mensagem(
        titulo: 'add-horario-configuracoes',
        mensagem: 'Error while adding HorarioConfiguracoes: $e',
        tipo: 'erro',
      );
      ConsoleLog.mensagem(
        titulo: 'add-horario-configuracoes',
        mensagem: stackTrace.toString(),
        tipo: 'erro',
      );
    }
  }

  Future<void> deleteHorarioConfiguracao(int key) async {
    await _horarioConfiguracaoBox.delete(key);
  }

  Future<int> clear() async {
    return await _horarioConfiguracaoBox.clear();
  }

  Future<String> getDescricaoPeloId({required String horarioId}) async {
    final dado = _horarioConfiguracaoBox.values.firstWhere(
      (element) => element.id == horarioId,
      orElse: () => HorarioConfiguracao(
        id: '',
        turnoID: '',
        descricao: 'sem horário.',
        inicio: '',
        fim: '',
        tipo_horario: '',
      ),
    );
    return dado.descricao;
  }

  Future<String> getDescricaoHorario(String horarioId) async {
    await init();
    final horarios = _horarioConfiguracaoBox.values.toList();
    if (horarios.isEmpty) {
      return 'Nenhum horário disponível.';
    }
    final horarioEncontrado = horarios.firstWhere(
      (item) => item.id == horarioId,
      orElse: () => HorarioConfiguracao.vazio(),
    );
    return horarioEncontrado.descricao.toString();
  }
}
