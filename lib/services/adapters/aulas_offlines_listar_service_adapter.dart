import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/functions/filtrar_aulas_da_gestao_ativa.dart';
import 'package:professor_acesso_notifiq/models/aula_model.dart';

class AulasOfflinesListarServiceAdapter {
  List<Aula> executar() {
    Box<Aula> caixaAulas = Hive.box<Aula>('aulas_offlines');
    Box gestaoAtivaBox = Hive.box('gestao_ativa');
    Map<dynamic, dynamic>? gestao_ativa_data;
    gestao_ativa_data = gestaoAtivaBox.get('gestao_ativa');

    // !! Aulas Off-line !!
    List<Aula> aulas = caixaAulas.values
        .map((valor) => Aula(
              id: valor.id,
              instrutor_id: valor.instrutor_id,
              disciplina_id: valor.disciplina_id,
              disciplinas_formatted: valor.disciplinas_formatted,
              turma_id: valor.turma_id,
              tipoDeAula: valor.tipoDeAula,
              dataDaAula: valor.dataDaAula,
              horarioID: valor.horarioID,
              horarios_formatted: valor.horarios_formatted,
              horarios_infantis: valor.horarios_infantis,
              conteudo: valor.conteudo,
              metodologia: valor.metodologia,
              saberes_conhecimentos: valor.saberes_conhecimentos,
              dia_da_semana: valor.dia_da_semana,
              situacao: valor.situacao,
              criadaPeloCelular: valor.criadaPeloCelular,
              etapa_id: valor.etapa_id,
              instrutorDisciplinaTurma_id: valor.instrutorDisciplinaTurma_id,
              eixos: valor.eixos,
              estrategias: valor.estrategias,
              recursos: valor.recursos,
              atividade_casa: valor.atividade_casa,
              atividade_classe: valor.atividade_classe,
              observacoes: valor.observacoes,
              experiencias: valor.experiencias,
              is_polivalencia: valor.is_polivalencia,
              campos_de_experiencias: valor.campos_de_experiencias,
              e_aula_infantil: valor.e_aula_infantil,
              //horarios_extras_formatted: valor.horarios_extras_formatted,
            ))
        .toList();

    List<Aula> aulasFiltradasPorGestaoAtiva = filtrarAulasDaGestaoAtiva(
        lista_de_objetos: aulas,
        instrutorID: gestao_ativa_data?['idt_instrutor_id'].toString(),
        disciplinaID: gestao_ativa_data?['idt_disciplina_id'].toString(),
        turmaID: gestao_ativa_data?['idt_turma_id'].toString());

    return aulasFiltradasPorGestaoAtiva;
  }
}
