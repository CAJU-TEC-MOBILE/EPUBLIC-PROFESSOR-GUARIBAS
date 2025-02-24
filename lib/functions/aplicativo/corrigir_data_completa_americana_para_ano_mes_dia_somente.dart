import 'package:intl/intl.dart';

String corrigirDataCompletaAmericanaParaAnoMesDiaSomente(
    {required String dataString}) {
  DateTime dateTime = DateTime.parse(dataString);
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  String formattedDate = dateFormat.format(dateTime);
  return formattedDate;
}
