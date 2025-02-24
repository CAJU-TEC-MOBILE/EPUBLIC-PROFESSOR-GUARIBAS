class PedidosSalvarRegraLogica {
  dynamic executar({required List<dynamic> pedidos}) {
    var verificacao = verificarSeListaEstaVazia(pedidos: pedidos);
    return verificacao;
  }

  static dynamic verificarSeListaEstaVazia({required List<dynamic> pedidos}) {
    if (pedidos.isEmpty) {
      print('------------PEDIDOS REGRA LÓGICA FALSE----------------');
      return [];
    }
    print('------------PEDIDOS REGRA LÓGICA TRUE----------------');
    return pedidos;
  }
}
