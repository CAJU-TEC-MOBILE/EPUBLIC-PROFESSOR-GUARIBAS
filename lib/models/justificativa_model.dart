import 'package:hive_flutter/hive_flutter.dart';

class Justificativa {
  final String id;
  final String descricao;

  Justificativa({
    required this.id,
    required this.descricao,
  });

  factory Justificativa.fromJson(Map<dynamic, dynamic> justificativaJson) {
    return Justificativa(
      id: justificativaJson['id'].toString(),
      descricao: justificativaJson['descricao'].toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Justificativa && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Justificativa(id: $id, descricao: $descricao)';
  }
}

class JustificativaAdapter extends TypeAdapter<Justificativa> {
  @override
  final typeId = 4;

  @override
  Justificativa read(BinaryReader reader) {
    return Justificativa(
        id: reader.readString(), descricao: reader.readString());
  }

  @override
  void write(BinaryWriter writer, Justificativa obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.descricao);
  }
}
