String retornarCadaInicialMaiscula({required String texto}) {
  if (texto == '' || texto.isEmpty) {
    return '';
  }

  String result = texto[0].toUpperCase();
  bool capitalizeNext = false;

  for (int i = 1; i < texto.length; i++) {
    String currentChar = texto[i];
    String previousChar = texto[i - 1];

    if (previousChar == ' ') {
      result += currentChar.toUpperCase();
    } else {
      result += currentChar.toLowerCase();
    }
  }

  return result;
}
