import 'package:intl/intl.dart';

class DateTimeUtils {
  static bool isDataAtualNoPeriodo({
    required String dataInicial,
    required String dataFinal,
  }) {
    DateTime dataAtual = DateTime.now();
    DateTime inicio = DateTime.parse(dataInicial);
    DateTime fim = DateTime.parse(dataFinal);
    if (inicio.isAfter(fim)) {
      throw ArgumentError(
        'A data inicial não pode ser posterior à data final.',
      );
    }
    bool estaDentroDoPeriodo =
        !dataAtual.isBefore(inicio) && !dataAtual.isAfter(fim);

    return estaDentroDoPeriodo;
  }

  static String get date {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}
