import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/pedido_model..dart';
import 'package:professor_acesso_notifiq/services/adapters/regras_logicas/pedidos/pedidos_salvar_regra_logica.dart';

class PedidosServiceAdapter {
  Future<void> salvar(List<dynamic> pedidos) async {
    Box _pedidosBox = Hive.box('pedidos');

    _pedidosBox.put(
        'pedidos', PedidosSalvarRegraLogica().executar(pedidos: pedidos));

    List<dynamic> pedidosSalvos = _pedidosBox.get('pedidos');
    print('------------SALVANDO PEDIDOS----------------');
    print('TOTAL DE PEDIDOS: ${pedidosSalvos.length}');
  }

  List<Pedido> listar() {
    Box _pedidosBox = Hive.box('pedidos');
    List<dynamic> pedidosSalvos = _pedidosBox.get('pedidos');

    List<Pedido> pedidosListModel =  pedidosSalvos.map((pedido) => Pedido.fromJson(pedido)).toList();
    return pedidosListModel;
  }
}
