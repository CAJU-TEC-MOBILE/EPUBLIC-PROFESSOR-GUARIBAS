import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/matricula_model.dart';

class MatriculasServiceAdapter {
  Future<void> salvar(List<dynamic> matriculas) async {
    Box<Matricula> matriculasBox = Hive.box<Matricula>('matriculas');

    await apagarTudo();

    for (var matriculaJson in matriculas) {
      Matricula matricula = Matricula.fromJson(matriculaJson);
      matriculasBox.add(matricula);
    }

    // List<Matricula> matriculasData = matriculasBox.values.toList();

    // print("-----------------TODAS AS MATRÍCULAS SALVAS---------------------");
    // print('TOTAL DE MATRÍCULAS: ${matriculasData.length}');
  }

  Future<List<Matricula>> listar() async {
    Box matriculasBox = Hive.box<Matricula>('matriculas');
    List<Matricula> matriculas = await matriculasBox.get('matriculas');
    return matriculas;
  }

  Future<void> apagarTudo() async {
    Box matriculasBox = Hive.box<Matricula>('matriculas');
    dynamic matriculasData = matriculasBox.values.toList();

    if (matriculasData != null && matriculasData.isNotEmpty) {
      await matriculasBox.clear();
    }
    // print('---------------BOX MATRÍCULAS (CLEAR)---------------');
  }
}
