import 'package:hive_flutter/hive_flutter.dart';

class GestaoDisciplina {
  String id;
  String descricao;
  List<dynamic> disciplinas;

  GestaoDisciplina({
    required this.id,
    required this.descricao,
    required this.disciplinas,
  });

  factory GestaoDisciplina.fromJson(Map<String, dynamic> json) {
    return GestaoDisciplina(
      id: json['id'].toString(),
      descricao: json['descricao'].toString(),
      disciplinas: json['disciplinas'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'disciplinas': disciplinas,
    };
  }

  @override
  String toString() {
    return 'GestaoDisciplina{id: $id, descricao: $descricao, disciplinas: $disciplinas}';
  }
}

class GestaoDisciplinaAdapter extends TypeAdapter<GestaoDisciplina> {
  @override
  final typeId = 21;

  @override
  GestaoDisciplina read(BinaryReader reader) {
    return GestaoDisciplina(
        id: reader.readString(),
        descricao: reader.readString(),
        disciplinas: reader.readList());
  }

  @override
  void write(BinaryWriter writer, GestaoDisciplina obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.descricao);
    writer.writeList(obj.disciplinas);
  }
}
