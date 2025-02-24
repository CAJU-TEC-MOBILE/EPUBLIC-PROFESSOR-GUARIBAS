import 'package:hive_flutter/hive_flutter.dart';

class HistoricoPresenca {
  final String? id;
  final String? criadaPeloCelular;
  final String? gestaoId;
  final String? aulaId;
  final String? alunoId;
  final String? disciplinaId;
  final String? turmaId;
  final String? franquiaId;
  final String? professorId;
  String? justificativaId;
  final bool presenca;
  final String? anexo;

  HistoricoPresenca({
    this.id,
    this.criadaPeloCelular,
    this.gestaoId,
    this.aulaId,
    this.alunoId,
    this.disciplinaId,
    this.turmaId,
    this.franquiaId,
    this.professorId,
    required this.presenca,
    this.justificativaId,
    this.anexo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'criadaPeloCelular': criadaPeloCelular,
      'gestaoId': gestaoId,
      'aulaId': aulaId,
      'alunoId': alunoId,
      'disciplinaId': disciplinaId,
      'turmaId': turmaId,
      'franquiaId': franquiaId,
      'professorId': professorId,
      'justificativaId': justificativaId,
      'presenca': presenca,
      'anexo': anexo,
    };
  }

  factory HistoricoPresenca.fromMap(Map<String, dynamic> map) {
    return HistoricoPresenca(
      id: map['id'],
      criadaPeloCelular: map['criadaPeloCelular'],
      gestaoId: map['gestaoId'],
      aulaId: map['aulaId'],
      alunoId: map['alunoId'],
      disciplinaId: map['disciplinaId'],
      turmaId: map['turmaId'],
      franquiaId: map['franquiaId'],
      professorId: map['professorId'],
      presenca: map['presenca'],
      anexo: map['anexo'],
      justificativaId: map['justificativaId'],
    );
  }

  @override
  String toString() {
    return 'HistoricoPresenca{id: $id, justificativaId: $justificativaId, criadaPeloCelular: $criadaPeloCelular, gestaoId: $gestaoId, aulaId: $aulaId, alunoId: $alunoId, disciplinaId: $disciplinaId, turmaId: $turmaId, franquiaId: $franquiaId, professorId: $professorId, presenca: $presenca, anexo: $anexo}';
  }
}

class HistoricoPresencaAdapter extends TypeAdapter<HistoricoPresenca> {
  @override
  final typeId = 88;

  @override
  HistoricoPresenca read(BinaryReader reader) {
    return HistoricoPresenca(
      id: reader.readString(),
      criadaPeloCelular: reader.readString(),
      gestaoId: reader.readString(),
      aulaId: reader.readString(),
      alunoId: reader.readString(),
      disciplinaId: reader.readString(),
      turmaId: reader.readString(),
      franquiaId: reader.readString(),
      professorId: reader.readString(),
      presenca: reader.readBool(),
      anexo: reader.readString(),
      justificativaId: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, HistoricoPresenca obj) {
    writer.writeString(obj.id ?? '');
    writer.writeString(obj.criadaPeloCelular ?? '');
    writer.writeString(obj.gestaoId ?? '');
    writer.writeString(obj.aulaId ?? '');
    writer.writeString(obj.alunoId ?? '');
    writer.writeString(obj.disciplinaId ?? '');
    writer.writeString(obj.turmaId ?? '');
    writer.writeString(obj.franquiaId ?? '');
    writer.writeString(obj.professorId ?? '');
    writer.writeBool(obj.presenca);
    writer.writeString(obj.anexo ?? '');
    writer.writeString(obj.justificativaId ?? '');
  }
}
