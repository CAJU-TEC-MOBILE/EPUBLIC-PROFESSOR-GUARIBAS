import 'package:hive_flutter/hive_flutter.dart';
import '../../enums/status_console.dart';
import '../../helpers/console_log.dart';
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

  Future<void> add(AulaTotalizador aulaTotalizador) async {
    await box.add(aulaTotalizador);
  }

  Future<void> clear() async {
    box = await Hive.openBox<AulaTotalizador>('aula_totalizadores');
    await box.clear();
  }

  Future<AulaTotalizador> totalizador() async {
    try {
      if (box.isEmpty) {
        return AulaTotalizador.vazio();
      }
      AulaTotalizador totalizador = box.values.first;
      return totalizador;
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'totalizador',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return AulaTotalizador.vazio();
    }
  }

  Future<void> visualizar() async {
    List<AulaTotalizador> data = box.values.toList();
    print("total: ${data.length.toString()}");
    data.forEach((item) {
      print(item);
    });
  }
}
