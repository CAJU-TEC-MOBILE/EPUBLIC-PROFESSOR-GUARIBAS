import 'package:professor_acesso_notifiq/models/dia_model.dart';
import 'package:professor_acesso_notifiq/models/horario_model.dart';

class RelacaoDiaHorario {
  final String relacaoID;
  final Horario horario;
  final Dia dia;

  RelacaoDiaHorario({
    required this.relacaoID,
    required this.horario,
    required this.dia,
  });

  factory RelacaoDiaHorario.fromJson(Map<dynamic, dynamic> json) {
    return RelacaoDiaHorario(
      relacaoID: json['relacao_id']?.toString() ?? '',
      horario: Horario.fromJson(json['horario'] ?? {}),
      dia: Dia.fromJson(json['dia'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'RelacaoDiaHorario('
        'relacaoID: $relacaoID, '
        'horario: ${horario.toString()}, '
        'dia: ${dia.toString()}'
        ')';
  }
}
