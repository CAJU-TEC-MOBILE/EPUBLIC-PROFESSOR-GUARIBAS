import 'package:hive_flutter/adapters.dart';

class Anexo {
  int id;
  String aluno_id;
  String turma_id;
  String? franquia_id;
  String anexo_nome;
  bool online;

  Anexo({
    required this.id,
    required this.aluno_id,
    required this.turma_id,
    this.franquia_id,
    required this.anexo_nome,
    required this.online,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aluno_id': aluno_id,
      'turma_id': turma_id,
      'franquia_id': franquia_id,
      'anexo_nome': anexo_nome,
      'online': online
    };
  }

  factory Anexo.fromMap(Map<String, dynamic> map) {
    return Anexo(
      id: map['id'],
      aluno_id: map['aluno_id'],
      turma_id: map['turma_id'],
      franquia_id: map['franquia_id'],
      anexo_nome: map['anexo_nome'],
      online: map['online'],
    );
  }

  @override
  String toString() {
    return 'Anexo{id: $id, aluno_id: $aluno_id, turma_id: $turma_id, franquia_id: $franquia_id, anexo_nome: $anexo_nome, online: $online}';
  }
}

class AnexoAdapter extends TypeAdapter<Anexo> {
  @override
  final typeId = 45;

  @override
  Anexo read(BinaryReader reader) {
    return Anexo(
      id: reader.readInt(),
      aluno_id: reader.readString(),
      turma_id: reader.readString(),
      franquia_id: reader.readString(),
      anexo_nome: reader.readString(),
      online: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Anexo obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.aluno_id);
    writer.writeString(obj.turma_id);
    writer.writeString(obj.franquia_id ?? '');
    writer.writeString(obj.anexo_nome);
    writer.writeBool(obj.online);
  }
}
