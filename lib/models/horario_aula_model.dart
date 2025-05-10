// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class HorarioConfiguracao {
  final String id;
  final String turnoID;
  final String descricao;
  final String inicio;
  final String fim;
  final String? tipo_horario;

  HorarioConfiguracao({
    required this.id,
    required this.turnoID,
    required this.descricao,
    required this.inicio,
    required this.fim,
    this.tipo_horario,
  });

  factory HorarioConfiguracao.vazio() {
    return HorarioConfiguracao(
      id: '-1',
      turnoID: '-1',
      descricao: 'Horário inexistente',
      inicio: '',
      fim: '',
      tipo_horario: null,
    );
  }

  factory HorarioConfiguracao.fromJson(Map<dynamic, dynamic> json) {
    return HorarioConfiguracao(
      id: json['id']?.toString() ?? '',
      turnoID: json['turno_id']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      inicio: json['inicio']?.toString() ?? '',
      fim: json['final']?.toString() ?? '',
      tipo_horario: json['tipo_horario']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'HorarioConfiguracao(id: $id, turnoID: $turnoID, descricao: $descricao, inicio: $inicio, fim: $fim, tipo_horario: $tipo_horario)';
  }

  HorarioConfiguracao copyWith({
    String? id,
    String? turnoID,
    String? descricao,
    String? inicio,
    String? fim,
    String? tipo_horario,
  }) {
    return HorarioConfiguracao(
      id: id ?? this.id,
      turnoID: turnoID ?? this.turnoID,
      descricao: descricao ?? this.descricao,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
      tipo_horario: tipo_horario ?? this.tipo_horario,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'turnoID': turnoID,
      'descricao': descricao,
      'inicio': inicio,
      'fim': fim,
      'tipo_horario': tipo_horario,
    };
  }

  factory HorarioConfiguracao.fromMap(Map<String, dynamic> map) {
    return HorarioConfiguracao(
      id: map['id'].toString(),
      turnoID: map['turnoID'].toString(),
      descricao: map['descricao'].toString(),
      inicio: map['inicio'].toString(),
      fim: map['fim'].toString(),
      tipo_horario: map['tipo_horario']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  // factory HorarioConfiguracao.fromJson(String source) =>
  //     HorarioConfiguracao.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant HorarioConfiguracao other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.turnoID == turnoID &&
        other.descricao == descricao &&
        other.inicio == inicio &&
        other.fim == fim &&
        other.tipo_horario == tipo_horario;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        turnoID.hashCode ^
        descricao.hashCode ^
        inicio.hashCode ^
        fim.hashCode ^
        tipo_horario.hashCode;
  }
}

class HorarioConfiguracaoAdapter extends TypeAdapter<HorarioConfiguracao> {
  @override
  final int typeId = 20;

  @override
  HorarioConfiguracao read(BinaryReader reader) {
    return HorarioConfiguracao(
      id: reader.readString(),
      turnoID: reader.readString(),
      descricao: reader.readString(),
      inicio: reader.readString(),
      fim: reader.readString(),
      tipo_horario: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, HorarioConfiguracao obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.turnoID);
    writer.writeString(obj.descricao);
    writer.writeString(obj.inicio);
    writer.writeString(obj.fim);
    writer.writeString(obj.tipo_horario ?? '');
  }
}
