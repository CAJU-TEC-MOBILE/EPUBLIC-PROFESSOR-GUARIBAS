import 'package:hive_flutter/hive_flutter.dart';

class Ano {
  int id;
  String? descricao;
  String? situacao;

  Ano({
    required this.id,
    this.descricao,
    this.situacao,
  });

  // Convertendo para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'situacao': situacao,
    };
  }

  factory Ano.fromJson(Map<String, dynamic> json) {
    try {
      return Ano(
        id: json['id'],
        descricao: json['descricao'].toString(),
        situacao: json['situacao'].toString(),
      );
    } catch (error) {
      return Ano.vazio();
    }
  }

  @override
  String toString() {
    return 'Ano{id: $id, descricao: $descricao, situacao: $situacao}';
  }

  static Ano fromMap(Map<String, dynamic> map) {
    return Ano(
      id: map['id'],
      descricao: map['descricao'],
      situacao: map['situacao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'situacao': situacao,
    };
  }

  factory Ano.vazio() {
    return Ano(
      id: -1,
      descricao: null,
      situacao: null,
    );
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
    );
  }

  @override
  void write(BinaryWriter writer, Ano obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.descricao ?? '');
    writer.writeString(obj.situacao ?? '');
  }
}
