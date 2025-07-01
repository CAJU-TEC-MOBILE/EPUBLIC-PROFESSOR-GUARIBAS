import 'package:hive_flutter/hive_flutter.dart';

class AulaTotalizador {
  int id;
  int idProfessor;
  int anoAtual;
  int totalAula;
  int qntAguardandoConfirmacao;
  int qntConfirmada;
  int qntConflito;
  int qntFalta;
  int qntInvalida;

  AulaTotalizador({
    required this.id,
    required this.idProfessor,
    required this.anoAtual,
    required this.totalAula,
    required this.qntAguardandoConfirmacao,
    required this.qntConfirmada,
    required this.qntConflito,
    required this.qntFalta,
    required this.qntInvalida,
  });

  factory AulaTotalizador.fromJson(Map<String, dynamic> json) {
    return AulaTotalizador(
      id: json['id'] ?? 0,
      idProfessor: json['id_professor'] ?? 0,
      anoAtual: json['ano_atual'] ?? 0,
      totalAula: json['total_aula'] ?? 0,
      qntAguardandoConfirmacao: json['qnt_aguardando_confirmacao'] ?? 0,
      qntConfirmada: json['qnt_confirmada'] ?? 0,
      qntConflito: json['qnt_conflito'] ?? 0,
      qntFalta: json['qnt_falta'] ?? 0,
      qntInvalida: json['qnt_invalida'] ?? 0,
    );
  }

  factory AulaTotalizador.vazio() {
    return AulaTotalizador(
      id: -1,
      idProfessor: -1,
      anoAtual: -1,
      totalAula: 0,
      qntAguardandoConfirmacao: 0,
      qntConfirmada: 0,
      qntConflito: 0,
      qntFalta: 0,
      qntInvalida: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_professor': idProfessor,
      'ano_atual': anoAtual,
      'total_aula': totalAula,
      'qnt_aguardando_confirmacao': qntAguardandoConfirmacao,
      'qnt_confirmada': qntConfirmada,
      'qnt_conflito': qntConflito,
      'qnt_falta': qntFalta,
      'qnt_invalida': qntInvalida,
    };
  }

  @override
  String toString() {
    return 'AulaTotalizador(id: $id, idProfessor: $idProfessor, anoAtual: $anoAtual, '
        'totalAula: $totalAula, qntAguardandoConfirmacao: $qntAguardandoConfirmacao, '
        'qntConfirmada: $qntConfirmada, qntConflito: $qntConflito, '
        'qntFalta: $qntFalta, qntInvalida: $qntInvalida)';
  }
}

class AulaTotalizadorAdapter extends TypeAdapter<AulaTotalizador> {
  @override
  final int typeId = 40;

  @override
  AulaTotalizador read(BinaryReader reader) {
    return AulaTotalizador(
      id: reader.readInt(),
      idProfessor: reader.readInt(),
      anoAtual: reader.readInt(),
      totalAula: reader.readInt(),
      qntAguardandoConfirmacao: reader.readInt(),
      qntConfirmada: reader.readInt(),
      qntConflito: reader.readInt(),
      qntFalta: reader.readInt(),
      qntInvalida: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, AulaTotalizador obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.idProfessor);
    writer.writeInt(obj.anoAtual);
    writer.writeInt(obj.totalAula);
    writer.writeInt(obj.qntAguardandoConfirmacao);
    writer.writeInt(obj.qntConfirmada);
    writer.writeInt(obj.qntConflito);
    writer.writeInt(obj.qntFalta);
    writer.writeInt(obj.qntInvalida);
  }
}
