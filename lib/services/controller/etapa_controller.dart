import 'package:hive_flutter/hive_flutter.dart';
import '../../data/adapters/etapa_adapter.dart';
import '../../models/etapa_model.dart';

class EtapaController {
  late Box<Etapa> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(EtapaAdapter().typeId)) {
      Hive.registerAdapter(EtapaAdapter());
    }

    box = await Hive.openBox<Etapa>('etapas');
  }

  Future<void> add(Etapa model) async {
    await box.add(model);
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<List<Etapa>> all() async {
    return box.values.toList();
  }

  Future<List<Etapa>> etapasPeloCircuitoId({required String circuitoId}) async {
    List<Etapa> etapas = box.values
        .where(
          (item) => item.circuito_nota_id == circuitoId,
        )
        .toList();

    return etapas;
  }

  Future<void> visualizar() async {
    List<Etapa> etapas = box.values.toList();
    print("total: ${etapas.length.toString()}");
    etapas.forEach((item) {
      print("=======================");
      print("id: ${item.id.toString()}");
      print("circuito_nota_id: ${item.circuito_nota_id.toString()}");
      print("curso_descricao: ${item.curso_descricao.toString()}");
      print("descricao: ${item.descricao.toString()}");
      print("periodo_final: ${item.periodo_final.toString()}");
      print("periodo_final: ${item.periodo_final.toString()}");
      print("etapa_global: ${item.etapa_global.toString()}");
    });
  }
}
