import 'package:intl/intl.dart';

String converterDataAmericaParaBrasil({required String dataString}) {
  DateTime dateTime = DateTime.parse(dataString);
  DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  String formattedDate = dateFormat.format(dateTime);
  return formattedDate;
}
