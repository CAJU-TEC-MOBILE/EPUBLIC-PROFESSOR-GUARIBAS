String extrairPrimeiroNome(String nomeCompleto) {
  List<String> partes = nomeCompleto.split(' ');
  if (partes.isNotEmpty) {
    String primeiroNome = partes[0];
    if (primeiroNome.length > 25) {
      return primeiroNome.substring(0, 25);
    }
    return primeiroNome;
  }
  return '';
}
