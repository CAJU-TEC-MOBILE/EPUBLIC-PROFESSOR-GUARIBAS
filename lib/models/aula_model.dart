import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:professor_acesso_notifiq/models/horario_model.dart';

import '../constants/app_tema.dart';
import '../services/controller/config_horario_configuracao.dart';
import '../services/controller/disciplina_aula_controller.dart';
import '../services/controller/disciplina_controller.dart';
import '../services/controller/horario_controller.dart';
import 'disciplina_aula_model.dart';
import 'disciplina_model.dart';
import 'serie_model.dart';

class Aula {
  var id;
  var instrutor_id;
  var disciplina_id;
  var turma_id;
  var tipoDeAula;
  var dataDaAula;
  var horarioID;
  List<int> horarios_infantis;
  var conteudo;
  var metodologia;
  var saberes_conhecimentos;
  var dia_da_semana;
  var situacao;
  var criadaPeloCelular;
  var etapa_id;
  var instrutorDisciplinaTurma_id;
  List<String> experiencias;
  var eixos;
  var estrategias;
  var recursos;
  var atividade_casa;
  var atividade_classe;
  final int? e_aula_infantil;
  var observacoes;
  int is_polivalencia;
  String? campos_de_experiencias;
  List<dynamic>? disciplinas;
  List<dynamic>? horarios_extras_formatted;
  int? multi_etapa;
  List<Serie>? series;
  String? disciplinas_formatted;
  String? horarios_formatted;
  Aula(
      {this.id = '',
      required this.instrutor_id,
      required this.disciplina_id,
      required this.turma_id,
      required this.tipoDeAula,
      required this.dataDaAula,
      required this.horarioID,
      required this.horarios_infantis,
      required this.conteudo,
      required this.metodologia,
      required this.saberes_conhecimentos,
      required this.dia_da_semana,
      required this.situacao,
      required this.criadaPeloCelular,
      required this.etapa_id,
      required this.instrutorDisciplinaTurma_id,
      required this.eixos,
      required this.estrategias,
      required this.recursos,
      required this.atividade_casa,
      required this.atividade_classe,
      required this.observacoes,
      required this.is_polivalencia,
      required this.experiencias,
      this.e_aula_infantil,
      this.campos_de_experiencias,
      this.disciplinas,
      this.horarios_extras_formatted,
      this.multi_etapa,
      this.series,
      this.horarios_formatted,
      this.disciplinas_formatted});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'disciplinas_formatted': disciplinas_formatted,
      'instrutor_id': instrutor_id,
      'disciplina_id': disciplina_id,
      'turma_id': turma_id,
      'tipoDeAula': tipoDeAula,
      'e_aula_infantil': e_aula_infantil,
      'dataDaAula': dataDaAula,
      'horarioID': horarioID,
      'horarios_infantis': horarios_infantis,
      'conteudo': conteudo,
      'metodologia': metodologia,
      'saberes_conhecimentos': saberes_conhecimentos,
      'dia_da_semana': dia_da_semana,
      'situacao': situacao,
      'criadaPeloCelular': criadaPeloCelular,
      'etapa_id': etapa_id,
      'instrutorDisciplinaTurma_id': instrutorDisciplinaTurma_id,
      'eixos': eixos,
      'estrategias': estrategias,
      'recursos': recursos,
      'dia_da_semana': dia_da_semana.toString(),
      'atividade_casa': atividade_casa,
      'atividade_classe': atividade_classe,
      'observacoes': observacoes,
      'experiencias': experiencias,
      'is_polivalencia': is_polivalencia,
      'disciplinas': disciplinas,
      'horarios_extras_formatted': horarios_extras_formatted,
      'campos_de_experiencias': campos_de_experiencias.toString(),
      'multi_etapa': multi_etapa ?? 0,
      'series': series ?? [],
      'horarios_formatted': horarios_formatted
    };
  }

  String get dataDaAulaPtBr {
    try {
      final parsedDate = DateTime.parse(dataDaAula);
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(parsedDate);
    } catch (e) {
      return dataDaAula.toString();
    }
  }

  Color get corSituacao {
    switch (situacao) {
      case 'Aula confirmada':
        return Colors.green;
      case 'Aula em conflito':
        return AppTema.primaryAmarelo;
      case 'Aula rejeitada por falta':
        return Colors.red;
      case 'Aula inválida':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<String> get descricaoHorarioPeloIdHorario async {
    if (horarioID == null || horarioID.toString().isEmpty) {
      return 'Sem horário';
    }

    final String horarioIDString = horarioID.toString();

    final int? horarioIDInt = int.tryParse(horarioIDString);

    if (horarioIDInt == null) {
      return 'ID de horário inválido';
    }

    HorarioController horarioController = HorarioController();

    final descricao = await horarioController.getDescricaoHorario(horarioIDInt);
    return descricao;
  }

  Future<String> get descricaoDisciplinaId async {
    if (disciplina_id == null || disciplina_id.toString().isEmpty) {
      return 'Sem disciplina';
    }

    final String disciplinaIdString = disciplina_id.toString();

    final int? disciplinaId = int.tryParse(disciplinaIdString);

    if (disciplinaId == null) {
      return 'ID de disciplina inválido';
    }

    DisciplinaController disciplinaController = DisciplinaController();

    await disciplinaController.init();
    List<Disciplina> disciplina = disciplinaController.getAllDisciplinas();

    final descricao = await disciplinaController.getDisciplinaDescricao(
        disciplinaId: disciplinaIdString);
    return descricao;
  }

  Future<String> disciplinasAulaLocal() async {
    DisciplinaAulaController disciplinaAulaController =
        DisciplinaAulaController();

    if (criadaPeloCelular.toString().isEmpty) {
      return '';
    }

    await disciplinaAulaController.init();

    List<DisciplinaAula> result =
        await disciplinaAulaController.getDisciplinaAulaCriadaPeloCelular(
      criadaPeloCelular: criadaPeloCelular.toString(),
    );

    if (result.isEmpty) {
      return '';
    }

    String disciplinas =
        result.map((disciplinaAula) => disciplinaAula.descricao).join(', ');

    return disciplinas;
  }

  Future<List<int>> getHorariosIdsAula() async {
    DisciplinaAulaController disciplinaAulaController =
        DisciplinaAulaController();
    await disciplinaAulaController.init();

    List<int> horariosId = [];

    List<DisciplinaAula> disciplinas =
        await disciplinaAulaController.getDisciplinaAulaCriadaPeloCelular(
            criadaPeloCelular: criadaPeloCelular);

    if (disciplinas.isNotEmpty) {
      for (var disciplina in disciplinas) {
        if (disciplina.data.isNotEmpty) {
          for (var item in disciplina.data) {
            if (item['horarios'] is List && item['horarios'].isNotEmpty) {
              horariosId.addAll(List<int>.from(item['horarios']));
            }
          }
        }
      }
    }

    return horariosId;
  }

  Future<String> getHorario({required String horarioId}) async {
    final configHorarioConfiguracao = ConfigHorarioConfiguracao();
    await configHorarioConfiguracao.init();

    Horario model = await configHorarioConfiguracao.horario(
      horarioId: horarioId,
    );

    return model.descricao;
  }

  Future<String> getDescricaoHorario() async {
    final configHorarioConfiguracao = ConfigHorarioConfiguracao();
    await configHorarioConfiguracao.init();

    Horario model = await configHorarioConfiguracao.horario(
      horarioId: horarioID.toString(),
    );

    return model.descricao;
  }

  Future<String> getHorariosAula() async {
    final disciplinaAulaController = DisciplinaAulaController();
    final horarioController = HorarioController();

    await disciplinaAulaController.init();
    await horarioController.init();

    final Set<int> horariosId = {};
    final List<String> horariosDescricao = [];

    try {
      final disciplinas =
          await disciplinaAulaController.getDisciplinaAulaCriadaPeloCelular(
        criadaPeloCelular: criadaPeloCelular,
      );

      for (final disciplina in disciplinas) {
        if (disciplina.data.isNotEmpty) {
          for (final item in disciplina.data) {
            if (item['horarios'] is List) {
              horariosId.addAll(List<int>.from(item['horarios']));
            }
          }
        }
      }

      if (horariosId.isNotEmpty) {
        final descricoes = await Future.wait(
          horariosId.map((id) async {
            final descricao = await getHorario(horarioId: id.toString());
            if (descricao.isNotEmpty) {
              return descricao.toString();
            }
            return null;
          }),
        );

        horariosDescricao.addAll(descricoes.whereType<String>());
      }
      if (horariosDescricao.isEmpty) {
        return '';
      }
      return horariosDescricao.join(', ');
    } catch (e) {
      return '';
    }
  }

  factory Aula.fromJson(Map<dynamic, dynamic> json) {
    return Aula(
      id: json['id'].toString(),
      disciplinas_formatted: json['disciplinas_formatted'].toString(),
      instrutor_id: json['instrutor_id'].toString(),
      disciplina_id: json['disciplina_id'].toString(),
      turma_id: json['turma_id'].toString(),
      tipoDeAula: json['tipoDeAula'].toString(),
      dataDaAula: json['dataDaAula'].toString(),
      horarioID: json['horarioID'].toString(),
      horarios_infantis: json['horarios_infantis'],
      conteudo: json['conteudo'].toString(),
      metodologia: json['metodologia'].toString(),
      saberes_conhecimentos: json['saberes_conhecimentos'].toString(),
      dia_da_semana: json['dia_da_semana'].toString(),
      situacao: json['situacao'].toString(),
      criadaPeloCelular: json['criadaPeloCelular'].toString(),
      etapa_id: json['etapa_id'].toString(),
      instrutorDisciplinaTurma_id:
          json['instrutorDisciplinaTurma_id'].toString(),
      eixos: json['eixos'].toString(),
      estrategias: json['estrategias'].toString(),
      recursos: json['recursos'].toString(),
      atividade_casa: json['atividade_casa'].toString(),
      atividade_classe: json['atividade_classe'].toString(),
      observacoes: json['observacoes'].toString(),
      e_aula_infantil: json['e_aula_infantil']!,
      is_polivalencia: json['is_polivalencia'],
      campos_de_experiencias: json['campos_de_experiencias'],
      //experiencias: List<String>.from(json['experiencias'] ?? []),
      experiencias: json['experiencias'],
      horarios_extras_formatted: json['horarios_extras_formatted'],
      disciplinas: json['disciplinas'],
      multi_etapa: json['multi_etapa'] ?? 0,
      series: json['series'] ?? [],
      horarios_formatted: json['horarios_formatted'].toString(),
    );
  }

  @override
  String toString() {
    return 'Aula(id: $id, instrutor_id: $instrutor_id, disciplina_id: $disciplina_id, turma_id: $turma_id, '
        'tipoDeAula: $tipoDeAula, dataDaAula: $dataDaAula, horarioID: $horarioID, horarios_infantis: $horarios_infantis, horarios_extras_formatted: $horarios_extras_formatted,'
        'conteudo: $conteudo, metodologia: $metodologia, saberes_conhecimentos: $saberes_conhecimentos, is_polivalencia: $is_polivalencia, horarios_formatted: $horarios_formatted'
        'dia_da_semana: $dia_da_semana, situacao: $situacao, criadaPeloCelular: $criadaPeloCelular, etapa_id: $etapa_id, disciplinas: $disciplinas,'
        'instrutorDisciplinaTurma_id: $instrutorDisciplinaTurma_id, eixos: $eixos, estrategias: $estrategias, campos_de_experiencias: $campos_de_experiencias, disciplinas_formatted: $disciplinas_formatted'
        'recursos: $recursos, series: $series multi_etapa: $multi_etapa, atividade_casa: $atividade_casa, atividade_classe: $atividade_classe, e_aula_infantil: $e_aula_infantil observacoes: $observacoes, experiencias: $experiencias)';
  }
}

class AulaAdapter extends TypeAdapter<Aula> {
  @override
  final typeId = 3;

  @override
  Aula read(BinaryReader reader) {
    return Aula(
      id: reader.readString(),
      instrutor_id: reader.readString(),
      disciplina_id: reader.readString(),
      e_aula_infantil: reader.readInt(),
      turma_id: reader.readString(),
      tipoDeAula: reader.readString(),
      dataDaAula: reader.readString(),
      horarioID: reader.readString(),
      horarios_infantis: reader.readIntList(),
      conteudo: reader.readString(),
      metodologia: reader.readString(),
      saberes_conhecimentos: reader.readString(),
      dia_da_semana: reader.readString(),
      situacao: reader.readString(),
      criadaPeloCelular: reader.readString(),
      etapa_id: reader.readString(),
      instrutorDisciplinaTurma_id: reader.readString(),
      eixos: reader.readString(),
      estrategias: reader.readString(),
      recursos: reader.readString(),
      atividade_casa: reader.readString(),
      atividade_classe: reader.readString(),
      observacoes: reader.readString(),
      campos_de_experiencias: reader.readString(),
      experiencias: reader.readStringList(),
      is_polivalencia: reader.readInt(),
      multi_etapa: reader.readInt(),
      series: (reader.readList()).map((item) => item as Serie).toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Aula obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.instrutor_id);
    writer.writeString(obj.disciplina_id);
    writer.writeInt(obj.e_aula_infantil!);
    writer.writeString(obj.turma_id);
    writer.writeString(obj.tipoDeAula);
    writer.writeString(obj.dataDaAula);
    writer.writeString(obj.horarioID);
    writer.writeIntList(obj.horarios_infantis);
    writer.writeString(obj.conteudo);
    writer.writeString(obj.metodologia);
    writer.writeString(obj.saberes_conhecimentos);
    writer.writeString(obj.dia_da_semana);
    writer.writeString(obj.situacao);
    writer.writeString(obj.criadaPeloCelular);
    writer.writeString(obj.etapa_id);
    writer.writeString(obj.instrutorDisciplinaTurma_id);
    writer.writeString(obj.eixos);
    writer.writeString(obj.estrategias);
    writer.writeString(obj.recursos);
    writer.writeString(obj.atividade_casa);
    writer.writeString(obj.atividade_classe);
    writer.writeString(obj.observacoes);
    writer.writeString(obj.campos_de_experiencias!);
    writer.writeStringList(obj.experiencias);
    writer.writeInt(obj.is_polivalencia);
    writer.writeInt(obj.multi_etapa ?? 0);
    writer.writeList(obj.series ?? []);
  }
}
