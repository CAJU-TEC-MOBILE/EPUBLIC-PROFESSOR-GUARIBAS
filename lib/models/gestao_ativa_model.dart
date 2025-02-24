import 'dart:ffi';

import 'package:professor_acesso_notifiq/models/circuito_model.dart';
import 'package:professor_acesso_notifiq/models/relacao_dia_horario_model.dart';

class GestaoAtiva {
  final String idt_id;
  final String idt_instrutor_id;
  final String idt_turma_id;
  final String idt_disciplina_id;
  final String instrutor_nome;
  final String disciplina_descricao;
  final String turma_descricao;
  final String turma_sistema_bncc_id;
  final String curso_id;
  final String curso_descricao;
  final String turno_id;
  final String turno_descricao;
  final String configuracao_id;
  final String configuracao_descricao;
  final String ano_descricao;
  final String circuito_nota_id;
  final int? is_polivalencia;
  final List<RelacaoDiaHorario> relacoesDiasHorarios;
  final Circuito circuito;
  final String? instrutorDisciplinaTurma_id;
  late final bool is_infantil;
  final int multi_etapa;

  GestaoAtiva({
    required this.idt_id,
    required this.idt_instrutor_id,
    required this.idt_turma_id,
    required this.idt_disciplina_id,
    required this.instrutor_nome,
    required this.disciplina_descricao,
    required this.turma_descricao,
    required this.turma_sistema_bncc_id,
    required this.curso_id,
    required this.curso_descricao,
    required this.turno_id,
    required this.turno_descricao,
    required this.configuracao_id,
    required this.configuracao_descricao,
    required this.ano_descricao,
    required this.circuito_nota_id,
    required this.relacoesDiasHorarios,
    required this.circuito,
    this.is_polivalencia,
    this.instrutorDisciplinaTurma_id,
    required this.is_infantil,
    required this.multi_etapa,
  });
  Future<List<RelacaoDiaHorario>> getRelacoesDiasHorarios() async {
    final List<RelacaoDiaHorario> relacoesProcessadas = [];

    for (var relacao in relacoesDiasHorarios) {
      relacoesProcessadas.add(relacao);
    }

    return relacoesProcessadas;
  }

  Future<List<String>> getRelacoesDia() async {
    final List<String> descricoes = [];

    for (var relacao in relacoesDiasHorarios) {
      descricoes.add(relacao.dia.descricao);
    }

    return descricoes;
  }

  factory GestaoAtiva.fromJson(Map<dynamic, dynamic> gestaoJson) {
    final relacoesDiasHorariosJson =
        gestaoJson['relacoesDiasHorarios'] as List<dynamic>? ?? [];
    final relacoesDiasHorarios = relacoesDiasHorariosJson
        .map((relacaoDiaHorario) =>
            RelacaoDiaHorario.fromJson(relacaoDiaHorario))
        .toList();

    return GestaoAtiva(
      idt_id: gestaoJson['idt_id']?.toString() ?? '',
      idt_instrutor_id: gestaoJson['idt_instrutor_id']?.toString() ?? '',
      idt_turma_id: gestaoJson['idt_turma_id']?.toString() ?? '',
      idt_disciplina_id: gestaoJson['idt_disciplina_id']?.toString() ?? '',
      instrutor_nome: gestaoJson['instrutor_nome']?.toString() ?? '',
      disciplina_descricao:
          gestaoJson['disciplina_descricao']?.toString() ?? '',
      turma_descricao: gestaoJson['turma_descricao']?.toString() ?? '',
      turma_sistema_bncc_id:
          gestaoJson['turma_sistema_bncc_id']?.toString() ?? '',
      curso_id: gestaoJson['curso_id']?.toString() ?? '',
      curso_descricao: gestaoJson['curso_descricao']?.toString() ?? '',
      turno_id: gestaoJson['turno_id']?.toString() ?? '',
      turno_descricao: gestaoJson['turno_descricao']?.toString() ?? '',
      configuracao_id: gestaoJson['configuracao_id']?.toString() ?? '',
      configuracao_descricao:
          gestaoJson['configuracao_descricao']?.toString() ?? '',
      ano_descricao: gestaoJson['ano_descricao']?.toString() ?? '',
      circuito_nota_id: gestaoJson['circuito_nota_id']?.toString() ?? '',
      relacoesDiasHorarios: relacoesDiasHorarios,
      instrutorDisciplinaTurma_id:
          gestaoJson['instrutorDisciplinaTurma_id']?.toString(),
      is_polivalencia: gestaoJson['is_polivalencia']!,
      circuito: Circuito.fromJson(gestaoJson['circuito'] ?? {}),
      is_infantil: gestaoJson['is_infantil'],
      multi_etapa: gestaoJson['multi_etapa'] ?? 0,
    );
  }

