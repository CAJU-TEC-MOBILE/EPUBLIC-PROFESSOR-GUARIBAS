String retornarTextoComPrimeiraLetraMaiscula({required String texto}) {
  if (texto.isEmpty) return '';

  return texto[0].toUpperCase() + texto.substring(1);
}
