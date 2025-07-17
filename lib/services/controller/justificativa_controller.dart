import 'package:hive_flutter/hive_flutter.dart';
import '../../models/justificativa_model.dart';

class JustificativaController {
  late Box<Justificativa> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(JustificativaAdapter().typeId)) {
      Hive.registerAdapter(JustificativaAdapter());
    }

    box = await Hive.openBox<Justificativa>('justificativas');
  }

  Future<List<Justificativa>> all() async {
    return box.values.toList();
  }
}
