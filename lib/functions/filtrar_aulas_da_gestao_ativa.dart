import 'package:professor_acesso_notifiq/models/aula_model.dart';

List<Aula> filtrarAulasDaGestaoAtiva({
  required List<Aula> lista_de_objetos,
  required var instrutorID,
  required var disciplinaID,
  required var turmaID,
}) {
  List<Aula> listaFiltrada = lista_de_objetos
      .where((aula) => aula.instrutor_id == instrutorID)
      .where((aula) => aula.disciplina_id == disciplinaID)
      .where((aula) => aula.turma_id == turmaID)
      .toList();
  return listaFiltrada;
}
