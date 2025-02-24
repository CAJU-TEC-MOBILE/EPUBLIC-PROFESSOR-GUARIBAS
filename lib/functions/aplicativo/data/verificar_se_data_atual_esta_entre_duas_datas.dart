bool verificarSeDataAtualEstaEntreDuasDatas(
    {required String dataInicial, required String dataFinal}) {
  DateTime dataAtual = DateTime.now();
  DateTime dataInicialFormatada = DateTime.parse(dataInicial);
  DateTime dataFinalFormatada = DateTime.parse(dataFinal);

  return dataAtual.isAfter(dataInicialFormatada) &&
      dataAtual.isBefore(dataFinalFormatada);
}
