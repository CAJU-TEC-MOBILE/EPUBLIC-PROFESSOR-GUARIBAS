import 'package:intl/intl.dart';

class DateTimeUtils {
  static bool isDataAtualNoPeriodo({
    required String dataInicial,
    required String dataFinal,
  }) {
    DateTime dataAtual = DateTime.now();
    DateTime dataInicialFormatada = DateTime.parse(dataInicial);
    DateTime dataFinalFormatada = DateTime.parse(dataFinal);

    return dataAtual.isAfter(dataInicialFormatada) &&
        dataAtual.isAfter(dataFinalFormatada);
  }

  static String get date {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}
