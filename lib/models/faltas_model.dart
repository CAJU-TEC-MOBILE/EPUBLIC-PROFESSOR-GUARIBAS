// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive_flutter/hive_flutter.dart';

class Falta {
  final String aula_id;
  final String matricula_id;
  final String justificativa_id;
  final String aluno_nome;
  final String observacao;
  final String document;
  final bool? existe_anexo;
  bool? status_falta;

  Falta({
    required this.aula_id,
    required this.matricula_id,
    required this.justificativa_id,
    required this.aluno_nome,
    required this.observacao,
    required this.document,
    this.existe_anexo,
    this.status_falta,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'aula_id': aula_id,
      'matricula_id': matricula_id,
      'justificativa_id': justificativa_id,
      'aluno_nome': aluno_nome,
      'observacao': observacao,
      'document': document,
      'existe_anexo': existe_anexo,
      'status_falta': status_falta
    };
  }

  @override
  String toString() {
    return '''
      ┌───────────────────────────────
      │ Aula ID:        $aula_id
      │ Matrícula ID:   $matricula_id
      │ Justificativa ID: $justificativa_id
      │ Aluno Nome:     $aluno_nome
      │ Observação:     $observacao
      │ Documento:      $document
      │ Status da Falta: $status_falta
      │ Existe Anexo:   $existe_anexo
      └───────────────────────────────
    ''';
  }
}

class FaltaAdapter extends TypeAdapter<Falta> {
  @override
  final typeId = 2;

  @override
  Falta read(BinaryReader reader) {
    return Falta(
        aula_id: reader.readString(),
        matricula_id: reader.readString(),
        justificativa_id: reader.readString(),
        aluno_nome: reader.readString(),
        observacao: reader.readString(),
        document: reader.readString(),
        existe_anexo: reader.readBool());
  }

  @override
  void write(BinaryWriter writer, Falta obj) {
    writer.writeString(obj.aula_id);
    writer.writeString(obj.matricula_id);
    writer.writeString(obj.justificativa_id);
    writer.writeString(obj.aluno_nome);
    writer.writeString(obj.observacao);
    writer.writeString(obj.document);
    writer.writeBool(obj.existe_anexo ?? false);
  }
}
