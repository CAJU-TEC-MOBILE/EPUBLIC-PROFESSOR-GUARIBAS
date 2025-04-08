import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class TipoAula {
  final String? id;
  final String descricao;

  const TipoAula({
    this.id,
    required this.descricao,
  });

  TipoAula copyWith({
    String? id,
    String? descricao,
  }) {
    return TipoAula(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }

  factory TipoAula.fromMap(Map<String, dynamic> map) {
    return TipoAula(
      id: map['id'] as String?,
      descricao: map['descricao'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TipoAula.fromJson(String source) =>
      TipoAula.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TipoAula => id: $id | descricao: $descricao';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TipoAula &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            descricao == other.descricao);
  }

  @override
  int get hashCode => id.hashCode ^ descricao.hashCode;
}

class TipoAulaAdapter extends TypeAdapter<TipoAula> {
  @override
  final typeId = 26;

  @override
  TipoAula read(BinaryReader reader) {
    return TipoAula(
      id: reader.readString(),
      descricao: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, TipoAula obj) {
    writer.writeString(obj.id ?? '');
    writer.writeString(obj.descricao);
  }
}
