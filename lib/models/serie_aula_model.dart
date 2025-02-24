import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Represents a class for a series of classes in a specific subject.
class SerieAula {
  final String? id;
  final String aulaId;
  final String disciplinaId; // Added disciplinaId
  final String? turmaId;
  final String? serieId;
  final String? anoId;
  final String? cursoId;
  final String? historico;
  final String? descricao;
  final String? situacao;

  /// Constructor for the SerieAula class.
  SerieAula({
    this.id,
    required this.aulaId,
    required this.disciplinaId, // Mark disciplinaId as required
    this.turmaId,
    this.serieId,
    this.anoId,
    this.cursoId,
    this.historico,
    this.descricao,
    this.situacao,
  });

  /// Creates a copy of the current SerieAula instance with modified fields.
  SerieAula copyWith({
    String? id,
    String? aulaId,
    String? disciplinaId, // Added disciplinaId to copyWith
    String? turmaId,
    String? serieId,
    String? anoId,
    String? cursoId,
    String? historico,
    String? descricao,
    String? situacao,
  }) {
    return SerieAula(
      id: id ?? this.id,
      aulaId: aulaId ?? this.aulaId,
      disciplinaId: disciplinaId ?? this.disciplinaId, // Keeping disciplinaId
      turmaId: turmaId ?? this.turmaId,
      serieId: serieId ?? this.serieId,
      anoId: anoId ?? this.anoId,
      cursoId: cursoId ?? this.cursoId,
      historico: historico ?? this.historico,
      descricao: descricao ?? this.descricao,
      situacao: situacao ?? this.situacao,
    );
  }

  /// Converts the instance to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aula_id': aulaId,
      'disciplina_id': disciplinaId, // Added disciplina_id mapping
      'turma_id': turmaId,
      'serie_id': serieId,
      'ano_id': anoId,
      'curso_id': cursoId,
      'historico': historico,
      'descricao': descricao,
      'situacao': situacao,
    };
  }

  /// Creates an instance from a map.
  factory SerieAula.fromMap(Map<String, dynamic> map) {
    return SerieAula(
      id: map['id'],
      aulaId: map['aula_id'],
      disciplinaId: map['disciplina_id'], // Ensure disciplina_id is retrieved
      turmaId: map['turma_id'],
      serieId: map['serie_id'],
      anoId: map['ano_id'],
      cursoId: map['curso_id'],
      historico: map['historico'],
      descricao: map['descricao'],
      situacao: map['situacao'],
    );
  }

  /// Converts the instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates an instance from a JSON string.
  factory SerieAula.fromJson(String source) =>
      SerieAula.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SerieAula(id: $id, aulaId: $aulaId, disciplinaId: $disciplinaId, turmaId: $turmaId, serieId: $serieId, anoId: $anoId, cursoId: $cursoId, historico: $historico, descricao: $descricao, situacao: $situacao)';
  }

  @override
  bool operator ==(covariant SerieAula other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.aulaId == aulaId &&
        other.disciplinaId ==
            disciplinaId && // Added comparison for disciplinaId
        other.turmaId == turmaId &&
        other.serieId == serieId &&
        other.anoId == anoId &&
        other.cursoId == cursoId &&
        other.historico == historico &&
        other.descricao == descricao &&
        other.situacao == situacao;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        aulaId.hashCode ^
        disciplinaId.hashCode ^ // Added hashCode for disciplinaId
        turmaId.hashCode ^
        serieId.hashCode ^
        anoId.hashCode ^
        cursoId.hashCode ^
        historico.hashCode ^
        descricao.hashCode ^
        situacao.hashCode;
  }
}

/// TypeAdapter for SerieAula to enable Hive persistence.
class SerieAulaAdapter extends TypeAdapter<SerieAula> {
  @override
  final typeId = 28;

  @override
  SerieAula read(BinaryReader reader) {
    return SerieAula(
      id: reader.readString(),
      aulaId: reader.readString(),
      disciplinaId: reader.readString(), // Added disciplinaId reading
      turmaId: reader.readString(),
      serieId: reader.readString(),
      anoId: reader.readString(),
      cursoId: reader.readString(),
      historico: reader.readString(),
      descricao: reader.readString(),
      situacao: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, SerieAula obj) {
    writer.writeString(obj.id ?? ''); // Handling null safely
    writer.writeString(obj.aulaId);
    writer.writeString(
        obj.disciplinaId); // Always required, no need for null check
    writer.writeString(obj.turmaId ?? '');
    writer.writeString(obj.serieId ?? '');
    writer.writeString(obj.anoId ?? '');
    writer.writeString(obj.cursoId ?? '');
    writer.writeString(obj.historico ?? '');
    writer.writeString(obj.descricao ?? '');
    writer.writeString(obj.situacao ?? '');
  }
}
