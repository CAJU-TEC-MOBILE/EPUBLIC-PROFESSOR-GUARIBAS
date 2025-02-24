import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Serie {
  final String? id;
  final String? turmaId;
  final String? serieId;
  final String? anoId;
  final String? cursoId;
  final String? historico;
  final String? descricao;
  final String? situacao;
  final bool? is_infantil;

  Serie({
    this.id,
    this.turmaId,
    this.serieId,
    this.anoId,
    this.cursoId,
    this.historico,
    this.descricao,
    this.situacao,
    this.is_infantil,
  });

  Serie copyWith({
    String? id,
    String? turmaId,
    String? serieId,
    String? anoId,
    String? cursoId,
    String? historico,
    String? descricao,
    String? situacao,
    bool? is_infantil,
  }) {
    return Serie(
      id: id ?? this.id,
      turmaId: turmaId ?? this.turmaId,
      serieId: serieId ?? this.serieId,
      anoId: anoId ?? this.anoId,
      cursoId: cursoId ?? this.cursoId,
      historico: historico ?? this.historico,
      descricao: descricao ?? this.descricao,
      situacao: situacao ?? this.situacao,
      is_infantil: is_infantil ?? this.is_infantil,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'turmaId': turmaId,
      'serieId': serieId,
      'anoId': anoId,
      'cursoId': cursoId,
      'historico': historico,
      'descricao': descricao,
      'situacao': situacao,
      'is_infantil': is_infantil,
    };
  }

  factory Serie.fromMap(Map<String, dynamic> map) {
    return Serie(
      id: map['id'] != null ? map['id'] as String : null,
      turmaId: map['turmaId'] != null ? map['turmaId'] as String : null,
      serieId: map['serieId'] != null ? map['serieId'] as String : null,
      anoId: map['anoId'] != null ? map['anoId'] as String : null,
      cursoId: map['cursoId'] != null ? map['cursoId'] as String : null,
      historico: map['historico'] != null ? map['historico'] as String : null,
      descricao: map['descricao'] != null ? map['descricao'] as String : null,
      situacao: map['situacao'] != null ? map['situacao'] as String : null,
      is_infantil:
          map['is_infantil'] != null ? map['is_infantil'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Serie.fromJson(String source) =>
      Serie.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Serie(id: $id, turmaId: $turmaId, serieId: $serieId, anoId: $anoId, cursoId: $cursoId, historico: $historico, descricao: $descricao, situacao: $situacao, is_infantil: $is_infantil)';
  }

  @override
  bool operator ==(covariant Serie other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.turmaId == turmaId &&
        other.serieId == serieId &&
        other.anoId == anoId &&
        other.cursoId == cursoId &&
        other.historico == historico &&
        other.descricao == descricao &&
        other.situacao == situacao &&
        other.is_infantil == is_infantil;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        turmaId.hashCode ^
        serieId.hashCode ^
        anoId.hashCode ^
        cursoId.hashCode ^
        historico.hashCode ^
        descricao.hashCode ^
        situacao.hashCode ^
        is_infantil.hashCode;
  }
}

class SerieAdapter extends TypeAdapter<Serie> {
  @override
  final typeId = 25;

  @override
  Serie read(BinaryReader reader) {
    return Serie(
      id: reader.readString(),
      turmaId: reader.readString(),
      serieId: reader.readString(),
      anoId: reader.readString(),
      cursoId: reader.readString(),
      historico: reader.readString(),
      descricao: reader.readString(),
      situacao: reader.readString(),
      is_infantil: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Serie obj) {
    writer.writeString(obj.id!);
    writer.writeString(obj.turmaId!);
    writer.writeString(obj.serieId!);
    writer.writeString(obj.anoId!);
    writer.writeString(obj.cursoId!);
    writer.writeString(obj.historico!);
    writer.writeString(obj.descricao!);
    writer.writeString(obj.situacao!);
    writer.writeBool(obj.is_infantil!);
  }
}
