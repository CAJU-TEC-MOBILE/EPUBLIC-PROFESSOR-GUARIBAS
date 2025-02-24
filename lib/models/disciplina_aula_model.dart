import 'package:hive_flutter/hive_flutter.dart';

class DisciplinaAula {
  final String id;
  final String codigo;
  final String descricao;
  final String idtTurmaId;
  final String idt_id;
  var criadaPeloCelular;
  bool checkbox;
  List<dynamic> data;

  DisciplinaAula({
    required this.id,
    required this.codigo,
    required this.descricao,
    required this.idtTurmaId,
    required this.idt_id,
    required this.checkbox,
    this.criadaPeloCelular,
    required this.data,
  });

  factory DisciplinaAula.fromJson(Map<String, dynamic> json) {
    return DisciplinaAula(
        id: json['id'].toString(),
        codigo: json['codigo'].toString(),
        descricao: json['descricao'].toString(),
        idtTurmaId: json['idt_turma_id'].toString(),
        idt_id: json['idt_id'].toString(),
        checkbox: json['checkbox'] ?? false,
        data: json['data'] ?? [],
        criadaPeloCelular: json['criadaPeloCelular']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'descricao': descricao,
      'idt_turma_id': idtTurmaId,
      'idt_id': idt_id,
      'checkbox': checkbox,
      'data': data,
      'criadaPeloCelular': criadaPeloCelular
    };
  }

  void clearData() {
    data = [];
  }

  // ToString method
  @override
  String toString() {
    return 'DisciplinaAula(id: $id, criadaPeloCelular: $criadaPeloCelular, codigo: $codigo, descricao: $descricao, idtTurmaId: $idtTurmaId, idt_id: $idt_id, checkbox: $checkbox, data: $data)';
  }
}

class DisciplinaAulaAdapter extends TypeAdapter<DisciplinaAula> {
  @override
  final int typeId = 12;

  @override
  DisciplinaAula read(BinaryReader reader) {
    return DisciplinaAula(
      id: reader.readString(),
      criadaPeloCelular: reader.readString(),
      codigo: reader.readString(),
      descricao: reader.readString(),
      idtTurmaId: reader.readString(),
      idt_id: reader.readString(),
      checkbox: reader.readBool(),
      data: reader.readList(),
    );
  }

  @override
  void write(BinaryWriter writer, DisciplinaAula obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.criadaPeloCelular);
    writer.writeString(obj.codigo);
    writer.writeString(obj.descricao);
    writer.writeString(obj.idtTurmaId);
    writer.writeString(obj.idt_id);
    writer.writeBool(obj.checkbox);
    writer.writeList(obj.data);
  }
}
