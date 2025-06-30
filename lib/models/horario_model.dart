// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Horario {
  final String id;
  final String turnoID;
  final String descricao;
  final String inicio;
  final String fim;

  Horario({
    required this.id,
    required this.turnoID,
    required this.descricao,
    required this.inicio,
    required this.fim,
  });

  factory Horario.fromJson(Map<dynamic, dynamic> json) {
    return Horario(
        id: json['id']?.toString() ?? '',
        turnoID: json['turno_id']?.toString() ?? '',
        descricao: json['descricao']?.toString() ?? '',
        inicio: json['inicio']?.toString() ?? '',
        fim: json['final']?.toString() ?? '');
  }

  @override
  String toString() {
    return 'Horario(id: $id, turnoID: $turnoID, descricao: $descricao, inicio: $inicio, fim: $fim)';
  }

  Horario copyWith({
    String? id,
    String? turnoID,
    String? descricao,
    String? inicio,
    String? fim,
  }) {
    return Horario(
      id: id ?? this.id,
      turnoID: turnoID ?? this.turnoID,
      descricao: descricao ?? this.descricao,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'turnoID': turnoID,
      'descricao': descricao,
      'inicio': inicio,
      'fim': fim,
    };
  }

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'] as String,
      turnoID: map['turnoID'] as String,
      descricao: map['descricao'] as String,
      inicio: map['inicio'] as String,
      fim: map['fim'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(covariant Horario other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.turnoID == turnoID &&
        other.descricao == descricao &&
        other.inicio == inicio &&
        other.fim == fim;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        turnoID.hashCode ^
        descricao.hashCode ^
        inicio.hashCode ^
        fim.hashCode;
  }
}
