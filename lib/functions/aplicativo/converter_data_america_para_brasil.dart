String conveterDataAmericaParaBrasil(String date) {
  List<String> dateParts = date.split('-');
  String day = dateParts[2];
  String month = dateParts[1];
  String year = dateParts[0];
  return '$day/$month/$year';
}
