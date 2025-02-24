import 'package:hive_flutter/hive_flutter.dart';

class Ano {
  int id;
  String descricao;
  String situacao;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Ano({
    required this.id,
    required this.descricao,
    required this.situacao,
    this.createdAt,
    this.updatedAt,
    this.deleteAt,
  });

  // Convertendo para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'situacao': situacao,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deleteAt': deleteAt,
    };
  }

  factory Ano.fromJson(Map<String, dynamic> json) {
    return Ano(
      id: json['id'],
      descricao: json['descricao'],
      situacao: json['situacao'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deleteAt: json['deleteAt'],
    );
  }

  @override
  String toString() {
    return 'Ano{id: $id, descricao: $descricao, situacao: $situacao, createdAt: $createdAt, updatedAt: $updatedAt, deleteAt: $deleteAt}';
  }

  static Ano fromMap(Map<String, dynamic> map) {
    return Ano(
      id: map['id'],
      descricao: map['descricao'],
      situacao: map['situacao'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      deleteAt: map['deleteAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'situacao': situacao,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deleteAt': deleteAt,
    };
  }
}

class AnoAdapter extends TypeAdapter<Ano> {
  @override
  final typeId = 41;

  @override
  Ano read(BinaryReader reader) {
    return Ano(
      id: reader.readInt(),
      descricao: reader.readString(),
      situacao: reader.readString(),
      createdAt: reader.readString(),
      updatedAt: reader.readString(),
      deleteAt: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Ano obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.descricao);
    writer.writeString(obj.situacao);
    writer.writeString(obj.createdAt ?? '');
    writer.writeString(obj.updatedAt ?? '');
    writer.writeString(obj.deleteAt ?? '');
  }
}
