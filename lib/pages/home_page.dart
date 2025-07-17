import 'dart:convert';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/help/console_log.dart';
import 'package:professor_acesso_notifiq/models/aula_totalizador_model.dart';
import 'package:professor_acesso_notifiq/models/professor_model.dart';
import 'package:professor_acesso_notifiq/pages/professor/listagem_gestoes_professor.dart';
import '../componentes/card/custom_sugestao_card.dart';
import '../componentes/dialogs/custom_snackbar.dart';
import '../componentes/dialogs/custom_sync_padrao_dialog.dart';
import '../componentes/drawer/custom_drawer.dart';
import '../componentes/global/preloader.dart';
import '../models/ano_model.dart';
import '../models/auth_model.dart';
import '../models/gestao_ativa_model.dart';
import '../repository/auth_repository.dart';
import '../repository/sincronizar_repository.dart';
import '../services/adapters/gestao_ativa_service_adapter.dart';
import '../services/adapters/gestoes_service_adpater.dart';
import '../services/connectivity/internet_connectivity_service.dart';
import '../services/controller/ano_controller.dart';
import '../services/controller/ano_selecionado_controller.dart';
import '../services/controller/aula_totalizador_controller.dart';
import '../services/controller/auth_controller.dart';
import '../services/controller/autorizacao_controller.dart';
import '../services/http/aulas/aula_totalizador_http.dart';
import '../services/http/gestoes/gestoes_disciplinas_http.dart';
import '../services/shared_preference_service.dart';
import '../wigets/cards/custom_totalizador_aula_cartd.dart';
import '../wigets/cards/custom_totalizador_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AnoController anoController = AnoController();
  final authController = AuthController();
  final authRepository = AuthRepository();
  final totalizadorHttp = AulaTotalizadorHttp();
  final preference = SharedPreferenceService();
  final autorizacaoController = AutorizacaoController();
  final totalizadorController = AulaTotalizadorController();
  final sincronizarRepository = SincronizarRepository();
  AulaTotalizador totalizadorAula = AulaTotalizador.vazio();
  Professor professor = Professor.vazio();
  AuthModel? authModel;
  GestaoAtiva? gestaoAtivaModel;
  Map<dynamic, dynamic> gestao_ativa_data = {};
  bool loadingCard = false;

  Future<void> _informacoes() async {
    try {
      await authController.init();
      await getDados();
      bool isConnected = await InternetConnectivityService.isConnected();
      if (!isConnected) {
        ConsoleLog.mensagem(
          titulo: 'get-informacoes',
          mensagem:
              'Você está offline no momento. Verifique sua conexão com a internet.',
          tipo: 'erro',
        );

        return;
      }

      professor = await authController.authProfessorFirst();
      if (professor.id == '') {
        return;
      }

      gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
      await getHomeAula(professor: professor);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'get-informacoes',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  Future<void> sincronizacao({required BuildContext context}) async {
    try {
      showLoading(context);

      await totalizadorController.init();
      await authController.init();

      bool status = await sincronizarRepository.geral(context: context);

      if (!status) {
        totalizadorAula = await totalizadorController.totalizador();
        setState(() => totalizadorAula);
        hideLoading(context);
        hideLoading(context);
      }

      professor = await authController.authProfessorFirst();

      if (professor.id == '') {
        totalizadorAula = await totalizadorController.totalizador();
        setState(() => totalizadorAula);
        hideLoading(context);
        hideLoading(context);
        return;
      }

      final response = await totalizadorHttp.getAulasTotalizadas(
        id: professor.id,
      );
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode != 200) {
        if (response.statusCode != 201) {
          String? message = data['error']?['message'].toString();
          if (response.statusCode == 401) {
            await preference.init();
            await preference.limparDados();
            CustomSnackBar.showInfoSnackBar(
              context,
              'Token de acesso expirado. Faça login novamente.',
            );
            await Navigator.pushReplacementNamed(context, '/login');
            return;
          }
          CustomSnackBar.showSuccessSnackBar(
            context,
            message.toString(),
          );
          return;
        }
      }

      totalizadorAula = await totalizadorController.totalizador();
      setState(() => totalizadorAula);

      await getDados();
      gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
      await getHomeAulaGeral(context: context, professor: professor);

      CustomSnackBar.showSuccessSnackBar(
        context,
        'Sincronização realizada com sucesso!',
      );

      hideLoading(context);
      Navigator.pop(context);
    } catch (error) {
      hideLoading(context);
      Navigator.pop(context);
      ConsoleLog.mensagem(
        titulo: 'sincronizacao',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _informacoes();
  }

  Future<void> getHomeAulaGeral(
      {required BuildContext context, required Professor? professor}) async {
    await anoController.init();
    await totalizadorController.init();
    await totalizadorController.clear();

    if (professor == null) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'O objeto professor é nulo. Operação abortada.',
        tipo: 'erro',
      );
      return;
    }

    String professorId = professor.id.toString();
    if (professorId.isEmpty) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'O ID do professor está vazio. Operação abortada.',
        tipo: 'erro',
      );
      return;
    }

    try {
      final response =
          await totalizadorHttp.getAulasTotalizadas(id: professorId);

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode != 200) {
        String? message = data['error']?['message'].toString();

        if (response.statusCode == 401) {
          await preference.init();
          await preference.limparDados();
          CustomSnackBar.showInfoSnackBar(
            context,
            'Token de acesso expirado. Faça login novamente.',
          );
          await Navigator.pushReplacementNamed(context, '/login');
          return;
        }
        CustomSnackBar.showSuccessSnackBar(
          context,
          message.toString(),
        );
        return;
      }

      if (!data.containsKey('id_professor') ||
          !data.containsKey('ano_atual') ||
          !data.containsKey('total_aula')) {
        ConsoleLog.mensagem(
          titulo: 'Erro',
          mensagem: 'Dados obrigatórios ausentes na resposta.',
          tipo: 'erro',
        );
        return;
      }

      final AulaTotalizador dado = AulaTotalizador(
        id: 0,
        idProfessor: data['id_professor'] ?? -1,
        anoAtual: data['ano_atual'] ?? DateTime.now().year,
        totalAula: data['total_aula'] ?? 0,
        qntAguardandoConfirmacao: data['qnt_aguardando_confirmacao'] ?? 0,
        qntConfirmada: data['qnt_confirmada'] ?? 0,
        qntConflito: data['qnt_conflito'] ?? 0,
        qntFalta: data['qnt_falta'] ?? 0,
        qntInvalida: data['qnt_invalida'] ?? 0,
      );
      await totalizadorController.add(dado);
      await getDados();
      final ano = await anoController.getAnoDescricao(
        descricao: dado.anoAtual.toString(),
      );
      await setSelectedAno(ano: ano, context: context);
      ConsoleLog.mensagem(
        titulo: 'Sucesso',
        mensagem: 'Dados processados com sucesso.',
        tipo: 'sucesso',
      );
      return;
    } catch (e) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'método getHomeAula: $e',
        tipo: 'erro',
      );
    }
  }

  Future<void> getHomeAula({required Professor? professor}) async {
    AulaTotalizadorController aulaTotalizadorController =
        AulaTotalizadorController();
    if (professor == null) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'O objeto professor é nulo. Operação abortada.',
        tipo: 'erro',
      );
      return;
    }
    String professorId = professor.id.toString();
    if (professorId.isEmpty) {
      ConsoleLog.mensagem(
        titulo: 'Erro',
        mensagem: 'O ID do professor está vazio. Operação abortada.',
        tipo: 'erro',
      );
      return;
    }
    try {
      final response =
          await totalizadorHttp.getAulasTotalizadas(id: professorId);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (!data.containsKey('id_professor') ||
            !data.containsKey('ano_atual') ||
            !data.containsKey('total_aula')) {
          ConsoleLog.mensagem(
            titulo: 'Erro',
            mensagem: 'Dados obrigatórios ausentes na resposta.',
            tipo: 'erro',
          );
          return;
        }
        await aulaTotalizadorController.init();
        await aulaTotalizadorController.clear();
        final AulaTotalizador dado = AulaTotalizador(
          id: 0,
          idProfessor: data['id_professor'] ?? -1,
          anoAtual: data['ano_atual'] ?? DateTime.now().year,
          totalAula: data['total_aula'] ?? 0,
          qntAguardandoConfirmacao: data['qnt_aguardando_confirmacao'] ?? 0,
          qntConfirmada: data['qnt_confirmada'] ?? 0,
          qntConflito: data['qnt_conflito'] ?? 0,
          qntFalta: data['qnt_falta'] ?? 0,
          qntInvalida: data['qnt_invalida'] ?? 0,
        );
        await aulaTotalizadorController.init();
        await aulaTotalizadorController.add(dado);
        await getDados();
        ConsoleLog.mensagem(
          titulo: 'Sucesso',
          mensagem: 'Dados processados com sucesso.',
          tipo: 'sucesso',
        );
        return;
      } else {
        ConsoleLog.mensagem(
          titulo: 'Erro',
          mensagem: 'Erro: Resposta com status ${response.statusCode}.',
          tipo: 'erro',
        );
      }
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'get-home-aula',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  Future<void> getDados() async {
    await totalizadorController.init();
    totalizadorAula = await totalizadorController.totalizador();

    if (totalizadorAula.id == -1) {
      await totalizadorController.clear();
      final model = AulaTotalizador.vazio();
      await totalizadorController.add(model);
    }
    setState(() => totalizadorAula);
  }

  Future<void> setSelectedAno(
      {required Ano ano, required BuildContext context}) async {
    try {
      final anoSelecionadoController = AnoSelecionadoController();
      bool isConnectedNotifier =
          await InternetConnectivityService.isConnected();
      if (!isConnectedNotifier) {
        CustomSnackBar.showErrorSnackBar(
          context,
          'Você está offline no momento. Verifique sua conexão com a internet.',
        );
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
        return;
      }
      final authController = AuthController();
      await anoSelecionadoController.init();
      await authController.init();
      int anoId = int.parse(ano.id.toString());
      await anoSelecionadoController.setAnoSelecionado(ano);
      ano = await anoSelecionadoController.getAnoSelecionado();
      await authController.updateAnoId(anoId: anoId);
      await recarregarPageParaObterNovasGestoes();
      await getFranquiaAtualHttp();
    } catch (error) {
      CustomSnackBar.showErrorSnackBar(
        context,
        error.toString(),
      );
    }
  }

  Future<void> getFranquiaAtualHttp() async {
    GestaoDisciplinaHttp gestaoDisciplinaHttp = GestaoDisciplinaHttp();
    await gestaoDisciplinaHttp.getGestaoDisciplinas();
  }

  Future<void> recarregarPageParaObterNovasGestoes() async {
    await GestoesService().atualizarGestoes(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: AppTema.backgroundColorApp,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTema.primaryDarkBlue),
          title: const Text(
            'Home',
            style: TextStyle(color: AppTema.primaryDarkBlue),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.sync,
                color: Colors.black,
                size: 25,
              ),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomSyncPadraoDialog(
                      message: " Deseja sincronizar os dados?",
                      onCancel: () => Navigator.of(context).pop(false),
                      onConfirm: () async =>
                          await sincronizacao(context: context),
                    );
                  },
                );
              },
            ),
          ],
        ),
        drawer: const CustomDrawer(),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const CustomSugestaoCard(
                  titulo: 'Ajude-nos a melhorar\ncom suas sugestões!',
                  imagem: 'assets/image_professor.png',
                ),
                CustomTotalizadorAulaCartd(
                  totalizador: totalizadorAula,
                ),
                Row(
                  children: [
                    totalizadorAula.id != -1
                        ? Expanded(
                            child: CustomTotalizadorCard(
                              totalizador: totalizadorAula,
                            ),
                          )
                        : SizedBox(
                            width: MediaQuery.of(context).size.width - 24.0,
                            height: 200.0,
                            child: loadingCard
                                ? const Center(
                                    child: SizedBox(),
                                  )
                                : const CardLoading(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        8.0,
                                      ),
                                    ),
                                    height: 100,
                                  ),
                          )
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTema.primaryAmarelo,
          elevation: 1.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ListagemGestoesProfessor(),
              ),
            );
          },
          tooltip: 'Add',
          child: const Icon(
            Icons.assignment_add,
            color: AppTema.primaryDarkBlue,
          ),
        ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
