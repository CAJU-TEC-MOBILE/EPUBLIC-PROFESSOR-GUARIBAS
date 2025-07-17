import 'package:hive_flutter/hive_flutter.dart';
import '../../models/matricula_model.dart';

class MatriculaTurmaAtivaController {
  late Box<Matricula> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(MatriculaAdapter().typeId)) {
      Hive.registerAdapter(MatriculaAdapter());
    }

    box = await Hive.openBox<Matricula>('matriculas_da_turma_ativa');
  }

  Future<List<Matricula>> all() async {
    return box.values.toList();
  }

  Future<void> updateAl(int index, Matricula model) async {
    await box.putAt(index, model);
  }
}
