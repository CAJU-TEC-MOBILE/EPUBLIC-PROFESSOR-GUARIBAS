import 'package:hive_flutter/hive_flutter.dart';

import '../../models/anexo_model.dart';

class AnexoController {
  late Box<Anexo> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(AnexoAdapter().typeId)) {
      Hive.registerAdapter(AnexoAdapter());
    }

    box = await Hive.openBox<Anexo>('anexos');
  }

  Future<List<Anexo>> getAll() async {
    return box.values.toList();
  }

  Future<void> create(Anexo model) async {
    await box.add(model);
  }

  Future<List<Anexo>> getAlunoTurma(
      {required String alunoId, required String turmaId}) async {
    List<Anexo> data = box.values
        .where((item) => item.aluno_id == alunoId && item.turma_id == turmaId)
        .toList();
    return data;
  }
}
