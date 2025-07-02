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
import '../componentes/dialogs/custom_sync_dialog.dart';
import '../componentes/dialogs/custom_sync_padrao_dialog.dart';
import '../componentes/drawer/custom_drawer.dart';
import '../componentes/global/preloader.dart';
import '../models/ano_model.dart';
import '../models/auth_model.dart';
import '../models/gestao_ativa_model.dart';
import '../repository/auth_repository.dart';
import '../services/adapters/gestao_ativa_service_adapter.dart';
import '../services/adapters/gestoes_service_adpater.dart';
import '../services/connectivity/internet_connectivity_service.dart';
import '../services/controller/ano_controller.dart';
import '../services/controller/ano_selecionado_controller.dart';
import '../services/controller/aula_totalizador_controller.dart';
import '../services/controller/auth_controller.dart';
import '../services/http/aulas/aula_totalizador_http.dart';
import '../services/http/gestoes/gestoes_disciplinas_http.dart';
import '../services/shared_preference_service.dart';
import '../wigets/cards/custom_totalizador_aula_cartd.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AnoController anoController = AnoController();
  final authController = AuthController();
  final aulaTotalizadorController = AulaTotalizadorController();
  final authRepository = AuthRepository();
  final aulaTotalizadorHttp = AulaTotalizadorHttp();
  final preference = SharedPreferenceService();

  AulaTotalizador totalizadorAula = AulaTotalizador.vazio();
  Professor professor = Professor.vazio();
  AuthModel? authModel;
  GestaoAtiva? gestaoAtivaModel;
  Map<dynamic, dynamic> gestao_ativa_data = {};
  bool loadingCard = false;

  Future<void> getInformacoes() async {
    try {
      await authController.init();
      professor = await authController.authProfessorFirst();
      if (professor.id == '') {
        return;
      }
      await getDados();
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

  Future<void> realizarSincronizacaoGeral(
      {required BuildContext context}) async {
    try {
      await authController.init();
      await authRepository.baixar();
      professor = await authController.authProfessorFirst();
      if (professor.id == '') {
        return;
      }
      await getDados();
      gestaoAtivaModel = GestaoAtivaServiceAdapter().exibirGestaoAtiva();
      await getHomeAulaGeral(context: context, professor: professor);
    } catch (error) {
      ConsoleLog.mensagem(
        titulo: 'realizar0-sincronizacao-geral',
        mensagem: error.toString(),
        tipo: 'erro',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getInformacoes();
  }

  Future<void> getHomeAulaGeral(
      {required BuildContext context, required Professor? professor}) async {
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
          await aulaTotalizadorHttp.getAulasTotalizadas(id: professorId);

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
      await anoController.init();
      await aulaTotalizadorController.init();
      await aulaTotalizadorController.clearAll();

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
      await aulaTotalizadorController.addAula(dado);
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
          await aulaTotalizadorHttp.getAulasTotalizadas(id: professorId);
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
        await aulaTotalizadorController.clearAll();
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
        await aulaTotalizadorController.addAula(dado);
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
    await aulaTotalizadorController.init();
    totalizadorAula = await aulaTotalizadorController.totalizador();
    if (totalizadorAula.id != -1) {
      await aulaTotalizadorController.clearAll();
      final AulaTotalizador dado = AulaTotalizador(
        id: 0,
        idProfessor: -1,
        anoAtual: DateTime.now().year,
        totalAula: 0,
        qntAguardandoConfirmacao: 0,
        qntConfirmada: 0,
        qntConflito: 0,
        qntFalta: 0,
        qntInvalida: 0,
      );
      await aulaTotalizadorController.addAula(dado);
    }
    setState(() {
      totalizadorAula = totalizadorAula;
    });
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
                      message:
                          "Tem certeza de que deseja atualizar todos os dados?",
                      onCancel: () => Navigator.of(context).pop(false),
                      onConfirm: () async {
                        showLoading(context);
                        await realizarSincronizacaoGeral(context: context);
                        CustomSnackBar.showSuccessSnackBar(
                          context,
                          'Sincronização realizada com sucesso!',
                        );
                        hideLoading(context);
                        Navigator.pop(context);
                      },
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
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Card(
                    color: AppTema.primaryWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 1.0,
                    child: Row(
                      children: [
                        totalizadorAula != null
                            ? Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Aulas',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: AppTema.primaryDarkBlue,
                                            ),
                                          ),
                                          totalizadorAula.id != -1
                                              ? Text(
                                                  totalizadorAula.anoAtual
                                                      .toString(),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                      const Divider(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Aula confirmada:"),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  totalizadorAula!.qntConfirmada
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  "Aguardando confirmação:",
                                                ),
                                                const SizedBox(
                                                  width: 8.0,
                                                ),
                                                Text(
                                                  totalizadorAula!
                                                      .qntAguardandoConfirmacao
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                    "Aula rejeitada por falta:"),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  totalizadorAula!.qntFalta
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Aula inválida:"),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  totalizadorAula!.qntInvalida
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text("Aula em conflito:"),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  totalizadorAula!.qntConflito
                                                      .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    color:
                                                        AppTema.primaryDarkBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                  ),
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
