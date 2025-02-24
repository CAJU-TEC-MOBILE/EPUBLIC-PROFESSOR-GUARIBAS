bool verificarSeDataAtualEmaior({required String data}) {
  if (data == '') {
    return false;
  }
  DateTime dataAtual = DateTime.now();
  DateTime dataInicialFormatada = DateTime.parse(data);

  if (dataAtual.year == dataInicialFormatada.year &&
      dataAtual.month == dataInicialFormatada.month &&
      dataAtual.day == dataInicialFormatada.day) {
    return false;
  }
  if (dataAtual.isAfter(dataInicialFormatada)) {
    return true;
  }

  return false;
}
