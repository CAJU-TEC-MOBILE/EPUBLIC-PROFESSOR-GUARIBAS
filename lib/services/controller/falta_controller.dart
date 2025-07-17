import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/faltas_model.dart';

class FaltaController {
  late Box<Falta> box;
  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(FaltaAdapter().typeId)) {
      Hive.registerAdapter(FaltaAdapter());
    }
    box = await Hive.openBox<Falta>('faltas');
  }

  Future<List<Falta>> all() async {
    return box.values.toList();
  }

  Future<void> deletaFaltPeloAulaId({required String? aulaId}) async {
    for (int i = 0; i < box.length; i++) {
      Falta falta = box.getAt(i)!;
      if (falta.aula_id == aulaId) {
        await box.deleteAt(i);
        i--;
      }
    }
  }
}
