import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/horario_aula_model.dart';

class HorarioConfiguracaoController {
  late Box<HorarioConfiguracao> _horarioConfiguracaoBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(HorarioConfiguracaoAdapter().typeId)) {
      Hive.registerAdapter(HorarioConfiguracaoAdapter());
    }
    _horarioConfiguracaoBox = await Hive.openBox<HorarioConfiguracao>('horario_configuracao');
  }

  Future<List<HorarioConfiguracao>> getAll() async {
    return _horarioConfiguracaoBox.values.toList();
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
          fim: horario['final'].toString(),  // Ensure this matches your class definition
          inicio: horario['inicio'].toString(),
        );
        await _horarioConfiguracaoBox.add(dado);
      }
    } catch (e, stackTrace) {
      print('Error while adding HorarioConfiguracoes: $e');
      print('StackTrace: $stackTrace');
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
      ),
    );

    return dado.descricao;
  }


   
}
