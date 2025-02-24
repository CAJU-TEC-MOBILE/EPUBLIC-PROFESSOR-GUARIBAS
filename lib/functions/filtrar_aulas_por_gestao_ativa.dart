import 'package:professor_acesso_notifiq/models/aula_model.dart';

Future<List<Aula>> filtrarAulasPorGestaoAtiva({
  required List<Aula> lista_de_objetos,
  required var instrutorID,
  required var disciplinaID,
  required var turmaID,
}) async {
  List<Aula> listaFiltrada = await lista_de_objetos
      .where((aula) => aula.instrutor_id == instrutorID)
      .where((aula) => aula.disciplina_id == disciplinaID)
      .where((aula) => aula.turma_id == turmaID)
      .toList();
  return listaFiltrada;
}


Future<List<Aula>> filtrarAulasPorGestaoAtivaInstrutorDisciplinaTurmaId({
  required List<Aula> lista_de_objetos,
  required var instrutorID,
  required var instrutorDisciplinaTurmaId,
  required var turmaID,
}) async {
  List<Aula> listaFiltrada = await lista_de_objetos
      .where((aula) => aula.instrutor_id == instrutorID)
      .where((aula) => aula.instrutorDisciplinaTurma_id == instrutorDisciplinaTurmaId)
      .where((aula) => aula.turma_id == turmaID)
      .toList();
  return listaFiltrada;
}