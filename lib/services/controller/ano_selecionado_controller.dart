import '../../models/ano_selecionado_model.dart';
import '../../models/ano_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/auth_model.dart';
import './auth_controller.dart';
import './ano_controller.dart';

class AnoSelecionadoController {
  late Box<AnoSelecionado> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(AnoSelecionadoAdapter().typeId)) {
      Hive.registerAdapter(AnoSelecionadoAdapter());
    }

    box = await Hive.openBox<AnoSelecionado>('ano_selecionado');
  }

  Future<List<AnoSelecionado>> getAll() async {
    return box.values.toList();
  }

  Future<void> setAnoSelecionado(Ano model) async {
    await clear();
    AnoSelecionado dado = AnoSelecionado(id: 1, ano: model);
    await box.add(dado);
  }

  Future<void> setAnoPorAuth({required int anoId}) async {
    await clear();

    final anoController = AnoController();

    await anoController.init();

    Ano anoUser = await anoController.getAnoId(anoId: anoId);
    await setAnoSelecionado(anoUser);
  }

  Future<Ano> getAnoSelecionado() async {
    AnoSelecionado dado = box.values.first;
    return dado.ano;
  }

  Future<Ano?> getAnoSelecionadoAno() async {
    if (box.values.isEmpty) {
      return null;
    }

    AnoSelecionado? dado = box.values.first as AnoSelecionado?;
    if (dado == null) {
      return null;
    }

    return dado.ano;
  }

  Future<void> create(AnoSelecionado model) async {
    await box.add(model);
  }

  Future<void> close() async {
    await box.close();
  }

  Future<void> clear() async {
    await box.clear();
  }
}
