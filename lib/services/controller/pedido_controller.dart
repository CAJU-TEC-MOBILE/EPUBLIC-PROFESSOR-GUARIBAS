import 'package:hive_flutter/hive_flutter.dart';
import '../../models/pedido_model.dart';

class PedidoController {
  late Box<Pedido> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(PedidoAdapter().typeId)) {
      Hive.registerAdapter(PedidoAdapter());
    }

    box = await Hive.openBox<Pedido>('pedidos_enviados');
  }

  Future<bool> add(Pedido model) async {
    try {
      if (!box.isOpen) {
        print('Erro ao adicionar pedido: A caixa está fechada');
        return false;
      }

      await box.add(model);
      return true;
    } catch (e) {
      print('Erro ao adicionar pedido: $e');
      return false;
    }
  }

  List<Pedido> getAll() {
    if (!box.isOpen) {
      print('Erro ao listar pedidos: A caixa está fechada');
      return [];
    }
    return box.values.toList();
  }

  Future<void> clear() async {
    if (box.isOpen) {
      await box.clear();
    }
  }

  List<Pedido> getPeloUserId({required String userId}) {
    if (!box.isOpen) {
      print('Erro ao listar pedidos: A caixa está fechada');
      return [];
    }
    return box.values.where((item) => item.user_id == userId).toList();
  }

  Future<bool> getStatusPeloInstrutorDisciplinaTurmaID({
    required String instrutorDisciplinaTurmaID,
    required String etapaId,
    required String userId,
    required String circuitoId,
  }) async {
    try {
      Box<Pedido> box = Hive.box<Pedido>('pedidos_enviados');

      List<Pedido> valores = box.values.toList();

      bool encontrado = valores.any(
        (item) =>
            item.etapa_id.toString() == etapaId.toString() &&
            item.instrutorDisciplinaTurmaID.toString() ==
                instrutorDisciplinaTurmaID.toString() &&
            item.user_id == userId &&
            item.circuito_id == circuitoId &&
            item.situacao != "APROVADO",
      );
      return encontrado;
    } catch (e) {
      //print("Erro ao buscar status: $e");
      return false;
    }
  }

  Future<int> getAvalidarPeriodo({
    required String instrutorDisciplinaTurmaID,
    required String etapaId,
    required String userId,
    required String circuitoId,
    required String dataFimEtapa,
  }) async {
    try {
      DateTime? dataFim;
      try {
        dataFim = DateTime.parse(dataFimEtapa);
      } catch (e) {
        return 2;
      }

      DateTime hoje = DateTime.now();
      DateTime dataAtual = DateTime(hoje.year, hoje.month, hoje.day);
      DateTime dataFimFormatada =
          DateTime(dataFim.year, dataFim.month, dataFim.day);

      if (dataAtual.isBefore(dataFimFormatada) ||
          dataAtual.isAtSameMomentAs(dataFimFormatada)) {
        return 1;
      }

      Box<Pedido> box = Hive.box<Pedido>('pedidos_enviados');
      List<Pedido> valores = box.values.toList();

      bool encontrado = valores.any(
        (item) =>
            item.etapa_id.toString() == etapaId.toString() &&
            item.instrutorDisciplinaTurmaID.toString() ==
                instrutorDisciplinaTurmaID.toString() &&
            item.user_id == userId &&
            item.circuito_id == circuitoId &&
            item.situacao != "APROVADO",
      );

      return encontrado ? 3 : 2;
    } catch (e) {
      return 2;
    }
  }

  Future<String> getTipoStatusPeloInstrutorDisciplinaTurmaID({
    required String instrutorDisciplinaTurmaID,
    required String etapaId,
    required String userId,
    required String circuitoId,
  }) async {
    try {
      Box<Pedido> box = Hive.box<Pedido>('pedidos_enviados');
      List<Pedido> valores = box.values.toList();

      Pedido? pedidoEncontrado = valores.firstWhere(
        (item) =>
            item.etapa_id.toString() == etapaId.toString() &&
            item.instrutorDisciplinaTurmaID.toString() ==
                instrutorDisciplinaTurmaID.toString() &&
            item.user_id == userId &&
            item.circuito_id == circuitoId,
        orElse: () => Pedido.vazio(),
      );

      return pedidoEncontrado.situacao;
    } catch (e) {
      return 'RECUSADO';
    }
  }

  Future<void> updateSituacaoPeloId({
    required String id,
    required String situacao,
  }) async {
    try {
      Box<Pedido> box = Hive.box<Pedido>('pedidos_enviados');

      for (var key in box.keys) {
        Pedido? item = box.get(key);
        if (item != null && item.id == id) {
          item.situacao = situacao;
          await box.put(key, item);
          break;
        }
      }
    } catch (e) {
      print("Erro ao atualizar status: $e");
    }
  }

  Future<void> close() async {
    if (box.isOpen) {
      await box.close();
    }
  }
}