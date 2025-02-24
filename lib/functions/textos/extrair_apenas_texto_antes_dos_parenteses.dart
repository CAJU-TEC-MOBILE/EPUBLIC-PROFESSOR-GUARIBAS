String extrairApenasTextoAntesParenteses(String texto) {
  final regex = RegExp(r'(.+?)(?=\()');
  final match = regex.firstMatch(texto);

  if (match != null) {
    return match.group(0) ?? texto;
  }

  return texto;
}
