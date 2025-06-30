import 'package:hive_flutter/hive_flutter.dart';
import '../../models/config_horario_model.dart';
import '../../data/adapters/config_horario_adapter.dart';
import '../../models/horario_model.dart';

class ConfigHorarioConfiguracao {
  late Box<ConfigHorarioModel> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(ConfigHorarioAdapter().typeId)) {
      Hive.registerAdapter(ConfigHorarioAdapter());
    }

    box = await Hive.openBox<ConfigHorarioModel>('config_horarios');
  }

  Future<void> add(ConfigHorarioModel model) async {
    await box.add(model);
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<Horario> horario({required String horarioId}) async {
    final horario = box.values.where((item) => item.id == horarioId).first;
    return Horario(
      id: horario.id,
      descricao: horario.descricao.toString(),
      turnoID: horario.turnoId.toString(),
      inicio: horario.inicio.toString(),
      fim: horario.fim.toString(),
    );
  }
}
