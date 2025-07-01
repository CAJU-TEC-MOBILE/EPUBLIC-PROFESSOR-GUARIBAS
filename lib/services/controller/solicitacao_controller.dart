import 'package:hive_flutter/hive_flutter.dart';
import '../../data/adapters/solicitacao_adapter.dart';
import '../../enums/status_console.dart';
import '../../helpers/console_log.dart';
import '../../models/solicitacao_model.dart';

class SolicitacaoController {
  late Box<SolicitacaoModel> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(SolicitacaoAdapter().typeId)) {
      Hive.registerAdapter(SolicitacaoAdapter());
    }

    box = await Hive.openBox<SolicitacaoModel>('solicitacoes');
  }

  Future<List<SolicitacaoModel>> getAll() async {
    return box.values.toList();
  }

  Future<void> add(SolicitacaoModel model) async {
    try {
      await box.add(model);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'solicitacao-add-controller',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<List<SolicitacaoModel>> all() async {
    List<SolicitacaoModel> avaliadores = box.values.toList();
    avaliadores.sort(
      (a, b) => a.descricao.toString().compareTo(b.descricao.toString()),
    );
    return avaliadores;
  }

  Future<void> visualizar() async {
    List<SolicitacaoModel> etapas = box.values.toList();
    print("total: ${etapas.length.toString()}");
    etapas.forEach((item) {
      print("=======================");
      print("id: ${item.id.toString()}");
      print("descricao: ${item.descricao.toString()}");
    });
  }
}
