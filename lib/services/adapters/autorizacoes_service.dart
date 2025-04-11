import 'package:hive_flutter/hive_flutter.dart';
import 'package:professor_acesso_notifiq/models/autorizacao_model.dart';

class AutorizacoesServiceAdapter {
  Future<void> salvar(List<dynamic> autorizacoes) async {
    Box autorizacoesBox = Hive.box('autorizacoes');

    autorizacoesBox.put('autorizacoes', autorizacoes);

    List<dynamic> autorizacoesSalvos = autorizacoesBox.get('autorizacoes');
    print('------------SALVANDO AUTORIZAÇÕES----------------');
    print('TOTAL DE AUTORIZAÇÕES: ${autorizacoesSalvos.length}');
    listar();
  }

  List<Autorizacao> listar() {
    Box autorizacoesBox = Hive.box('autorizacoes');
    List<dynamic> autorizacoesSalvos = autorizacoesBox.get('autorizacoes');

    List<Autorizacao> autorizacoesListModel = autorizacoesSalvos
        .map((pedido) => Autorizacao.fromJson(pedido))
        .toList();

    return autorizacoesListModel;
  }
}
