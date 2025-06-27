import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/help/console_log.dart';
import 'package:professor_acesso_notifiq/models/autorizacao_model.dart';

class AutorizacoesServiceAdapter {
  Future<void> salvar(List<dynamic> autorizacoes) async {
    try {
      Box autorizacoesBox = Hive.box('autorizacoes');

      autorizacoesBox.put('autorizacoes', autorizacoes);

      List<dynamic> autorizacoesSalvos = autorizacoesBox.get('autorizacoes');
      print('------------SALVANDO AUTORIZAÇÕES----------------');
      print('TOTAL DE AUTORIZAÇÕES: ${autorizacoesSalvos.length}');
      listar();
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'autorizacoes-service-adapter',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  List<AutorizacaoModel> listar() {
    Box autorizacoesBox = Hive.box('autorizacoes');
    List<dynamic> autorizacoesSalvos = autorizacoesBox.get('autorizacoes');

    List<AutorizacaoModel> autorizacoesListModel = autorizacoesSalvos
        .map((pedido) => AutorizacaoModel.fromJson(pedido))
        .toList();

    return autorizacoesListModel;
  }
}
