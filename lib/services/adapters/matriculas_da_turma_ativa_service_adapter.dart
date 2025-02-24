import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/matricula_model.dart';

class MatriculasDaTurmaAtivaServiceAdapter {
  Future<void> salvar() async {
    Box<Matricula> matriculasDaturmaAtivaBox =
        Hive.box<Matricula>('matriculas_da_turma_ativa');
    Box<Matricula> matriculasBox = Hive.box<Matricula>('matriculas');
    // ignore: no_leading_underscores_for_local_identifiers
    Box _gestaoAtivaBox = Hive.box('gestao_ativa');

    dynamic gestaoAtivaData = _gestaoAtivaBox.get('gestao_ativa');
    List<Matricula> matriculasData = matriculasBox.values.toList();

    List<Matricula> matriculasFiltro = matriculasData
        .where((matricula) =>
            matricula.turma_id.toString() ==
            gestaoAtivaData['idt_turma_id'].toString())
        .toList();

    await apagarTudo();

    matriculasDaturmaAtivaBox.addAll(matriculasFiltro);

    //print("-----------------TODAS AS MATRÍCULAS DA TURMA ATIVA SALVAS----------------------");
    /*print('TOTAL DE MATRICULAS DA TURMA ATIVA: ' +
        _matriculasDaturmaAtivaBox.values.length.toString());*/
  }

  Future<List<Matricula>> listar() async {
    Box<Matricula> matriculasDaturmaAtivaBox =
        Hive.box<Matricula>('matriculas_da_turma_ativa');
    List<Matricula> matriculasDaturmaAtivaData =
        matriculasDaturmaAtivaBox.values.toList().cast<Matricula>();
    //print(_matriculasDaturmaAtivaData);

    return matriculasDaturmaAtivaData;
  }

  Future<void> apagarTudo() async {
    Box<Matricula> matriculasDaturmaAtivaBox =
        Hive.box<Matricula>('matriculas_da_turma_ativa');
    dynamic matriculasDaturmaAtivaData =
        matriculasDaturmaAtivaBox.values.toList();

    if (matriculasDaturmaAtivaData != null &&
        matriculasDaturmaAtivaData.isNotEmpty) {
      await matriculasDaturmaAtivaBox.clear();
      //print('BOX MATRÍCULAS DA TURMA ATIVA (CLEAR)');
    }
  }
}
