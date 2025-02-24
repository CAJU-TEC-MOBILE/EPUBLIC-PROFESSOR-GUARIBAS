import 'package:hive_flutter/hive_flutter.dart';
import '../../models/aula_totalizador_model.dart';

class AulaTotalizadorController {
  late Box<AulaTotalizador> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(AulaTotalizadorAdapter().typeId)) {
      Hive.registerAdapter(AulaTotalizadorAdapter());
    }

    box = await Hive.openBox<AulaTotalizador>('aula_totalizadores');
  }

  Future<void> addAula(AulaTotalizador aulaTotalizador) async {
    await box.add(aulaTotalizador);
  }

  Future<void> clearAll() async {
    box = await Hive.openBox<AulaTotalizador>('aula_totalizadores');
    await box.clear();
  }

  Future<AulaTotalizador?> getAulaTotalizador() async {
     if (box.isNotEmpty) {
      return box.getAt(0);  
    }
    return null; 
  }
}
