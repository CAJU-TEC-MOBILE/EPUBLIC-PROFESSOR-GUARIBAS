import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:professor_acesso_notifiq/models/atualizacao_model.dart';

class SobreApp {
  String _versaoApp = 'Carregando...';
  List<Atualizacao> _atualizacoes = [];

  String get versaoApp => _versaoApp;
  List<Atualizacao> get listaAtualizacoes => _atualizacoes;

  /// Carrega informações da versão e monta a lista de atualizações
  Future<void> carregarInformacoesDoApp() async {
    _versaoApp = dotenv.env['VERSAO'] ?? 'Versão padrão';
    final data = dotenv.env['DATA'] ?? 'SEM DATA';

    _atualizacoes = [
      Atualizacao(
        versao: 'Versão: $_versaoApp',
        data: data,
        titulo: 'Lançamento do aplicativo',
        descricao:
            'Primeira versão do aplicativo, que permite os professores gerenciarem tarefas específicas, com a finalidade de facilitar o processo '
            'de criação de aulas, realização de frequência entre outros recursos.',
      ),
    ];
  }
}
