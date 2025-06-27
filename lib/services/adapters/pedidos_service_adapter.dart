import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/pedido_model.dart';
import 'package:professor_acesso_notifiq/services/adapters/regras_logicas/pedidos/pedidos_salvar_regra_logica.dart';

class PedidosServiceAdapter {
  Future<void> salvar(List<dynamic> pedidos) async {
    Box pedidosBox = Hive.box('pedidos');

    pedidosBox.put(
        'pedidos', PedidosSalvarRegraLogica().executar(pedidos: pedidos));

    List<dynamic> pedidosSalvos = pedidosBox.get('pedidos');
    print('------------SALVANDO PEDIDOS----------------');
    print('TOTAL DE PEDIDOS: ${pedidosSalvos.length}');
  }

  Future<List<Pedido>> listar() async {
    Box pedidosBox = Hive.box('pedidos');
    List<dynamic> pedidosSalvos = await pedidosBox.get('pedidos');
    List<Pedido> pedidosListModel = pedidosSalvos
        .map((pedido) => Pedido.fromJson(jsonEncode(pedido)))
        .toList();

    return pedidosListModel;
  }

  Future<String?> getPeloId({required String id}) async {
    try {
      Box pedidosBox = await Hive.openBox('pedidos');
      List<dynamic>? pedidosSalvos = pedidosBox.get('pedidos');

      String? descricao;

      if (pedidosSalvos == null) return null;

      for (var item in pedidosSalvos) {
        if (item['id'].toString() == id.toString()) {
          descricao = item['descricao'].toString();
        }
      }

      return descricao;
    } catch (e) {
      print('Erro ao buscar pedido pelo ID: $e');
      return null;
    }
  }
}
