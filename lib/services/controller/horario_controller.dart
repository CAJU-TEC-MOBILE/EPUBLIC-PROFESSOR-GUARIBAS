import '../../models/horario_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HorarioController {
  late Box _horarioBox; // Remover o tipo específico Box<Horario>

  Future<void> init() async {
    await Hive.initFlutter();

    _horarioBox = await Hive.openBox('horarios');
  }

  Future<List<dynamic>> getAllHorario() async {
    List<dynamic> data = [];
    Set<int> seenIds = {};

    final horarios = _horarioBox.values.toList();

    for (var item in horarios) {
      if (item is List) {
        for (var obj in item) {
          if (obj is Map && obj.containsKey('id')) {
            if (!seenIds.contains(obj['id'])) {
              seenIds.add(obj['id']);
              data.add(obj);
            }
          }
        }
      } else {
        if (item is Map && item.containsKey('id')) {
          if (!seenIds.contains(item['id'])) {
            seenIds.add(item['id']);
            data.add(item);
          }
        }
      }
    }

    return data;
  }

  Future<String> getDescricaoHorario(int id) async {
    await init();
    final horarios = _horarioBox.values.toList();

    if (horarios.isEmpty) {
      return 'Nenhum horário disponível.';
    }

    final horario = horarios[0].firstWhere(
      (h) => h['id'].toString() == id.toString(),
      orElse: () => null,
    );

    if (horario != null) {
      return horario['descricao'].toString();
    } else {
      return 'Horário com ID $id não encontrado.';
    }
  }
}
