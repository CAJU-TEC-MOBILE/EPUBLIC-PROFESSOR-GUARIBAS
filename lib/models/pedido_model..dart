// ignore_for_file: public_member_api_docs, sort_constructors_first
class Pedido {
  final String id;
  final String descricao;

  Pedido({
    required this.id,
    required this.descricao,
  });

  factory Pedido.fromJson(Map<dynamic, dynamic> pedidoJson) {
    return Pedido(
      id: pedidoJson['id']?.toString() ?? '',
      descricao: pedidoJson['descricao']?.toString() ?? '',
    );
  }
}