  factory GestaoAtiva.fromMap(Map<dynamic, dynamic> gestaoJson) {
    final relacoesDiasHorariosJson =
        gestaoJson['relacoesDiasHorarios'] as List<dynamic>? ?? [];
    final relacoesDiasHorarios = relacoesDiasHorariosJson
        .map((relacaoDiaHorario) =>
            RelacaoDiaHorario.fromJson(relacaoDiaHorario))
        .toList();

    return GestaoAtiva(
      idt_id: gestaoJson['idt_id']?.toString() ?? '',
      idt_instrutor_id: gestaoJson['idt_instrutor_id']?.toString() ?? '',
      idt_turma_id: gestaoJson['idt_turma_id']?.toString() ?? '',
      idt_disciplina_id: gestaoJson['idt_disciplina_id']?.toString() ?? '',
      instrutor_nome: gestaoJson['instrutor_nome']?.toString() ?? '',
      disciplina_descricao:
          gestaoJson['disciplina_descricao']?.toString() ?? '',
      turma_descricao: gestaoJson['turma_descricao']?.toString() ?? '',
      turma_sistema_bncc_id:
          gestaoJson['turma_sistema_bncc_id']?.toString() ?? '',
      curso_id: gestaoJson['curso_id']?.toString() ?? '',
      curso_descricao: gestaoJson['curso_descricao']?.toString() ?? '',
      turno_id: gestaoJson['turno_id']?.toString() ?? '',
      turno_descricao: gestaoJson['turno_descricao']?.toString() ?? '',
      configuracao_id: gestaoJson['configuracao_id']?.toString() ?? '',
      configuracao_descricao:
          gestaoJson['configuracao_descricao']?.toString() ?? '',
      ano_descricao: gestaoJson['ano_descricao']?.toString() ?? '',
      circuito_nota_id: gestaoJson['circuito_nota_id']?.toString() ?? '',
      relacoesDiasHorarios: relacoesDiasHorarios,
      instrutorDisciplinaTurma_id:
          gestaoJson['instrutorDisciplinaTurma_id']?.toString(),
      is_polivalencia: gestaoJson['is_polivalencia'],
      circuito: Circuito.fromJson(gestaoJson['circuito'] ?? {}),
      is_infantil:
          gestaoJson['is_infantil'] ?? false, // Ensure default value if null
      multi_etapa: gestaoJson['multi_etapa'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'GestaoAtiva('
        'idt_id: $idt_id, '
        'idt_instrutor_id: $idt_instrutor_id, '
        'idt_turma_id: $idt_turma_id, '
        'idt_disciplina_id: $idt_disciplina_id, '
        'instrutor_nome: $instrutor_nome, '
        'disciplina_descricao: $disciplina_descricao, '
        'turma_descricao: $turma_descricao, '
        'turma_sistema_bncc_id: $turma_sistema_bncc_id, '
        'curso_id: $curso_id, '
        'curso_descricao: $curso_descricao, '
        'turno_id: $turno_id, '
        'turno_descricao: $turno_descricao, '
        'configuracao_id: $configuracao_id, '
        'configuracao_descricao: $configuracao_descricao, '
        'ano_descricao: $ano_descricao, '
        'circuito_nota_id: $circuito_nota_id, '
        'relacoesDiasHorarios: ${relacoesDiasHorarios.length} items, '
        'circuito: ${circuito.toString()}, '
        'is_polivalencia: ${is_polivalencia.toString()}, '
        'instrutorDisciplinaTurma_id: $instrutorDisciplinaTurma_id'
        'is_infantil: $is_infantil'
        'multi_etapa: $multi_etapa'
        ')';
  }
}
