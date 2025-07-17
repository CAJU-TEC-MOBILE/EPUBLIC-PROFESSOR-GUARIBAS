import 'package:hive_flutter/hive_flutter.dart';
import '../../models/aula_ativa_model.dart';
import '../../models/aula_model.dart';

class AulaAtivaController {
  late Box<AulaAtivaModel> box;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(AulaAtivaAdapter().typeId)) {
      Hive.registerAdapter(AulaAtivaAdapter());
    }
    box = await Hive.openBox<AulaAtivaModel>('aulas_ativas');
  }

  Future<void> add({required AulaAtivaModel model}) async {
    await box.add(model);
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<void> selecionarAula({required Aula model}) async {
    AulaAtivaModel aula = AulaAtivaModel.selected(model);
    await box.add(aula);
  }

  Future<AulaAtivaModel> aulaAtivaPeloId(
      {required String criadaPeloCelular}) async {
    final dados = box.values
        .where((item) => item.criadaPeloCelular.toString() == criadaPeloCelular)
        .toList();
    if (dados.isEmpty) return AulaAtivaModel.vazio();
    return dados.first;
  }

  Future<AulaAtivaModel> aulaAtiva() async {
    final dados = box.values.toList();
    if (dados.isEmpty) return AulaAtivaModel.vazio();
    return dados.first;
  }
}
