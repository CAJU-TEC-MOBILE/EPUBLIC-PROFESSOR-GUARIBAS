import 'package:hive/hive.dart';

class Disciplina {
  final String id;
  final String codigo;
  final String descricao;
  final String idtTurmaId;
  final String idt_id;
  bool checkbox;
  List<dynamic> data;

  static const List<dynamic> defaultData = [
    {'conteudo': '', 'metodologia': '', 'horarios': []}
  ];

  Disciplina({
    required this.id,
    required this.codigo,
    required this.descricao,
    required this.idtTurmaId,
    required this.idt_id,
    required this.checkbox,
    List<dynamic>? data,
  }) : data = (data == null || data.isEmpty) ? defaultData : data;

  factory Disciplina.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'];
    List<dynamic> parsedData = defaultData;

    if (dataList is List) {
      parsedData = dataList.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else {
          return {'conteudo': '', 'metodologia': '', 'horarios': []};
        }
      }).toList();
    }

    return Disciplina(
      id: json['id'].toString(),
      codigo: json['codigo'].toString(),
      descricao: json['descricao'].toString(),
      idtTurmaId: json['idt_turma_id'].toString(),
      idt_id: json['idt_id'].toString(),
      checkbox: json['checkbox'] ?? false,
      data: parsedData,
    );
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
    };
  }

  void clearData() {
    data = defaultData;
  }

  factory Disciplina.vazia() {
    return Disciplina(
      id: '',
      codigo: '',
      descricao: 'Disciplina não encontrada',
      idtTurmaId: '',
      idt_id: '',
      checkbox: false,
      data: [],
    );
  }

  @override
  String toString() {
    return 'Disciplina(id: $id, codigo: $codigo, descricao: $descricao, idtTurmaId: $idtTurmaId, idt_id: $idt_id, checkbox: $checkbox, data: $data)';
  }
}

class DisciplinaAdapter extends TypeAdapter<Disciplina> {
  @override
  final int typeId = 0;

  @override
  Disciplina read(BinaryReader reader) {
    return Disciplina(
      id: reader.readString(),
      codigo: reader.readString(),
      descricao: reader.readString(),
      idtTurmaId: reader.readString(),
      idt_id: reader.readString(),
      checkbox: reader.readBool(),
      data: reader.readList(),
    );
  }

  @override
  void write(BinaryWriter writer, Disciplina obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.codigo);
    writer.writeString(obj.descricao);
    writer.writeString(obj.idtTurmaId);
    writer.writeString(obj.idt_id);
    writer.writeBool(obj.checkbox);
    writer.writeList(obj.data ??
        [
          {'conteudo': '', 'metodologia': '', 'horarios': []}
        ]);
  }
}
