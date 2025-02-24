import 'package:intl/intl.dart';

class DataTime {
  static String diaDaSemana(String dataStr) {
    DateTime data = DateTime.parse(dataStr);

    List<String> diasSemana = [
      "Segunda-feira",
      "Terça-feira",
      "Quarta-feira",
      "Quinta-feira",
      "Sexta-feira",
      "Sábado",
      "Domingo"
    ];

    return diasSemana[data.weekday - 1];
  }
}
