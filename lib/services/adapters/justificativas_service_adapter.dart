import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/justificativa_model.dart';

class JustificativasServiceAdapter {
  Future<void> salvar(List<dynamic> justificativas) async {
    Box<Justificativa> box = Hive.box<Justificativa>('Justificativas');

    await apagarTudo();

    for (var justificativaJson in justificativas) {
      Justificativa justificativa = Justificativa.fromJson(justificativaJson);
      box.add(justificativa);
    }

    List<Justificativa> data = box.values.toList();
    print('------------TODAS AS JUSTIFICATIVAS SALVAS-----------');
    print('TOTAL DE JUSTIFICATIVAS: ${data.length}');
  }

  Future<List<Justificativa>> listar() async {
    Box<Justificativa> box = Hive.box<Justificativa>('justificativas');
    List<Justificativa> data = box.values.toList().cast<Justificativa>();

    return data;
  }

  Future<void> apagarTudo() async {
    Box<Justificativa> box = Hive.box<Justificativa>('justificativas');
    dynamic data = box.values.toList();

    if (data != null && data.isNotEmpty) {
      await box.clear();
    }
  }
}
