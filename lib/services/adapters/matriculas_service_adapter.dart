import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/matricula_model.dart';

class MatriculasServiceAdapter {
  Future<void> salvar(List<dynamic> matriculas) async {
    Box<Matricula> _matriculasBox = Hive.box<Matricula>('matriculas');

    await apagarTudo();

    matriculas.forEach((matriculaJson) {
      Matricula matricula = Matricula.fromJson(matriculaJson);
      _matriculasBox.add(matricula);
    });

    List<Matricula> matriculasData = _matriculasBox.values.toList();

    print("-----------------TODAS AS MATRÍCULAS SALVAS---------------------");
    print('TOTAL DE MATRÍCULAS: ' + matriculasData.length.toString());
  }

  Future<List<Matricula>> listar() async {
    Box _matriculasBox = Hive.box<Matricula>('matriculas');
    List<Matricula> matriculas = await _matriculasBox.get('matriculas');
    return matriculas;
  }

  Future<void> apagarTudo() async {
    Box _matriculasBox = Hive.box<Matricula>('matriculas');
    dynamic _matriculasData = _matriculasBox.values.toList();

    if (_matriculasData != null && _matriculasData.isNotEmpty) {
      await _matriculasBox.clear();
    }
    print('---------------BOX MATRÍCULAS (CLEAR)---------------');
  }
}
