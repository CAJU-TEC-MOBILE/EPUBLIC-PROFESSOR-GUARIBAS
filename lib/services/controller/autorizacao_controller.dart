import 'package:hive_flutter/hive_flutter.dart';
import '../../data/adapters/autorizacao_adapter.dart';
import '../../enums/status_console.dart';
import '../../helpers/console_log.dart';
import '../../models/autorizacao_model.dart';

class AutorizacaoController {
  late Box<AutorizacaoModel> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(AutorizacaoAdapter().typeId)) {
      Hive.registerAdapter(AutorizacaoAdapter());
    }

    box = await Hive.openBox<AutorizacaoModel>('autorizacao');
  }

  Future<void> add(AutorizacaoModel model) async {
    try {
      await box.add(model);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'autorizacao-add-controller',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  Future<List<AutorizacaoModel>> autorizacaoPeloUserId(
      {required String userId}) async {
    List<AutorizacaoModel> autorizacoes = box.values
        .where((item) => item.userId.toString() == userId.toString())
        .toList();
    autorizacoes.sort((a, b) => b.id.compareTo(a.id));
    return autorizacoes;
  }

  Future<void> visualizar() async {
    List<AutorizacaoModel> data = box.values.toList();
    print("total: ${data.length.toString()}");
    data.forEach((item) {
      print("=======================");
      print("id: ${item.id.toString()}");
      print("userId: ${item.userId.toString()}");
      print("circuitoNotaId: ${item.etapaId.toString()}");
      print(
        "instrutorDisciplinaTurmaId: ${item.instrutorDisciplinaTurmaId.toString()}",
      );
      print("etapaId: ${item.etapaId.toString()}");
      print("dataExpiracao: ${item.dataExpiracao.toString()}");
      print("observacoes: ${item.observacoes.toString()}");
      print("status: ${item.status.toString()}");
      print("data: ${item.data.toString()}");
      print("mobile: ${item.mobile.toString()}");
    });
  }

  Future<void> update(AutorizacaoModel model) async {
    try {
      final List<AutorizacaoModel> list = box.values.toList();
      final int index = list.indexWhere((item) => item.id == model.id);

      if (index != -1) {
        await box.putAt(index, model);
      }
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'autorizacao-update-controller',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  Future<List<AutorizacaoModel>> autorizacaoStatusEtapaId(
      {required String etapaId, required String status}) async {
    List<AutorizacaoModel> autorizacoes = box.values
        .where(
          (item) =>
              item.etapaId.toString() == etapaId.toString() &&
              item.status.toString() == status.toString(),
        )
        .toList();
    autorizacoes.sort((a, b) => b.id.compareTo(a.id));
    return autorizacoes;
  }
}
