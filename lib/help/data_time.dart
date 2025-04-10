import 'dart:ffi';

import 'package:intl/intl.dart';

class DataTime {
  static String diaDaSemana(String dataStr) {
    try {
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
    } catch (e) {
      print('error-dia-semana: $e');
      return 'SEM DIA DA SEMANA';
    }
  }

  static bool existeDiaLetivo(DateTime data) {
    try {
      return data.weekday == DateTime.saturday;
    } catch (e) {
      return false;
    }
  }

  static String getDataAtualFormatoISO() {
    DateTime data = DateTime.now();
    String ano = data.year.toString();
    String mes = data.month.toString().padLeft(2, '0');
    String dia = data.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }
}
