import 'dart:convert';
import 'package:flutter/material.dart';
import '../componentes/dialogs/custom_snackbar.dart';
import '../enums/status_console.dart';
import '../helpers/console_log.dart';
import '../models/auth_model.dart';
import '../models/avaliador_model.dart';
import '../models/instrutor_model.dart';
import '../models/solicitacao_model.dart';
import '../services/adapters/autorizacoes_service.dart';
import '../services/adapters/gestoes_service_adpater.dart';
import '../services/adapters/justificativas_service_adapter.dart';
import '../services/adapters/matriculas_service_adapter.dart';
import '../services/adapters/pedidos_service_adapter.dart';
import '../services/adapters/sistema_bncc_service_adapter.dart';
import '../services/adapters/usuarios_service_adapter.dart';
import '../services/configuracao/configuracao_app.dart';
import '../services/controller/Instrutor_controller.dart';
import '../services/controller/auth_controller.dart';
import '../services/controller/avaliador_controller.dart';
import '../services/controller/disciplina_controller.dart';
import '../services/controller/professor_controller.dart';
import '../services/controller/solicitacao_controller.dart';
import '../services/http/auth/auth_http.dart';
import '../services/http/autorizacoes/avaliador_http.dart';
import '../services/http/autorizacoes/solicitacao_http.dart';
import '../services/http/configuracao/configuracao_http.dart';
import '../services/http/gestoes/gestoes_disciplinas_http.dart';
import '../services/http/gestoes/gestoes_listar_com_outros_dados_http.dart';
import '../services/shared_preference_service.dart';
import 'configuracao_repository.dart';

class AuthRepository {
  final sharedPreferenceService = SharedPreferenceService();
  final instrutorController = InstrutorController();
  final disciplinaController = DisciplinaController();
  final professorController = ProfessorController();
  final authController = AuthController();
  final authHttp = AuthHttp();
  final gestoesService = GestoesService();
  final gestoesListarComOutrosDadosHttp = GestoesListarComOutrosDadosHttp();
  final configuracaoHttp = ConfiguracaoHttp();
  final configuracaoApp = ConfiguracaoApp();
  final gestaoDisciplinaHttp = GestaoDisciplinaHttp();
  final solicitacaoHttp = SolicitacaoHttp();
  final avaliadorController = AvaliadorController();
  final avaliadorHttp = AvaliadorHttp();
  final solicitacaoController = SolicitacaoController();

  final configuracaoRepository = ConfiguracaoRepository();
  Future<bool> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await sharedPreferenceService.init();
      final response = await authHttp.login(email: email, password: password);
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode != 200) {
        String? message = data['error']?['message'].toString();
        CustomSnackBar.showErrorSnackBar(
          context,
          message.toString(),
        );
        return false;
      }

      await authController.init();
      await instrutorController.init();
      await disciplinaController.init();
      await professorController.init();

      await authController.clear();
      await instrutorController.clear();
      await disciplinaController.clear();
      await professorController.clear();

      await Future.delayed(const Duration(seconds: 3));

      final professorData = data['user']['professor'];
      final instrutor = Instrutor(
        id: professorData['id'].toString(),
        nome: professorData['nome'].toString(),
        anoId: data['user']['ano_id'].toString(),
        token: data['user']['token_atual'].toString(),
      );

      final auth = AuthModel.fromJson(data['user']);
      await instrutorController.addInstrutor(instrutor);
      await authController.add(auth);
      await sharedPreferenceService.salvarDadosUsuario(
        accessToken: instrutor.token.toString(),
        successStatus: true,
      );
      sharedPreferenceService.visualizar();

      await gestoesService.atualizarGestoesDispositivo();
      await professorController.create(data['user']['professor']);
      await MatriculasServiceAdapter().salvar(data['matriculas'] ?? []);
      await JustificativasServiceAdapter().salvar(data['justificativas'] ?? []);
      await PedidosServiceAdapter()
          .salvar(data['pedidos_para_autorizacao'] ?? []);
      await UsuariosServiceAdapter()
          .salvar(data['users_para_autorizacao'] ?? []);
      // await AutorizacoesServiceAdapter()
      //     .salvar(data['autorizacoes_socilitadas_pelo_usuario'] ?? []);
      await SistemaBnccServiceAdapter().salvar(data['sistema_bncc'] ?? []);
      await gestaoDisciplinaHttp.getGestaoDisciplinas();
      await gestoesService.atualizarGestoesDoDispositivo(context);
      await configuracaoApp.anos();
      await AuthHttp.setBaixarImage(
        professorId: data['user']['professor']['id']?.toString() ?? '',
        imagemPerfil:
            data['user']['professor']['imagem_perfil']?.toString() ?? '',
        cpf: data['user']['professor']['cpf']?.toString() ?? '',
        userId: data['user']['id']?.toString() ?? '',
      );
      await baixar();
      return true;
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'auth-repository-login',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
      return false;
    }
  }

  Future<void> baixar() async {
    await configuracaoRepository.configHorario();
    print("\n✅ Download de horários completo!");
    await _baixarAvaliadores();
    print("\n✅ Download avaliadores completo!");
    await _baixarSolicitacao();
    print("\n✅ Download solicitação completo!");
  }

  Future<void> _baixarAvaliadores() async {
    try {
      final response = await avaliadorHttp.all();

      if (response.statusCode != 200) {
        return;
      }

      await avaliadorController.init();
      await avaliadorController.clear();

      final data = json.decode(response.body);

      final List<dynamic> avaliadores = data;

      for (var item in avaliadores) {
        final model = AvaliadorModel.fromJson(item);
        await avaliadorController.add(model);
      }
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'baixar-valiadores-repository',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }

  Future<void> _baixarSolicitacao() async {
    try {
      final response = await solicitacaoHttp.all();

      if (response.statusCode != 200) {
        return;
      }
      await solicitacaoController.init();

      await solicitacaoController.clear();

      final data = json.decode(response.body);

      final List<dynamic> solicitacoes = data['solicitacoes'];

      for (final item in solicitacoes) {
        final model = SolicitacaoModel.fromMap(item);
        await solicitacaoController.add(model);
      }
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'baixar-solicitacao-repository',
        mensagem: error.toString(),
        tipo: StatusConsole.error,
      );
    }
  }
}
