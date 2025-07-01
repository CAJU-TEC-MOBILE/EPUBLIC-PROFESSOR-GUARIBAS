import 'package:hive_flutter/hive_flutter.dart';
import '../../data/adapters/avaliador_adapter.dart';
import '../../enums/status_console.dart';
import '../../helpers/console_log.dart';
import '../../models/avaliador_model.dart';

class AvaliadorController {
  late Box<AvaliadorModel> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(AvaliadorAdapter().typeId)) {
      Hive.registerAdapter(AvaliadorAdapter());
    }

    box = await Hive.openBox<AvaliadorModel>('avaliadores');
  }

  Future<void> add(AvaliadorModel model) async {
    try {
      await box.add(model);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'avaliado-add-controller',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<List<AvaliadorModel>> all() async {
    List<AvaliadorModel> avaliadores = box.values.toList();
    avaliadores.sort((a, b) => a.name.toString().compareTo(b.name.toString()));
    return avaliadores;
  }

  Future<List<AvaliadorModel>> avaliadorPorConfiguracao({
    required String configuracaoId,
  }) async {
    List<AvaliadorModel> avaliadores = box.values
        .where(
          (item) =>
              item.configuracaoId == configuracaoId ||
              item.franquiasPermitidas!.any(
                (id) => id.toString() == configuracaoId,
              ),
        )
        .toList();

    avaliadores.sort((a, b) => a.name!.compareTo(b.name!));
    return avaliadores;
  }

  Future<void> visualizar() async {
    List<AvaliadorModel> avaliadores = box.values.toList();
    print("total: ${avaliadores.length.toString()}");
    avaliadores.forEach((item) {
      print("=======================");
      print("id: ${item.id.toString()}");
      print("descricao: ${item.name.toString()}");
    });
  }
}
