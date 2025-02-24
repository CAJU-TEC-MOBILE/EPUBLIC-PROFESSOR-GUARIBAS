import 'package:hive_flutter/hive_flutter.dart';

class Matricula {
  final String matricula_id;
  final String turma_id;
  final String aluno_id;
  final String aluno_nome;
  final String matricula_situacao;
  int? justificativa_id;
  String? justificativa;
  int? codigo;
  bool? existe_anexo;

  Matricula({
    required this.matricula_id,
    required this.turma_id,
    required this.aluno_id,
    required this.aluno_nome,
    required this.matricula_situacao,
    this.justificativa_id,
    this.justificativa,
    this.codigo,
    this.existe_anexo,
  });

  factory Matricula.fromJson(Map<dynamic, dynamic> matriculaJson) {
    return Matricula(
      matricula_id: matriculaJson['matricula_id'].toString(),
      turma_id: matriculaJson['turma_id'].toString(),
      aluno_id: matriculaJson['aluno_id'].toString(),
      aluno_nome: matriculaJson['aluno_nome'].toString(),
      matricula_situacao: matriculaJson['matricula_situacao'].toString(),
      codigo: matriculaJson['codigo'] ?? 0,
      justificativa_id: matriculaJson['justificativa_id'] ?? 0,
      justificativa: matriculaJson['justificativa'] ?? '',
      existe_anexo: matriculaJson['existe_anexo'] ?? false,
    );
  }
  @override
  String toString() {
    return 'Matricula(matricula_id: $matricula_id, turma_id: $turma_id, aluno_id: $aluno_id, aluno_nome: $aluno_nome, existe_anexo: $existe_anexo, codigo: $codigo, justificativa: $justificativa, justificativa_id: $justificativa_id, matricula_situacao: $matricula_situacao)';
  }
}

class MatriculaAdapter extends TypeAdapter<Matricula> {
  @override
  final typeId = 1;

  @override
  Matricula read(BinaryReader reader) {
    return Matricula(
      matricula_id: reader.readString(),
      turma_id: reader.readString(),
      aluno_id: reader.readString(),
      aluno_nome: reader.readString(),
      matricula_situacao: reader.readString(),
      justificativa: reader.readString(),
      justificativa_id: reader.readInt(),
      existe_anexo: reader.readBool(),
      codigo: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Matricula obj) {
    writer.writeString(obj.matricula_id);
    writer.writeString(obj.turma_id);
    writer.writeString(obj.aluno_id);
    writer.writeString(obj.aluno_nome);
    writer.writeString(obj.matricula_situacao);
    writer.writeInt(obj.codigo ?? 0);
    writer.writeString(obj.justificativa ?? '');
    writer.writeInt(obj.justificativa_id ?? 0);
    writer.writeBool(obj.existe_anexo ?? false);
  }
}
